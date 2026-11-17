local CW = Copperwise
local panel, rail, railContent, detail, selected, title, availability, itemIcon
local quantityInput, priceInputs, depositText, totalText, eligibilityText, postButton
local listContent, listingStatus, message, summary, empty, reconcileButton, refreshButton
local rows, buttons, listingButtons, radios, drafts = {}, {}, {}, {}, {}
local duration, elapsed, painting = 2, 0, false
local preview, listingStamp
local money = CW.FormatMoney

local whole = CW.IsPositiveWhole

local function native(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, ...)
    if ok then return value end
end
local function prepare(id, intent, quantity, price, postingDuration)
    postingDuration = postingDuration or duration
    local row = {id=id, name=intent.name, intended=intent.quantity, intentRevision=CW.IntentRevision(id), quantity=quantity, duration=postingDuration, stacks={}, eligible=0}
    local observation = CW.ObservationFor(id)
    row.price = price
    row.observedAt = observation and observation.observedAt
    if not whole(row.price) then row.price = nil end
    local item = CW.AvailableItem(id)
    if not CW.HoldingsSettled() then row.reason = "Bag holdings are settling"
    elseif not item then row.reason = "Not currently in bags"
    elseif item.support ~= "comparable commodity" then row.reason = item.support
    else
        row.name = item.name
        local remaining, rejected = math.min(quantity or intent.quantity, intent.quantity), {}
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if remaining > 0 and info and info.itemID == id then
                    local location = ItemLocation:CreateFromBagAndSlot(bag, slot)
                    local valid = native(C_AuctionHouse.IsSellItemValid, location, false)
                    local status = native(C_AuctionHouse.GetItemCommodityStatus, location)
                    if info.isLocked then rejected["locked stacks"] = true
                    elseif valid ~= true then rejected["native sell eligibility unavailable or refused"] = true
                    elseif status ~= Enum.ItemCommodityStatus.Commodity then rejected["native commodity classification unavailable or unsupported"] = true
                    else
                        local units = math.min(remaining, info.stackCount)
                        row.stacks[#row.stacks+1] = {bag=bag, slot=slot, location=location,
                            itemID=id, link=info.hyperlink, count=info.stackCount,
                            quantity=units}
                        row.eligible = row.eligible + units
                        remaining = remaining - units
                    end
                end
            end
        end
        if remaining > 0 then
            local reasons = {}
            for reason in pairs(rejected) do reasons[#reasons+1] = reason end
            table.sort(reasons)
            if #reasons > 0 then row.pendingReason = table.concat(reasons, "; ") end
        end
        if row.eligible == 0 then row.reason = "No supported sellable source stacks" end
    end
    row.shortage = item and math.max(0, intent.quantity - item.quantity) or nil
    if CW.HoldingsSettled() and not item then row.shortage = intent.quantity end
    local anchor = row.stacks[1]
    if anchor then
        local limit = native(C_AuctionHouse.GetAvailablePostCount, anchor.location)
        if type(limit) ~= "number" or limit < 0 or limit % 1 ~= 0 then
            row.reason = row.reason or "Native posting quantity unavailable"
            row.eligible = 0
        else
            row.eligible = math.min(row.eligible, limit)
            if row.eligible == 0 then row.reason = row.reason or "No units currently available for native posting" end
        end
        -- Like native Max/Auctionator, one commodity post may span bag stacks.
        -- The native fee applies to the reviewed total, not a sum of stack fees.
        if whole(quantity) and quantity <= row.eligible then
            local deposit = native(C_AuctionHouse.CalculateCommodityDeposit, id, postingDuration, quantity)
            if type(deposit) == "number" and deposit >= 0 and deposit % 1 == 0 then row.deposit = deposit end
        end
    end
    if not row.reason and not row.price then row.reason = "Unit buyout unavailable; enter copper or run Full scan" end
    if not row.reason and row.deposit == nil then row.reason = "Native deposit unavailable" end
    if not row.reason and row.deposit > GetMoney() then row.reason = "Insufficient money for deposit" end
    row.ready = row.reason == nil and row.eligible > 0
    return row
end
CW.PrepareReview = prepare

function CW.BatchReviewEntries()
    local entries = {}
    for id, intent in pairs(CW.SaleIntents()) do
        if intent.destination == "AH" then
            local draft = drafts[id]
            local quantity
            if draft and not draft.defaultQuantity then quantity = draft.quantity
            else quantity = prepare(id, intent, intent.quantity, nil).eligible end
            local reviewed = prepare(id, intent, quantity, nil)
            entries[#entries+1] = {id=id, name=intent.name, intended=intent.quantity,
                intentRevision=CW.IntentRevision(id), quantity=quantity, duration=duration,
                deposit=reviewed.deposit, stacks=reviewed.stacks}
        end
    end
    table.sort(entries, function(a,b) return a.id < b.id end)
    return entries
end

local function label(parent, x, y, width, text, template)
    local font = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    font:SetPoint("TOPLEFT", x, y); font:SetWidth(width); font:SetJustifyH("LEFT")
    if text then font:SetText(text) end
    return font
end

local function button(parent, text, x, y, width, click)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 23); b:SetPoint("TOPLEFT", x, y); b:SetText(text)
    b:SetScript("OnClick", click)
    return b
