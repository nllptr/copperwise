local CW = Copperwise
local frame = CreateFrame("Frame")
local batch, notice, reasons = nil, nil, {}
local dispatchReview, hardwareRequired, minimumInput
local MAX_KEYS, CHUNK_SIZE, MAX_REQUESTS = 1000, 100, 100
local FRESH_SECONDS = 60

function CW.BatchActive() return batch ~= nil end
function CW.BatchNotice() return notice end
function CW.BatchItemReason(id) return reasons[id] end
function CW.BatchAllowsReview(review) return review == dispatchReview end
function CW.ClearBatchResult()
    if not batch then notice, reasons = nil, {} end
end

function CW.MinimumListedUnits()
    local value = type(CopperwiseDB) == "table" and CopperwiseDB.minimumListedUnits
    if CW.IsPositiveWhole(value) then return value end
    return 500
end

local function changed()
    if CW.RenderReview then CW.RenderReview() end
end

function CW.StopBatch(reason)
    if not batch then return end
    if batch.waiting then CW.AHResponseUncertain = true end
    if CW.AHOperation == "batch" then CW.AHOperation = nil end
    batch, dispatchReview = nil, nil
    notice = reason or "Batch stopped. Unfinished intent retained."
    changed()
end

local function skip(entry, reason)
    reasons[entry.id] = reason
    batch.skipped = batch.skipped + 1
    batch.index = batch.index + 1
end

