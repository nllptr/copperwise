local CW = Copperwise
local frame = CreateFrame("Frame")
local baseline, query, wanted, visible, ownPost, pending, notice
local loaded = false
local baselineFailure

local function validLedger(value)
    if type(value) ~= "table" or value.version ~= 1 or type(value.beforeIDs) ~= "table" then return false end
    for _, key in ipairs({"id", "quantity", "price", "intentQuantity", "beforeUnits"}) do
        local n = value[key]
        if not CW.IsPositiveWhole(n) then return false end
    end
    return value.quantity <= value.intentQuantity and value.quantity <= value.beforeUnits
        and (value.duration == 1 or value.duration == 2 or value.duration == 3)
end

local function changed()
    if CW.RenderReview then CW.RenderReview() end
end

local function store(value)
    pending = value
    CopperwiseDB.pendingPost = value
end

local function owned()
    if type(C_AuctionHouse.HasFullOwnedAuctionResults) ~= "function"
        or not C_AuctionHouse.HasFullOwnedAuctionResults() then
        error("Your owned auctions are still loading. Refresh item to retry the posting check.", 0)
    end
    local count = C_AuctionHouse.GetNumOwnedAuctions()
    if type(count) ~= "number" or count < 0 or count % 1 ~= 0 or count > 10000 then error("Your owned-auction count is unavailable. Refresh item to retry the posting check.", 0) end
    local rows, ids, byID = {}, {}, {}
    for index = 1, count do
        local row = C_AuctionHouse.GetOwnedAuctionInfo(index)
        if not row or type(row.auctionID) ~= "number" or row.auctionID <= 0 or row.auctionID % 1 ~= 0 then
            error("Owned auction " .. index .. " of " .. count .. " has no usable auction ID. Market listings can still load.", 0)
        end
        -- Keep native numeric IDs as keys; tostring can round large IDs and
        -- make different auctions appear to have the same identity.
        local previous = byID[row.auctionID]
        if previous then
            local a, b = previous.itemKey, row.itemKey
            if not a or not b or a.itemID ~= b.itemID or a.itemLevel ~= b.itemLevel
                or a.itemSuffix ~= b.itemSuffix or a.battlePetSpeciesID ~= b.battlePetSpeciesID
                or previous.quantity ~= row.quantity or previous.buyoutAmount ~= row.buyoutAmount
                or previous.bidAmount ~= row.bidAmount or previous.status ~= row.status then
                error("Owned auction ID " .. string.format("%.0f",row.auctionID) .. " has conflicting rows. Market listings can still load.", 0)
            end
            -- Repeated identical cache rows describe the same listing, not more units.
        else
            ids[row.auctionID], byID[row.auctionID] = true, row
            rows[#rows+1] = row
        end
    end
    return rows, ids
end

local function confirm()
    if not validLedger(pending) or pending.conflict or not pending.rows then return end
    if not CW.HoldingsSettled() then return end
    local item = CW.AvailableItem(pending.id)
    local available = item and item.quantity or 0
    if pending.beforeUnits - available ~= pending.quantity then return end
    local matchedUnits = 0
    for _, row in ipairs(pending.rows) do
        if not pending.beforeIDs[row.auctionID] and row.itemKey and row.itemKey.itemID == pending.id
            and CW.IsPositiveWhole(row.quantity) and row.buyoutAmount == pending.price then
            -- Commodity owned buyout is per unit (as used by Auctionator's
            -- Cancelling provider); target-client acceptance checks this too.
            matchedUnits = matchedUnits + row.quantity
        end
    end
    if matchedUnits ~= pending.quantity then return end
    local ok, reason = CW.ConfirmPostedIntent(pending.id, pending.quantity, pending.intentQuantity, pending.intentRevision)
    if not ok then notice = reason; return end
    local id, units = pending.id, pending.quantity
    store(nil)
    baseline = nil
    wanted = visible
    notice = "Confirmed " .. units .. " posted units (item " .. id .. ") against owned listings and bags."
    if CW.PostConfirmed then CW.PostConfirmed(id, units) end
    if CW.Render then CW.Render() end
    changed()
end

function CW.OpenPosting()
    visible, wanted = true, true
    if not pending then notice = nil; baselineFailure = nil end
end

function CW.ClosePosting()
    visible, wanted, baseline = false, false, nil
    if pending then
        if type(pending) == "table" then pending.conflict = true end
        notice = "Posting stopped. Inspect Auctions and reconcile the pending outcome." end
end

function CW.PostingBlocksScan()
    return pending ~= nil
end

function CW.PostingNotice()
    return notice, pending ~= nil
end

function CW.PostingReason()
    if not loaded then return "Posting state is loading." end
    if pending then return "Pending post: inspect native Auctions and reconcile before another post." end
    if query then return "Loading owned listings for posting attribution." end
    if baselineFailure then return baselineFailure end
    if not baseline or GetTime() - baseline.at > 60 then
        wanted = true
        return "Waiting for fresh owned listings."
    end
    return CW.AHReadiness("posting", 0.2)
end

function CW.RefreshPosting()
    if not query then
        wanted, baselineFailure = true, nil
        if not pending then notice = nil end
    end
end

function CW.InterruptPosting(reason)
    baseline, baselineFailure = nil, nil
    if query then query = nil; CW.AHOperation = nil; CW.AHResponseUncertain = true end
    if pending then
        if type(pending) == "table" then pending.conflict = true end
        notice = reason end
end

-- Called only by XML OnClick -> parent:PostItem(), matching the verified probe.
-- No pcall, rendering, printing or disabling the button before the native post.
function CW.PostReviewedItem(review)
    local reason = CW.PostingReason()
    if reason then notice = reason; return end
    local sourceStack = review and review.stacks and review.stacks[1]
    local intent = review and CW.SaleIntent(review.id)
    if not sourceStack or not review.ready or not intent or intent.destination ~= "AH"
        or intent.quantity ~= review.intended or CW.IntentRevision(review.id) ~= review.intentRevision
        or not CW.HoldingsSettled() then
        notice = "Intent or holdings changed; review again."; return
    end
    if not CW.IsPositiveWhole(review.quantity) or review.quantity > review.eligible then
        notice = "Reviewed quantity changed; review again."; return
    end
    -- Revalidate every reviewed contributor, then use one native anchor location.
    for _, source in ipairs(review.stacks) do
        local bagItem = C_Container.GetContainerItemInfo(source.bag, source.slot)
        if not bagItem or bagItem.isLocked or bagItem.itemID ~= review.id or bagItem.stackCount ~= source.count
            or not C_Item.DoesItemExist(source.location) or C_Item.GetItemLink(source.location) ~= source.link
            or C_Item.GetStackCount(source.location) ~= source.count
            or not C_AuctionHouse.IsSellItemValid(source.location, false)
            or C_AuctionHouse.GetItemCommodityStatus(source.location) ~= Enum.ItemCommodityStatus.Commodity then
            notice = "Source stacks changed; review again."; return
        end
    end
    local limit = C_AuctionHouse.GetAvailablePostCount(sourceStack.location)
    if type(limit) ~= "number" or limit < review.quantity then
        notice = "Native available quantity changed; review again."; return
    end
    local deposit = C_AuctionHouse.CalculateCommodityDeposit(review.id, review.duration, review.quantity)
    if type(deposit) ~= "number" or deposit ~= review.deposit or GetMoney() < deposit then
        notice = "Deposit or funds changed; review again."; return
    end
    local item = CW.AvailableItem(review.id)
    if not item then notice = "Bag holdings changed; review again."; return end
    -- This ledger survives reload/logout. Never retry an unresolved native call.
    store({version=1, id=review.id, quantity=review.quantity, price=review.price, duration=review.duration,
        intentQuantity=intent.quantity, intentRevision=CW.IntentRevision(review.id),
        beforeUnits=item.quantity, beforeIDs=baseline.ids,
        started=time(), conflict=false})
    baseline, ownPost = nil, true
    notice = "Posting " .. review.quantity .. " units; awaiting owned listings and settled bags."
    local needsConfirmation = C_AuctionHouse.PostCommodity(sourceStack.location, review.duration, review.quantity, review.price)
    ownPost = false
    if needsConfirmation then
        pending.conflict = true
        -- Preserve the native confirmation path rather than bypassing it.
        local nativeSell = AuctionHouseFrame and AuctionHouseFrame.CommoditiesSellFrame
        if nativeSell and nativeSell.CachePendingPost then
            nativeSell:CachePendingPost(sourceStack.location, review.duration, review.quantity, review.price)
        end
        notice = "Native confirmation required; resolve it, then inspect Auctions and reconcile."
    end
    wanted = true
end

function CW.PendingPostDetails()
    if not validLedger(pending) then return "Unsupported pending-post data is preserved.", pending end
    return "Item " .. pending.id .. " · " .. pending.quantity .. " units · "
        .. pending.price .. " copper/unit · duration " .. ({2,8,24})[pending.duration] .. "h", pending
end

function CW.ResolvePost(posted, reviewedPending)
    if not pending or pending ~= reviewedPending then return end
    if not validLedger(pending) then
        notice = "Unsupported or malformed pending-post data preserved; manual recovery required."; changed(); return
    end
    if posted then
        local ok, reason = CW.ConfirmPostedIntent(pending.id, pending.quantity, pending.intentQuantity)
        if not ok then notice = reason .. " Adjust intent in Inventory, then choose Keep intent."; changed(); return end
        if CW.PostConfirmed then CW.PostConfirmed(pending.id, pending.quantity) end
    end
    store(nil)
    notice = posted and "Operator confirmed posting; intent reduced." or "Operator reconciled outcome; current intent kept."
    baseline, wanted = nil, visible
    changed()
    if CW.Render then CW.Render() end
end

frame:SetScript("OnUpdate", function()
    if not loaded then return end
    if ownPost then
        ownPost = false
        if type(pending) == "table" then pending.conflict = true end
        notice = "Native posting did not return normally; inspect Auctions and reconcile."
    end
    local ok, err = pcall(function()
        confirm()
        if query and GetTime() > query.deadline then
            query, CW.AHOperation, CW.AHResponseUncertain = nil, nil, true
            notice = "Owned-listing response timed out; close/reopen AH. Pending intent is preserved."
        elseif wanted and visible and not query and not CW.AHReadiness("posting", 2) then
            wanted = false
            CW.AHOperation = "posting"
            query = {deadline=GetTime()+20}
            local sent, reason = CW.AHRequest("QueryOwnedAuctions", {})
            if not sent then
                query, CW.AHOperation = nil, nil
                baselineFailure = "Could not refresh your owned auctions. Refresh item to retry."
                notice = baselineFailure
            end
        end
    end)
    if not ok then
        if query then CW.AHResponseUncertain = true; query, CW.AHOperation = nil, nil end
        notice = tostring(err)
    end
end)
frame:SetScript("OnEvent", function(_, event, addon)
    if event == "PLAYER_LOGIN" then
        loaded = type(CopperwiseDB) == "table"
        if loaded then pending = CopperwiseDB.pendingPost end
        if pending then
            if type(pending) == "table" then pending.conflict = true end
            notice = "Restored unresolved post. Inspect native Auctions and bags; reconcile before posting."
        end
        for _, name in ipairs({"PostCommodity", "PostItem", "CancelAuction"}) do
            if type(C_AuctionHouse[name]) == "function" then
                hooksecurefunc(C_AuctionHouse, name, function()
                    if not ownPost then CW.InterruptPosting("Other posting/cancellation activity; reconcile Copperwise's pending outcome.") end
                end)
            end
        end
    elseif event == "AUCTION_HOUSE_CLOSED" then
        CW.ClosePosting()
        query, CW.AHOperation = nil, nil
    elseif event == "OWNED_AUCTIONS_UPDATED" and query then
        if C_AuctionHouse.HasFullOwnedAuctionResults and not C_AuctionHouse.HasFullOwnedAuctionResults() then return end
        query, CW.AHOperation = nil, nil
        local ok, rows, ids = pcall(owned)
        if ok then
            if pending and type(pending) == "table" and pending.version == 1 then pending.rows = rows; confirm()
            elseif not pending then
                baseline = {ids=ids, at=GetTime()}
                if baselineFailure then notice = nil end
                baselineFailure = nil
            end
        else
            -- A failed posting check must not retry every review tick and starve
            -- unrelated market queries. Refresh item/reopening explicitly retries it.
            wanted = false
            baselineFailure = "Posting paused: " .. tostring(rows)
            notice = baselineFailure
        end
    elseif pending and (event == "AUCTION_MULTISELL_UPDATE" or event == "AUCTION_MULTISELL_FAILURE"
        or event == "AUCTION_HOUSE_SHOW_ERROR") then wanted = true
    elseif pending and (event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN") and addon == "Copperwise" then
        ownPost = false
        if type(pending) == "table" then pending.conflict = true end
        notice = "Client blocked posting. No automatic retry; inspect Auctions and reconcile."
    end
end)
for _, event in ipairs({"PLAYER_LOGIN", "AUCTION_HOUSE_CLOSED", "OWNED_AUCTIONS_UPDATED",
    "AUCTION_MULTISELL_UPDATE", "AUCTION_MULTISELL_FAILURE", "AUCTION_HOUSE_SHOW_ERROR",
    "ADDON_ACTION_BLOCKED", "ADDON_ACTION_FORBIDDEN"}) do pcall(frame.RegisterEvent, frame, event) end