end

local function input(parent, x, y, width, maxLetters, change)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetSize(width, 22); box:SetPoint("TOPLEFT", x, y); box:SetAutoFocus(false)
    box:SetMaxLetters(maxLetters); box:SetNumeric(true)
    box:SetScript("OnTextChanged", function() if not painting then change() end end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    return box
end

local function putPrice(price)
    painting = true
    priceInputs[1]:SetText(price and tostring(math.floor(price / 10000)) or "")
    priceInputs[2]:SetText(price and tostring(math.floor(price / 100) % 100) or "")
    priceInputs[3]:SetText(price and tostring(price % 100) or "")
    painting = false
end

local function readPrice()
    local values = {}
    for i, box in ipairs(priceInputs) do
        local value = tonumber(box:GetText())
        if value == nil or value < 0 or value % 1 ~= 0 or (i > 1 and value > 99) then return nil end
        values[i] = value
    end
    local price = values[1]*10000 + values[2]*100 + values[3]
    return whole(price) and price or nil
end

local function editTerms(priceEdited)
    if CW.BatchActive and CW.BatchActive() then CW.StopBatch("Review terms changed; start a fresh batch.") end
    if not selected then return end
    local draft = drafts[selected]
    if not draft then return end
    draft.quantity, draft.price = tonumber(quantityInput:GetText()), readPrice()
    if priceEdited then draft.edited = true end
    CW.RenderReview()
end

local function choose(id)
    selected, listingStamp = id, nil
    for _, box in ipairs(priceInputs) do box:ClearFocus() end
    quantityInput:ClearFocus()
    local intent = CW.SaleIntent(id)
    local draft = drafts[id]
    if not draft then
        local row = prepare(id, intent, intent.quantity, nil)
        local observation = CW.ObservationFor(id)
        draft = {quantity=row.eligible, price=observation and observation.minimum, edited=false, defaultQuantity=true}
        drafts[id] = draft
    end
    painting = true; quantityInput:SetText(tostring(draft.quantity or "")); painting = false
    putPrice(draft.price)
    CW.CloseListings()
end

local function renderListings(id)
    local result = CW.ItemListings(id)
    local valid = result and result.full and result.state == "complete"
    if valid and listingStamp ~= result then
        listingStamp = result
        local draft = drafts[id]
        if not draft.edited then
            draft.price = result.levels[1] and result.levels[1].price
            putPrice(draft.price)
        end
    end
    local levels = valid and result.levels or {}
    listingStatus:SetText(result and ((valid and ("Observed " .. date("%H:%M:%S", result.observedAt) .. " · " .. result.units .. " units. ") or "") .. result.reason)
        or "Refresh item to load individual listings. Post all uses a targeted summary scan.")
    for index, level in ipairs(levels) do
        local b = listingButtons[index]
        if not b then
            b = CreateFrame("Button", nil, listContent)
            b:SetHeight(24); b:SetPoint("LEFT", 0, 0); b:SetPoint("RIGHT", 0, 0)
            b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            b.price = label(b, 8, -4, 180)
            b.units = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            b.units:SetPoint("TOPRIGHT", -10, -4); b.units:SetJustifyH("RIGHT")
            listingButtons[index] = b
        end
        b:ClearAllPoints(); b:SetPoint("TOPLEFT", 0, -(index-1)*24); b:SetPoint("RIGHT", listContent, "RIGHT", 0, 0)
        b.price:SetText(money(level.price)); b.units:SetText(tostring(level.quantity)); b:Show()
        local price = level.price
        b:SetScript("OnClick", function()
            local draft = drafts[selected]
            if not draft then return end
            draft.price, draft.edited = price, true
            putPrice(price); CW.RenderReview()
        end)
    end
    for i = #levels+1, #listingButtons do listingButtons[i]:Hide() end
    listContent:SetHeight(math.max(1, #levels*24))
end

function CW.RenderReview()
    if not panel or not panel:IsShown() then return end
    rows = {}
    local present, units = {}, 0
    for id, intent in pairs(CW.SaleIntents()) do
        if intent.destination == "AH" then
            rows[#rows+1] = {id=id, intent=intent}
            present[id], units = true, units + intent.quantity
        end
    end
    for id in pairs(drafts) do if not present[id] then drafts[id] = nil end end
    table.sort(rows, function(a,b) if a.intent.name ~= b.intent.name then return a.intent.name < b.intent.name end; return a.id < b.id end)
    if not present[selected] then selected = nil end
    -- Select before rendering, but defer querying until the UI has a draft.
    if not selected and rows[1] then choose(rows[1].id) end
    summary:SetText(#rows .. " marked items · " .. units .. " intended units")
    for index, row in ipairs(rows) do
        local b = buttons[index]
        if not b then
            b = CreateFrame("Button", nil, railContent)
            b:SetSize(180, 44); b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            b.icon = b:CreateTexture(nil, "ARTWORK"); b.icon:SetSize(28, 28); b.icon:SetPoint("TOPLEFT", 3, -6)
            b.name = label(b, 37, -5, 116)
            b.name:SetWordWrap(false)
            b.selection = b:CreateTexture(nil, "BACKGROUND")
            b.selection:SetAllPoints(); b.selection:SetColorTexture(0.6,0.48,0.2,0.3)
            b.count = label(b, 155, -5, 30)
            b.state = label(b, 37, -23, 145)
            buttons[index] = b
        end
        b:SetPoint("TOPLEFT", 0, -(index-1)*46)
        local item = CW.AvailableItem(row.id)
        local _, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(row.id)
        b.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        b.name:SetText((row.id == selected and "|cffffd36b" or "|cffffffff") .. row.intent.name .. "|r")
        b.selection:SetShown(row.id == selected)
        b.count:SetText(tostring(row.intent.quantity))
        b.state:SetText((CW.BatchItemReason and CW.BatchItemReason(row.id)) or (item and (item.quantity < row.intent.quantity and ("Short " .. (row.intent.quantity-item.quantity)) or "Marked for AH")
            or (CW.HoldingsSettled() and "Not in bags" or "Availability pending")))
        local id = row.id
        b:SetScript("OnClick", function() choose(id); CW.RenderReview() end)
        b:Show()
    end
    for i = #rows+1, #buttons do buttons[i]:Hide() end
    railContent:SetHeight(math.max(1, #rows*46))
    local postingNotice, pendingPost = CW.PostingNotice()
    if CW.RenderBatch then CW.RenderBatch() end
    reconcileButton:SetShown(pendingPost)
    empty:SetShown(not selected)
    detail:SetShown(selected ~= nil)
    if not selected then
        preview = nil
        CW.CloseListings()
        message:SetText((CW.BatchNotice and CW.BatchNotice()) or postingNotice or CW.intentNotice or "Mark items for AH in Inventory, then return here.")
        return
    end
    local intent, draft = CW.SaleIntent(selected), drafts[selected]
    renderListings(selected)
    local row = prepare(selected, intent, draft.quantity, draft.price)
    local item = CW.AvailableItem(selected)
    if draft.defaultQuantity and not quantityInput:HasFocus() then
        local available = prepare(selected, intent, intent.quantity, draft.price).eligible
        draft.quantity = available
        painting = true; quantityInput:SetText(tostring(available)); painting = false
        row = prepare(selected, intent, available, draft.price)
    end
    title:SetText(row.name)
    local _, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(selected)
    itemIcon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    availability:SetText(intent.quantity .. " marked · " .. (item and item.quantity or (CW.HoldingsSettled() and 0 or "?")) .. " in bags"
        .. (row.shortage and row.shortage > 0 and (" · short " .. row.shortage) or ""))
    eligibilityText:SetText("Eligible " .. row.eligible .. " · " .. #row.stacks .. " stacks")
    local validQuantity = whole(draft.quantity) and draft.quantity <= intent.quantity and draft.quantity <= row.eligible
    if not validQuantity then row.ready = false; row.reason = "Enter positive whole units within eligible marked holdings." end
    depositText:SetText(money(validQuantity and row.deposit or nil))
    totalText:SetText(money(validQuantity and row.price and row.price*draft.quantity or nil))
    for index, radio in ipairs(radios) do radio:SetChecked(index == duration) end
    local postingReason = CW.PostingReason()
    postButton:SetEnabled(row.ready and not postingReason and not (CW.BatchActive and CW.BatchActive()))
    postButton:SetText("Post item")
    local notice, pending = CW.PostingNotice()
    reconcileButton:SetShown(pending)
    local status = (CW.BatchNotice and CW.BatchNotice()) or notice or row.reason or row.pendingReason or postingReason or "Ready. Click a listing price to use it."
    message:SetText(status)
    refreshButton:SetEnabled(not CW.PostingBlocksScan())
    preview = row
end

function CW.PostConfirmed(id, units)
    local draft = drafts[id]
    if draft then
        draft.quantity = math.max(0, (draft.quantity or 0) - units)
        draft.defaultQuantity = draft.quantity == 0
        if selected == id then painting = true; quantityInput:SetText(tostring(draft.quantity)); painting = false end
    end
end

function CW.DiscardReview()
    if CW.StopBatch then CW.StopBatch("Left Copperwise; batch stopped.") end
    drafts, selected, preview, listingStamp, duration = {}, nil, nil, nil, 2
    CW.CloseListings(); CW.ClosePosting()
    if quantityInput then quantityInput:ClearFocus() end
    for _, box in ipairs(priceInputs or {}) do box:ClearFocus() end
end

function CW.SetupReview(parent)
    panel = parent
    rail = CreateFrame("Frame", nil, panel)
    rail:SetPoint("TOPLEFT", 12, -46); rail:SetPoint("BOTTOMLEFT", 12, 30); rail:SetWidth(205)
    local railBackground = rail:CreateTexture(nil, "BACKGROUND")
    railBackground:SetAllPoints(); railBackground:SetColorTexture(0,0,0,0.2)
    label(rail, 3, -3, 190, "Marked for AH", "GameFontNormal")
    local railScroll = CreateFrame("ScrollFrame", nil, rail, "UIPanelScrollFrameTemplate")
    railScroll:SetPoint("TOPLEFT", 0, -26); railScroll:SetPoint("BOTTOMRIGHT", -23, 0)
    railContent = CreateFrame("Frame", nil, railScroll); railContent:SetSize(182, 1); railScroll:SetScrollChild(railContent)
    detail = CreateFrame("Frame", nil, panel)
    detail:SetPoint("TOPLEFT", 240, -46); detail:SetPoint("BOTTOMRIGHT", -12, 50)
    itemIcon = detail:CreateTexture(nil, "ARTWORK"); itemIcon:SetSize(34,34); itemIcon:SetPoint("TOPLEFT", 0, 0)
    title = label(detail, 44, 0, 390, nil, "GameFontNormalLarge")
    availability = label(detail, 44, -24, 390)
    label(detail, 0, -65, 80, "Quantity")
    quantityInput = input(detail, 86, -60, 60, 10, function()
        if drafts[selected] then drafts[selected].defaultQuantity = false end
        editTerms()
    end)
    button(detail, "Max", 155, -60, 48, function()
        local intent = selected and CW.SaleIntent(selected)
        if not intent then return end
        local row = prepare(selected, intent, intent.quantity, readPrice())
        painting = true; quantityInput:SetText(tostring(row.eligible)); painting = false
        local draft = drafts[selected]; draft.defaultQuantity = true; draft.quantity = row.eligible
        CW.RenderReview()
    end)
    eligibilityText = label(detail, 86, -85, 220)
    label(detail, 0, -116, 80, "Unit buyout")
    priceInputs = {}
    local coins = {"Gold", "Silver", "Copper"}
    for i = 1, 3 do
        priceInputs[i] = input(detail, 86+(i-1)*66, -110, 45, i==1 and 6 or 2, function() editTerms(true) end)
        local coin = detail:CreateTexture(nil, "ARTWORK")
        coin:SetSize(14,14); coin:SetPoint("TOPLEFT", 133+(i-1)*66, -114)
        coin:SetTexture("Interface\\MoneyFrame\\UI-" .. coins[i] .. "Icon")
    end
    label(detail, 0, -154, 80, "Duration")
    for i, hours in ipairs({2,8,24}) do
        local radio = CreateFrame("CheckButton", nil, detail, "UIRadioButtonTemplate")
        radio:SetSize(18,18); radio:SetPoint("TOPLEFT", 84+(i-1)*62, -149)
        label(detail, 105+(i-1)*62, -153, 35, hours .. "h")
        local index = i
        radio:SetScript("OnClick", function()
            if CW.StopBatch then CW.StopBatch("Duration changed; start a fresh batch.") end
            duration = index; CW.RenderReview()
        end)
        radios[i] = radio
    end
    local metrics = CreateFrame("Frame", nil, detail)
    metrics:SetPoint("TOPRIGHT", 0, -60); metrics:SetSize(120, 110)
    label(metrics, 0, 0, 120, "Deposit", "GameFontNormal")
    depositText = label(metrics, 0, -18, 120)
    label(metrics, 0, -40, 120, "Total price", "GameFontNormal")
    totalText = label(metrics, 0, -58, 120)
    metrics.PostItem = function() CW.PostReviewedItem(preview) end
    postButton = CreateFrame("Button", "CopperwisePostItemButton", metrics, "CopperwisePostItemButtonTemplate")
    postButton:SetSize(120,25); postButton:SetPoint("TOPLEFT", 0, -85); postButton:SetText("Post item")
    label(detail, 0, -191, 200, "Current listings", "GameFontNormal")
    refreshButton = button(detail, "Refresh item", 0, 0, 110, function()
        if selected then CW.SelectListings(selected, true); CW.RefreshPosting() end
    end)
    refreshButton:ClearAllPoints(); refreshButton:SetPoint("TOPRIGHT", 0, -184)
    listingStatus = label(detail, 0, -214, 450)
    label(detail, 8, -246, 240, "Buyout price / unit", "GameFontNormal")
    local available = detail:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    available:SetPoint("TOPRIGHT", -30, -246); available:SetText("Available")
    local scroll = CreateFrame("ScrollFrame", nil, detail, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -265); scroll:SetPoint("BOTTOMRIGHT", -24, 2)
    listContent = CreateFrame("Frame", nil, scroll); listContent:SetSize(400,1); scroll:SetScrollChild(listContent)
    scroll:HookScript("OnSizeChanged", function(self, width) listContent:SetWidth(math.max(1,width)) end)
    empty = label(panel, 250, -74, 380, "No items marked for AH.", "GameFontNormal")
    summary = label(panel, 12, -8, 205)
    summary:ClearAllPoints(); summary:SetPoint("BOTTOMLEFT", 12, 8)
    message = label(panel, 240, -8, 320)
    message:ClearAllPoints(); message:SetPoint("BOTTOMLEFT", 240, 7)
    reconcileButton = button(panel, "Reconcile post", 0,0,125,function()
        local description, token = CW.PendingPostDetails()
        StaticPopup_Show("COPPERWISE_RECONCILE_POST", description, nil, token)
    end)
    reconcileButton:ClearAllPoints(); reconcileButton:SetPoint("BOTTOMRIGHT", -12, 6)
    StaticPopupDialogs.COPPERWISE_RECONCILE_POST = {
        text="%s\n\nInspect native Auctions and bags for Copperwise's pending post. Count as posted reduces the unchanged reviewed intent; Keep intent clears the blocker without reducing intent. Never retry a posted listing.",
        button1="Count as posted", button2="Cancel", button3="Keep intent",
        OnAccept=function(_, token) CW.ResolvePost(true, token) end,
        OnCancel=function() end,
        OnAlt=function(_, token) CW.ResolvePost(false, token) end, timeout=0, whileDead=true, hideOnEscape=true, preferredIndex=3,
    }
    panel:HookScript("OnShow", function() CW.OpenPosting(); CW.RenderReview() end)
    panel:HookScript("OnHide", CW.DiscardReview)
    panel:HookScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed >= 0.25 then elapsed = 0; CW.RenderReview() end
    end)
end