local function request(more)
    if CW.AHReadiness("batch", 0.2) then return end
    if batch.requests >= MAX_REQUESTS then CW.StopBatch("Targeted scan request limit reached; nothing posted."); return end
    if not more then
        batch.keys, batch.requested = {}, {}
        for i = batch.chunkStart, math.min(#batch.entries, batch.chunkStart+CHUNK_SIZE-1) do
            local id = batch.entries[i].id
            batch.keys[#batch.keys+1] = C_AuctionHouse.MakeItemKey(id, 0, 0, 0)
            batch.requested[id] = true
        end
    end
    CW.AHOperation = "batch"
    batch.requests = batch.requests + 1
    batch.waiting, batch.more, batch.deadline = true, nil, GetTime()+30
    local ok, err
    if more then ok, err = CW.AHRequest("RequestMoreBrowseResults")
    else ok, err = CW.AHRequest("SearchForItemKeys", batch.keys, {}) end
    if not ok then CW.StopBatch("Targeted summary scan unavailable: " .. tostring(err)); return end
    notice = "Checking AH-marked items… " .. math.min(batch.chunkStart-1, #batch.entries) .. "/" .. #batch.entries
end

local function receive()
    local full, rows = C_AuctionHouse.HasFullBrowseResults(), C_AuctionHouse.GetBrowseResults()
    if type(full) ~= "boolean" or type(rows) ~= "table" or #rows > CHUNK_SIZE then
        error("Targeted summary coverage unavailable")
    end
    if not full and #rows == 0 then return end
    batch.waiting = false
    if not full then batch.more = true; return end
    local seen = {}
    for _, row in ipairs(rows) do
        local key = row.itemKey
        if type(key) ~= "table" or not batch.requested[key.itemID]
            or (key.itemSuffix or 0) ~= 0 or (key.battlePetSpeciesID or 0) ~= 0
            or seen[key.itemID] or type(row.totalQuantity) ~= "number"
            or row.totalQuantity < 0 or row.totalQuantity % 1 ~= 0
            or type(row.minPrice) ~= "number" or row.minPrice < 0 or row.minPrice % 1 ~= 0 then
            error("Ambiguous or incomplete targeted summaries")
        end
        seen[key.itemID] = true
        batch.observations[key.itemID] = {minimum=row.minPrice, units=row.totalQuantity, at=GetTime()}
    end
    CW.AHOperation = nil
    batch.chunkStart = batch.chunkStart + CHUNK_SIZE
    if batch.chunkStart > #batch.entries then
        batch.phase, batch.index = "posting", 1
        notice = "Targeted check complete. Posting eligible items…"
    else batch.more = false end
end

local function nextReview()
    local entry = batch.entries[batch.index]
    if not entry then
        local completed, skipped = batch.completed, batch.skipped
        CW.StopBatch("Batch complete: " .. completed .. " posted · " .. skipped .. " skipped. Unfinished quantities remain marked.")
        return
    end
    local intent = CW.SaleIntent(entry.id)
    if not intent or intent.destination ~= "AH" or intent.quantity ~= entry.intended
        or CW.IntentRevision(entry.id) ~= entry.intentRevision then
        CW.StopBatch("Marked quantities changed; start a fresh batch."); return
    end
    local observation = batch.observations[entry.id]
    if observation and GetTime()-observation.at > FRESH_SECONDS then
        CW.StopBatch("Targeted prices are over 60 seconds old; start a fresh batch."); return
    end
    if not observation or not CW.IsPositiveWhole(observation.minimum) then
        skip(entry, "No fresh lowest buyout"); return
    end
    if observation.units < batch.minimum then
        skip(entry, "Below minimum supply: " .. observation.units .. " / " .. batch.minimum); return
    end
    if not CW.HoldingsSettled() then return end
    local item = CW.AvailableItem(entry.id)
    if not item then skip(entry, "Not in bags"); return end
    if not CW.IsPositiveWhole(entry.quantity) then skip(entry, "No reviewed eligible quantity"); return end
    if type(item.sell) ~= "number" or item.sell < 0 or item.sell % 1 ~= 0 then
        skip(entry, "Vendor value unavailable"); return
    end
    local gross = observation.minimum * entry.quantity
    if math.floor(gross * 95 / 100) <= item.sell * entry.quantity then
        skip(entry, "AH after 5% cut does not beat vendor"); return
    end
    local review = CW.PrepareReview(entry.id, intent, entry.quantity, observation.minimum, entry.duration)
    if review.deposit ~= entry.deposit then
        CW.StopBatch("Deposit changed; review and start a fresh batch."); return
    end
    if #review.stacks ~= #entry.stacks then
        CW.StopBatch("Source stacks changed; review and start a fresh batch."); return
    end
    for index, source in ipairs(review.stacks) do
        local before = entry.stacks[index]
        if source.bag ~= before.bag or source.slot ~= before.slot or source.count ~= before.count or source.link ~= before.link then
            CW.StopBatch("Source stacks changed; review and start a fresh batch."); return
        end
    end
    if not review.ready or entry.quantity > review.eligible then
        skip(entry, review.reason or "Reviewed quantity no longer available"); return
    end
    if CW.PostingReason() then return end
    return review
end

-- Native calls remain outside pcall and rendering, like the verified individual
-- XML posting path. If blocked, the existing durable ledger prevents retries.
local function post(review)
    batch.inFlight = review.id
    batch.postStarted = GetTime()
    reasons[review.id] = "Awaiting confirmation"
    dispatchReview = review
    CW.PostReviewedItem(review)
    dispatchReview = nil
    local _, pending = CW.PostingNotice()
    if not pending then CW.StopBatch("Posting terms changed before dispatch; review and start again.") end
end

function CW.BatchPostConfirmed(id)
    if not batch or batch.inFlight ~= id then return end
    reasons[id] = "Posted"
    batch.inFlight, batch.postStarted = nil, nil
    batch.completed, batch.index = batch.completed+1, batch.index+1
end

function CW.BatchClick()
    if batch then
        if hardwareRequired and batch.phase == "posting" and not batch.inFlight then
            local review = nextReview()
            if review then post(review) end
        end
        return
    end
    local _, pending = CW.PostingNotice()
    if pending then return end
    if type(C_AuctionHouse.SearchForItemKeys) ~= "function" then
        notice = "Targeted summary queries are unavailable on this client."; changed(); return
    end
    local entries = CW.BatchReviewEntries()
    if #entries == 0 or #entries > MAX_KEYS then
        notice = "Mark between 1 and " .. MAX_KEYS .. " AH items before starting."; changed(); return
    end
    CW.CloseListings()
    reasons = {}
    batch = {entries=entries, minimum=CW.MinimumListedUnits(), phase="scan", chunkStart=1,
        observations={}, requests=0, more=false, started=GetTime(), completed=0, skipped=0}
    notice = "Waiting to check AH-marked items…"
    changed()
end

function CW.RenderBatch()
    if CW.batchButton then
        local _, pending = CW.PostingNotice()
        CW.batchButton:SetText(batch and (hardwareRequired and batch.phase == "posting" and not batch.inFlight
            and "Continue posting" or (batch.phase == "scan" and "Checking…" or "Posting…")) or "Post all")
        CW.batchButton:SetEnabled(not pending and (not batch or hardwareRequired and batch.phase == "posting"))
    end
    if CW.RenderScanButton then CW.RenderScanButton() end
    if minimumInput then minimumInput:SetEnabled(not batch) end
end

function CW.SetupBatchControls(parent)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOPLEFT", 12, -12); label:SetText("Min listed units")
    minimumInput = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    minimumInput:SetSize(48, 22); minimumInput:SetPoint("TOPLEFT", 110, -6)
    minimumInput:SetAutoFocus(false); minimumInput:SetNumeric(true); minimumInput:SetMaxLetters(10)
    minimumInput:SetText(tostring(CW.MinimumListedUnits()))
    local function save(self)
        local value = tonumber(self:GetText())
        if not batch and CW.IsPositiveWhole(value) and type(CopperwiseDB) == "table" then
            CopperwiseDB.minimumListedUnits = value
        end
        self:SetText(tostring(CW.MinimumListedUnits())); self:ClearFocus()
    end
    minimumInput:SetScript("OnEnterPressed", save)
    minimumInput:SetScript("OnEditFocusLost", save)
    minimumInput:SetScript("OnEscapePressed", function(self)
        self:SetText(tostring(CW.MinimumListedUnits())); self:ClearFocus()
    end)
end

frame:SetScript("OnUpdate", function()
    if not batch then return end
    local review
    local ok, err = pcall(function()
        if batch.phase == "scan" then
            if GetTime()-batch.started > 180 or batch.waiting and GetTime() > batch.deadline then
                CW.StopBatch("Targeted scan timed out; nothing posted.")
            elseif batch.more ~= nil then request(batch.more) end
        elseif batch.inFlight then
            local text, pending = CW.PostingNotice()
            local _, ledger = CW.PendingPostDetails()
            notice = text or "Waiting for confirmed posting…"
            if type(ledger) == "table" and ledger.conflict then
                CW.StopBatch(text or "Posting paused; reconcile the pending outcome.")
            elseif not pending or GetTime()-batch.postStarted > 30 then
                CW.StopBatch("Posting outcome is uncertain; reconcile before continuing.")
            end
        elseif GetTime()-batch.started > 300 then
            CW.StopBatch("Batch timed out; start a fresh batch.")
        else
            review = nextReview()
            if batch then notice = hardwareRequired and "Click Continue posting for the next eligible item."
                or ("Posting " .. batch.index .. "/" .. #batch.entries .. " · " .. batch.skipped .. " skipped") end
        end
    end)
    if not ok then CW.StopBatch("Batch stopped: " .. tostring(err)) end
    if review and batch and not hardwareRequired then post(review) end
    changed()
end)

frame:SetScript("OnEvent", function(_, event, addon)
    if event == "AUCTION_HOUSE_CLOSED" then CW.StopBatch("Auction house closed; batch stopped.")
    elseif (event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN") and addon == "Copperwise" then
        hardwareRequired = true
        CW.StopBatch("Client blocked automatic posting. Reconcile, then restart; subsequent posts use Continue posting.")
    elseif batch and batch.waiting and (event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED"
        or event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED") then
        local ok, err = pcall(receive)
        if not ok then CW.StopBatch("Targeted scan failed: " .. tostring(err)) end
    elseif batch and (event == "AUCTION_HOUSE_BROWSE_FAILURE" or event == "AUCTION_HOUSE_SHOW_ERROR"
        or event == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" or event == "AUCTION_MULTISELL_FAILURE") then
        CW.StopBatch("Native AH error; unfinished intent retained. Reconcile any pending post.")
    end
end)
for _, event in ipairs({"AUCTION_HOUSE_CLOSED", "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
    "AUCTION_HOUSE_BROWSE_RESULTS_ADDED", "AUCTION_HOUSE_BROWSE_FAILURE", "AUCTION_HOUSE_SHOW_ERROR",
    "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED", "AUCTION_MULTISELL_FAILURE",
    "ADDON_ACTION_BLOCKED", "ADDON_ACTION_FORBIDDEN"}) do pcall(frame.RegisterEvent, frame, event) end
