local frame = CreateFrame("Frame")
local session, panel, output, tab, active, result
local houseOpen, ownRequest, hooksReady, reopenRequired = false, false, false, false
local lastTraffic = 0
local samples = {{2447, "Peacebloom"}, {2770, "Copper Ore"}, {2835, "Rough Stone"}}
local selected = samples[1]
local MAX_REQUESTS, MAX_ROWS, TIMEOUT, QUIET = 3, 500, 15, 2
local mode = {"CopperwiseAuctionProbePanel"}
local observed = {}

local function value(v)
    if v == nil then return "unavailable" end
    return tostring(v)
end

local function record(message)
    local line = string.sub("t=" .. time() .. " " .. message, 1, 900)
    print("Copperwise AH probe: " .. line)
    if session then
        table.insert(session.events, line)
        while #session.events > 200 do table.remove(session.events, 1) end
    end
end

local function api(name, ...)
    local fn = C_AuctionHouse and C_AuctionHouse[name]
    if type(fn) ~= "function" then error("C_AuctionHouse." .. name .. " unavailable") end
    return fn(...)
end

local function sameKey(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return false end
    for _, field in ipairs({"itemID", "itemLevel", "itemSuffix", "battlePetSpeciesID"}) do
        if (a[field] or 0) ~= (b[field] or 0) then return false end
    end
    return true
end

local function render()
    if not output then return end
    if not result then
        output:SetText("Selected: " .. selected[2] .. " (" .. selected[1]
            .. ")\nScan starts a new observation.\n\nLocal scan only; imported history is separate.\nWait for other searches to finish before scanning.")
        return
    end
    local r = result
    local units = r.units and tostring(r.units) or "unavailable"
    local price = r.minimum and string.format("%.4f copper/unit", r.minimum) or "unavailable"
    output:SetText("Item: " .. r.itemID .. " (" .. r.name .. ")\nState: " .. r.state
        .. "\n" .. r.reason .. "\n\nRequests: " .. r.requests .. "/" .. MAX_REQUESTS
        .. "   Rows covered: " .. value(r.rows) .. "\nCovered stock: " .. units
        .. " units\nLowest covered buyout: " .. price
        .. "\nBid-only units: " .. value(r.bidOnly) .. "\nFull selected-key results: " .. value(r.full)
        .. "\nStarted: " .. date("%Y-%m-%d %H:%M:%S %Z", r.started)
        .. "\nResults observed: " .. (r.observedAt and date("%Y-%m-%d %H:%M:%S %Z", r.observedAt) or "not yet")
        .. "\n\nCoverage is this item key at this AH only.\nPartial results are not market totals.\nNo offline history, purchases or posting.")
end

local function finish(state, reason)
    active = nil
    if result then
        result.state, result.reason = state, reason
        record("state=" .. state .. " item=" .. result.itemID .. " requests=" .. result.requests
            .. " rows=" .. value(result.rows) .. " covered-units=" .. value(result.units)
            .. " lowest-covered-copper/unit=" .. value(result.minimum)
            .. " bid-only-units=" .. value(result.bidOnly) .. " full=" .. value(result.full)
            .. " observedAt=" .. value(result.observedAt) .. " reason=" .. reason)
    end
    render()
end

local function fail(reason)
    reopenRequired = true
    finish("incomplete", reason)
end

local function guard(fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            if active then fail(tostring(err)) else record("refused/error: " .. tostring(err)) end
        end
    end
end

local function externalRequest(name)
    lastTraffic = GetTime()
    if not ownRequest and (active or (result and result.state == "partial")) then
        -- Results are shared caches: a competing request invalidates attribution.
        result.full = false
        reopenRequired = true
        finish("interrupted", "Another AH request (" .. name .. "); do not treat cached results as this scan.")
    end
end

local function setupHooks()
    if hooksReady then return end
    for _, name in ipairs({"SendSearchQuery", "SendSellSearchQuery", "SendBrowseQuery",
        "SearchForFavorites", "RefreshItemSearchResults", "RefreshCommoditySearchResults",
        "RequestMoreItemSearchResults", "RequestMoreCommoditySearchResults",
        "RequestMoreBrowseResults", "ReplicateItems", "QueryOwnedAuctions", "QueryBids"}) do
        if C_AuctionHouse and type(C_AuctionHouse[name]) == "function" then
            local requestName = name
            hooksecurefunc(C_AuctionHouse, name, function() externalRequest(requestName) end)
        elseif name == "SendSearchQuery" then error("modern native AH search unavailable") end
    end
    hooksReady = true
end

local function ready()
    if not houseOpen or not panel or not panel:IsShown() then error("open the Copperwise AH tab first") end
    if reopenRequired then error("close and reopen AH before another scan; prior response attribution is uncertain") end
    if not hooksReady then error("query observation hooks unavailable") end
    if not observed.AUCTION_HOUSE_CLOSED or not observed.ITEM_SEARCH_RESULTS_UPDATED
        or not observed.COMMODITY_SEARCH_RESULTS_UPDATED then error("required AH events unavailable") end
    if GetTime() - lastTraffic < QUIET then error("AH recently active; wait two quiet seconds") end
    if not api("IsThrottledMessageSystemReady") then error("AH throttled/busy; retry manually when ready") end
    -- Optional read-only diagnostic; never enqueue, abort or call Auctionator APIs.
    local queue = Auctionator and Auctionator.AH and Auctionator.AH.Queue
    if queue and type(queue.queue) == "table" and #queue.queue > 0 then
        error("Auctionator has queued work; let it finish first")
    end
end

local function request(more)
    ready()
    local r = result
    if r.requests >= MAX_REQUESTS then error("three-request bound reached; results remain partial") end
    local name, argument = "SendSearchQuery", r.key
    if more then
        name = r.commodity and "RequestMoreCommoditySearchResults" or "RequestMoreItemSearchResults"
        argument = r.commodity and r.itemID or r.key
    end
    r.requests = r.requests + 1
    r.state, r.reason = "waiting", "Waiting for matching results; cancel stops local collection."
    r.full = false
    active = {deadline=GetTime() + TIMEOUT, sentAt=GetTime()}
    ownRequest = true
    local ok, err
    if more then ok, err = pcall(api, name, argument)
    else ok, err = pcall(api, name, argument, {}, false) end
    ownRequest = false
    record("request=" .. name .. " item=" .. r.itemID .. " number=" .. r.requests
        .. " source=local-native-search started=" .. r.started)
    if not ok then fail(tostring(err)) end
    render()
end

local function start()
    if active then error("scan already waiting; cancel or wait") end
    ready()
    local key = api("MakeItemKey", selected[1], 0, 0, 0)
    local info = api("GetItemKeyInfo", key)
    if not info or type(info.isCommodity) ~= "boolean" then
        error("sample metadata uncached; inspect it in native browse, wait, then retry")
    end
    result = {itemID=selected[1], name=info.itemName or selected[2], key=key,
        commodity=info.isCommodity, started=time(), requests=0, state="starting", reason=""}
    record("market-context realm=" .. value(GetRealmName and GetRealmName())
        .. " faction=" .. value(UnitFactionGroup("player"))
        .. " region=" .. value(GetCurrentRegion and GetCurrentRegion())
        .. "; context only, upstream market mapping unverified")
    record("key item=" .. key.itemID .. " level=" .. value(key.itemLevel) .. " suffix="
        .. value(key.itemSuffix) .. " pet=" .. value(key.battlePetSpeciesID)
        .. " commodity=" .. tostring(result.commodity))
    request(false)
end

local function more()
    if active then error("already waiting for results") end
    if not result or result.state ~= "partial" or result.requests >= MAX_REQUESTS then
        error("More is only available after partial results and within the request bound")
    end
    request(true)
end

local function readResults()
    local r = result
    if not api("HasSearchResults", r.key) then return end
    local full, count
    if r.commodity then
        full = api("HasFullCommoditySearchResults", r.itemID)
        count = api("GetNumCommoditySearchResults", r.itemID)
    else
        full = api("HasFullItemSearchResults", r.key)
        count = api("GetNumItemSearchResults", r.key)
    end
    if type(full) ~= "boolean" or type(count) ~= "number" or count < 0 or count ~= math.floor(count) then
        error("result count/completeness unavailable")
    end
    -- An empty partial update can be a loading signal, not an empty market.
    if count == 0 and not full then return end
    local units, bidOnly, minimum, seen = 0, 0, nil, {}
    local covered = math.min(count, MAX_ROWS)
    for index = 1, covered do
        local row
        if r.commodity then row = api("GetCommoditySearchResultInfo", r.itemID, index)
        else row = api("GetItemSearchResultInfo", r.key, index) end
        if not row or type(row.quantity) ~= "number" or row.quantity <= 0
            or row.quantity ~= math.floor(row.quantity) or row.auctionID == nil then
            error("row " .. index .. " incomplete; no complete stock/price summary")
        end
        if seen[row.auctionID] then error("duplicate auction ID; coverage unresolved") end
        seen[row.auctionID] = true
        if (r.commodity and row.itemID ~= r.itemID) or (not r.commodity and not sameKey(row.itemKey, r.key)) then
            error("row identity differs from requested key")
        end
        local price
        if r.commodity then
            if type(row.unitPrice) ~= "number" or row.unitPrice <= 0 then error("commodity price unavailable") end
            price = row.unitPrice
        else
            if row.buyoutAmount ~= nil and (type(row.buyoutAmount) ~= "number" or row.buyoutAmount < 0) then
                error("invalid buyout amount")
            end
            if row.buyoutAmount and row.buyoutAmount > 0 then price = row.buyoutAmount / row.quantity
            elseif type(row.minBid) == "number" and row.minBid > 0 then bidOnly = bidOnly + row.quantity
            else error("neither valid buyout nor bid-only metadata") end
        end
        units = units + row.quantity
        if price and (not minimum or price < minimum) then minimum = price end
        if index <= 5 then
            record("row=" .. index .. " auction=" .. row.auctionID .. " item=" .. r.itemID
                .. " quantity=" .. row.quantity .. " raw-unitPrice=" .. value(row.unitPrice)
                .. " raw-buyoutAmount=" .. value(row.buyoutAmount) .. " minBid=" .. value(row.minBid)
                .. " normalized-copper/unit=" .. value(price))
        end
    end
    -- Replace the previous cumulative cache snapshot; never add updates together.
    r.rows, r.units, r.bidOnly, r.minimum = covered, units, bidOnly, minimum
    r.observedAt, r.full = time(), full and count <= MAX_ROWS
    record("result-update api-full=" .. tostring(full) .. " cache-rows=" .. count
        .. " processed=" .. covered .. " elapsed=" .. string.format("%.2f", GetTime() - (active.sentAt or GetTime())))
    if r.full then
        finish(count == 0 and "empty" or "complete", count == 0 and "Observed empty selected-key results; no asking price."
            or "Full selected-key results received; this is not a full-market scan or atomic snapshot.")
    else
        finish("partial", count > MAX_ROWS and "500-row processing bound reached; stock/price cover only these rows."
            or "Partial selected-key results; use More after cooldown, at most three requests total.")
    end
end

local function cancel(reason)
    if active or (result and result.state == "partial") then
        if active then reopenRequired = true end
        result.full = false
        finish("cancelled", reason or "Stopped locally; an already sent server request cannot be recalled.")
    end
end

local function button(parent, text, x, y, action)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(126, 24)
    b:SetPoint("TOPLEFT", x, y)
    b:SetText(text)
    b:SetScript("OnClick", guard(action))
    return b
end

local function setupPanel()
    if panel then return end
    local ah = AuctionHouseFrame
    if not ah or not ah.SetDisplayMode or not ah.Tabs or not AuctionHouseFrameDisplayMode then
        error("native modern AH frame unavailable; no automatic legacy fallback")
    end
    setupHooks()
    panel = CreateFrame("Frame", nil, ah)
    panel:SetPoint("TOPLEFT", 20, -65)
    panel:SetPoint("BOTTOMRIGHT", -20, 35)
    panel:Hide()
    ah.CopperwiseAuctionProbePanel = panel
    AuctionHouseFrameDisplayMode.CopperwiseProbe = mode
    output = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    output:SetPoint("TOPLEFT", 12, -95)
    output:SetPoint("BOTTOMRIGHT", -12, 10)
    output:SetJustifyH("LEFT")
    output:SetJustifyV("TOP")
    for index, sample in ipairs(samples) do
        local choice = sample
        button(panel, sample[2], 12 + (index-1)*140, -10, function()
            if active then error("wait or cancel before selecting a different sample") end
            cancel("Sample selection changed; previous partial observation stopped.")
            selected = choice
            result = nil
            record("selected=" .. selected[1] .. "; Scan starts a new observation")
            render()
        end)
    end
    button(panel, "Scan sample", 12, -48, start)
    button(panel, "More results", 152, -48, more)
    button(panel, "Cancel", 292, -48, function() cancel() end)
    -- Independent native display-mode tab, positioned above the normal tab row
    -- to avoid colliding with Auctionator/LibAHTab's appended tabs.
    tab = CreateFrame("Button", "CopperwiseAuctionProbeTab", ah, "AuctionHouseFrameDisplayModeTabTemplate")
    tab:SetText("Copperwise probe")
    PanelTemplates_TabResize(tab, 20, nil, 70)
    tab:SetPoint("BOTTOMRIGHT", ah, "TOPRIGHT", -35, 0)
    tab:SetScript("OnClick", guard(function()
        ah:SetDisplayMode(mode)
        ah:SetTitle("Copperwise — local scan probe")
        PanelTemplates_SelectTab(tab)
    end))
    hooksecurefunc(ah, "SetDisplayMode", function(_, current)
        if current ~= mode then
            panel:Hide()
            PanelTemplates_DeselectTab(tab)
            cancel("Left Copperwise tab; local collection stopped.")
        end
    end)
    panel:SetScript("OnHide", function() cancel("Copperwise surface hidden; local collection stopped.") end)
    render()
    record("native Copperwise tab created; scan remains user initiated")
end

SLASH_COPPERWISEAUCTIONPROBE1 = "/cwah"
SlashCmdList.COPPERWISEAUCTIONPROBE = guard(function(message)
    local command, argument = (message or ""):match("^(%S*)%s*(.-)%s*$")
    if command == "note" then record("operator-note=" .. argument)
    elseif command == "cancel" then cancel()
    elseif command == "scan" then start()
    elseif command == "more" then more()
    elseif command == "status" then
        record("AH-open=" .. tostring(houseOpen) .. " hooks=" .. tostring(hooksReady)
            .. " throttle-ready=" .. value(C_AuctionHouse and C_AuctionHouse.IsThrottledMessageSystemReady
                and C_AuctionHouse.IsThrottledMessageSystemReady()) .. " selected=" .. selected[1])
        if result then record("last-state=" .. result.state .. " reason=" .. result.reason) end
        render()
    elseif command == "" then
        if not houseOpen then error("visit an auctioneer first") end
        setupPanel()
        tab:Click()
    else error("use /cwah, status, scan, more, cancel, note <outcome>") end
end)

frame:SetScript("OnUpdate", guard(function()
    if active and GetTime() >= active.deadline then fail("Timed out waiting for attributable, usable results; not observed empty.") end
end))

frame:SetScript("OnEvent", guard(function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        if type(CopperwiseAuctionEvidence) ~= "table" then CopperwiseAuctionEvidence = {} end
        session = {events={}}
        table.insert(CopperwiseAuctionEvidence, session)
        while #CopperwiseAuctionEvidence > 5 do table.remove(CopperwiseAuctionEvidence, 1) end
        local version, build, _, interface = GetBuildInfo()
        local addon = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
        record("client=" .. value(version) .. " build=" .. value(build) .. " interface=" .. value(interface)
            .. " platform=" .. (IsMacClient and IsMacClient() and "macOS" or "other/unknown")
            .. " Auctionator-loaded=" .. value(addon and addon("Auctionator")))
        record("read-only native scan; visit auctioneer then /cwah; history import untouched")
        setupHooks()
    elseif event == "AUCTION_HOUSE_SHOW" then
        houseOpen = true
        lastTraffic = GetTime()
        setupPanel()
    elseif event == "AUCTION_HOUSE_CLOSED" then
        houseOpen = false
        cancel("Auction house closed; local collection stopped.")
        reopenRequired = false
    elseif active then
        if event == "ITEM_SEARCH_RESULTS_UPDATED" or event == "ITEM_SEARCH_RESULTS_ADDED" then
            local key = ...
            if not result.commodity and sameKey(key, result.key) then readResults() end
        elseif event == "COMMODITY_SEARCH_RESULTS_UPDATED" or event == "COMMODITY_SEARCH_RESULTS_ADDED" then
            local itemID = ...
            if result.commodity and itemID == result.itemID then readResults() end
        elseif event == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" or event == "AUCTION_HOUSE_BROWSE_FAILURE"
            or event == "AUCTION_HOUSE_SHOW_ERROR" or event == "UI_ERROR_MESSAGE" then
            local code = ...
            fail(event .. " code=" .. value(code) .. "; scope/result uncertain")
        else record("event=" .. event .. "; waiting within deadline") end
    end
end))

for _, event in ipairs({"PLAYER_LOGIN", "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED",
    "ITEM_SEARCH_RESULTS_UPDATED", "ITEM_SEARCH_RESULTS_ADDED", "COMMODITY_SEARCH_RESULTS_UPDATED",
    "COMMODITY_SEARCH_RESULTS_ADDED", "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
    "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED", "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
    "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED", "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
    "AUCTION_HOUSE_BROWSE_FAILURE", "AUCTION_HOUSE_SHOW_ERROR", "UI_ERROR_MESSAGE"}) do
    local ok, err = pcall(frame.RegisterEvent, frame, event)
    observed[event] = ok
    if not ok then record("unsupported event=" .. event .. " " .. tostring(err)) end
end
