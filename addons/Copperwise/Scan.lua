local CW = Copperwise
local frame = CreateFrame("Frame")
local active, attempt, panel, output, scanButton, cancelButton
local houseOpen, ownRequest, hooksReady, reopenRequired = false, false, false, false
local lastTraffic, externalPending = 0, {}
local mode = {"CopperwiseMarketPanel"}
local MAX_REQUESTS, MAX_ROWS, RESPONSE_TIMEOUT, TOTAL_TIMEOUT = 2000, 100000, 30, 180
local responseEvents = {
    SendSearchQuery="search", SendSellSearchQuery="search",
    RefreshItemSearchResults="search", RefreshCommoditySearchResults="search",
    RequestMoreItemSearchResults="search", RequestMoreCommoditySearchResults="search",
    SendBrowseQuery="browse", SearchForFavorites="browse", RequestMoreBrowseResults="browse",
    QueryOwnedAuctions="owned", QueryBids="bids", ReplicateItems="replicate",
}

local function market()
    local realm, faction = GetRealmName(), UnitFactionGroup("player")
    local region = GetCurrentRegion and GetCurrentRegion()
    if not realm or not faction or not region then return nil end
    return region .. ":" .. #realm .. ":" .. realm .. ":" .. faction,
        realm .. " / " .. faction .. " / region " .. region
end

local function cache()
    local key = market()
    return key and CopperwiseDB and CopperwiseDB.markets and CopperwiseDB.markets[key]
end

-- Inventory only compares native commodities; full-market collection also retains
-- other native keys, without collapsing equipment variants into a bag item ID.
function CW.ObservationFor(id)
    local snapshot = cache()
    if not snapshot then return nil end
    local nativeKey = C_AuctionHouse.MakeItemKey(id, 0, 0, 0)
    local info = C_AuctionHouse.GetItemKeyInfo(nativeKey)
    if not info or info.isCommodity ~= true then return nil end
    local found
    for _, row in pairs(snapshot.items) do
        if row.key.itemID == id then
            if row.ambiguous or found or (row.key.itemSuffix or 0) ~= 0 or (row.key.battlePetSpeciesID or 0) ~= 0 then
                return nil -- ambiguous comparability must not manufacture an estimate
            end
            found = row
        end
    end
    return {minimum=found and found.minimum, units=found and found.units or 0,
        observedAt=snapshot.observedAt, context=snapshot.context, full=true,
        empty=found == nil, rows=snapshot.count}
end

local function render()
    CW.attempt = attempt
    if CW.Render then CW.Render() end
    if not output then return end
    scanButton:SetEnabled(active == nil)
    cancelButton:SetEnabled(active ~= nil)
    local text = "Full auction-house scan (summary mode)\nCollect minimum asking values and available supply across the market.\n"
        .. "Inventory uses the retained results to review owned commodities.\n\n"
    if attempt then
        text = text .. "Latest scan: " .. attempt.state .. "\n" .. attempt.reason
            .. "\nRequests: " .. attempt.requests .. "; item summaries processed: " .. attempt.count
            .. "\nMarket: " .. attempt.context
            .. "\nStarted: " .. date("%Y-%m-%d %H:%M:%S %Z", attempt.started)
    else text = text .. "No scan attempted this session." end
    local snapshot = cache()
    if snapshot then
        text = text .. "\n\nLast complete full scan: " .. date("%Y-%m-%d %H:%M:%S %Z", snapshot.observedAt)
            .. "\n" .. snapshot.count .. " item summaries; " .. snapshot.context
            .. "\nRepeated keys: " .. (snapshot.duplicates or 0)
            .. "; conflicting keys withheld: " .. (snapshot.ambiguous or 0)
    else text = text .. "\n\nNo complete scan retained for this market." end
    if CW.notice then text = text .. "\n\n" .. CW.notice end
    output:SetText(text .. "\n\nAsking values are not completed sales.\nKeep this tab open until scanning finishes.\nNo posting is performed by a scan.")
end

local function finish(state, reason)
    if active and active.waiting then reopenRequired = true end
    active = nil
    if attempt then attempt.state, attempt.reason = state, reason end
    render()
end

local function guard(fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            if active then finish("failed", tostring(err))
            else CW.notice = tostring(err); render() end
        end
    end
end

local function requestToken(kind, argument)
    local id = kind == "search" and (type(argument) == "table" and argument.itemID or argument) or kind
    return kind .. ":" .. tostring(id)
end

local function externalRequest(name, argument)
    lastTraffic = GetTime()
    if ownRequest then return end
    local kind = responseEvents[name]
    local token = requestToken(kind, argument)
    if externalPending[token] then externalPending.uncertain = true end
    externalPending[token] = true
    if active then
        reopenRequired = true
        finish("cancelled", "Other AH activity interrupted collection; close/reopen AH before retrying.")
    end
end

local function setupHooks()
    if hooksReady then return end
    if not C_AuctionHouse or type(C_AuctionHouse.SendBrowseQuery) ~= "function" then
        error("native summary-mode auction queries unavailable")
    end
    for name in pairs(responseEvents) do
        if type(C_AuctionHouse[name]) == "function" then
            local requestName = name
            hooksecurefunc(C_AuctionHouse, name, function(argument) externalRequest(requestName, argument) end)
        end
    end
    hooksReady = true
end

local function queueBusy()
    local queue = Auctionator and Auctionator.AH and Auctionator.AH.Queue
    return queue and type(queue.queue) == "table" and #queue.queue > 0
end

local function dispatch(more)
    if not active then return end
    if GetTime() - lastTraffic < 0.2 or not C_AuctionHouse.IsThrottledMessageSystemReady() then
        attempt.state, attempt.reason = "throttled", "Waiting for native query readiness."
        return
    end
    if queueBusy() or next(externalPending) then
        finish("cancelled", "Other AH work is pending; retry after it finishes.")
        return
    end
    if attempt.requests >= MAX_REQUESTS then
        finish("partial", "Request bound reached; prior complete scan preserved.")
        return
    end
    attempt.requests = attempt.requests + 1
    attempt.state, attempt.reason = "waiting", "Waiting for the next market summary batch."
    active.waiting, active.deadline, active.nextPage = true, GetTime() + RESPONSE_TIMEOUT, nil
    ownRequest = true
    local ok, err
    if more then ok, err = pcall(C_AuctionHouse.RequestMoreBrowseResults)
    else ok, err = pcall(C_AuctionHouse.SendBrowseQuery,
        {searchString="", sorts={}, filters={}, itemClassFilters={}}) end
    ownRequest = false
    if not ok then finish("failed", tostring(err)) end
    render()
end

local function start()
    CW.notice = nil
    if active then error("scan already in progress") end
    if not houseOpen or not panel or not panel:IsShown() then error("open the Copperwise AH tab first") end
    if reopenRequired then error("close/reopen AH before scanning; previous response attribution is uncertain") end
    setupHooks()
    if next(externalPending) or queueBusy() then error("other AH work is outstanding; wait or close/reopen AH") end
    if GetTime() - lastTraffic < 2 then error("wait for two quiet seconds after other AH activity") end
    local key, context = market()
    if not key then error("market context unavailable") end
    attempt = {state="ready", reason="Starting full market summary scan.", requests=0, count=0,
        started=time(), context=context}
    active = {market=key, context=context, started=GetTime(), nextPage=false}
    dispatch(false)
end

local function receive()
    if not active or not active.waiting then return end
    local rows = C_AuctionHouse.GetBrowseResults()
    local full = C_AuctionHouse.HasFullBrowseResults()
    if type(rows) ~= "table" or type(full) ~= "boolean" then error("browse coverage unavailable") end
    if #rows == 0 and not full then return end
    active.waiting = false
    if #rows > MAX_ROWS then finish("partial", "Market exceeds the processing bound; prior scan preserved."); return end
    -- Each response is a cumulative native cache snapshot, never an additive delta.
    active.batch = {rows=rows, full=full, index=1, items={}, zeros={}, count=0, duplicates=0, ambiguous=0}
    attempt.state, attempt.reason = "processing", "Processing market summaries."
end

local function process()
    local batch = active.batch
    for index = batch.index, math.min(batch.index + 249, #batch.rows) do
        local row = batch.rows[index]
        local key = row and row.itemKey
        if not row or type(row.totalQuantity) ~= "number" or row.totalQuantity < 0
            or row.totalQuantity ~= math.floor(row.totalQuantity) then
            error("Incomplete supply metadata; prior complete scan preserved.")
        end
        -- Native browse caches can retain a row after its last listing disappears.
        if row.totalQuantity > 0 then
            if type(key) ~= "table" or type(key.itemID) ~= "number" or key.itemID <= 0
                or type(row.minPrice) ~= "number" or row.minPrice < 0 then
                error("Incomplete market summary; prior complete scan preserved.")
            end
            local identity = key.itemID .. ":" .. (key.itemLevel or 0) .. ":" .. (key.itemSuffix or 0)
                .. ":" .. (key.battlePetSpeciesID or 0)
            local previous = batch.items[identity]
            local minimum = row.minPrice > 0 and row.minPrice or nil
            if previous then
                -- A repeated summary is not another independent pool of supply.
                batch.duplicates = batch.duplicates + 1
                if not previous.ambiguous and (previous.units ~= row.totalQuantity or previous.minimum ~= minimum) then
                    previous.ambiguous = true
                    batch.ambiguous = batch.ambiguous + 1
                end
            else
                local ambiguous = batch.zeros[identity] == true
                if ambiguous then
                    batch.duplicates = batch.duplicates + 1
                    batch.ambiguous = batch.ambiguous + 1
                end
                batch.items[identity] = {key=key, units=row.totalQuantity, minimum=minimum, ambiguous=ambiguous}
                batch.count = batch.count + 1
            end
        elseif type(key) == "table" and type(key.itemID) == "number" and key.itemID > 0 then
            local identity = key.itemID .. ":" .. (key.itemLevel or 0) .. ":" .. (key.itemSuffix or 0)
                .. ":" .. (key.battlePetSpeciesID or 0)
            local previous = batch.items[identity]
            if previous or batch.zeros[identity] then batch.duplicates = batch.duplicates + 1 end
            if previous and not previous.ambiguous then
                previous.ambiguous = true
                batch.ambiguous = batch.ambiguous + 1
            end
            batch.zeros[identity] = true
        end
    end
    batch.index = batch.index + 250
    attempt.count = batch.count
    if batch.index <= #batch.rows then return end
    active.batch = nil
    if batch.full then
        local version, build, _, interface = GetBuildInfo()
        local snapshot = {items=batch.items, count=batch.count, context=active.context,
            duplicates=batch.duplicates, ambiguous=batch.ambiguous,
            observedAt=time(), startedAt=attempt.started, source="native full browse summary", full=true,
            client={version=version, build=build, interface=interface}}
        CopperwiseDB.markets[active.market] = snapshot
        finish("complete", "Full market summary scan completed; " .. batch.count .. " item summaries retained.")
        print("Copperwise: Finished processing " .. batch.count .. " item summaries.")
    else
        active.nextPage = true
        attempt.state, attempt.reason = "partial", "More market summaries remain; continuing when native throttling permits."
    end
end

local function cancel(reason)
    if active then finish("cancelled", reason or "Scan cancelled; previous complete scan preserved.") end
end
CW.Scan, CW.Cancel = guard(start), cancel

local function setupPanel()
    if panel then return end
    local ah = AuctionHouseFrame
    if not ah or not ah.SetDisplayMode or not ah.Tabs or not AuctionHouseFrameDisplayMode then
        error("native modern AH frame unavailable")
    end
    panel = CreateFrame("Frame", nil, ah)
    panel:SetPoint("TOPLEFT", 20, -65)
    panel:SetPoint("BOTTOMRIGHT", -20, 35)
    panel:Hide()
    ah.CopperwiseMarketPanel = panel
    AuctionHouseFrameDisplayMode.CopperwiseMarket = mode
    local function button(label, x, action)
        local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        b:SetSize(180, 25); b:SetPoint("TOPLEFT", x, -10); b:SetText(label)
        b:SetScript("OnClick", guard(action))
        return b
    end
    scanButton = button("Full scan", 12, start)
    cancelButton = button("Cancel scan", 205, function() cancel() end)
    output = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    output:SetPoint("TOPLEFT", 12, -60); output:SetPoint("BOTTOMRIGHT", -12, 10)
    output:SetJustifyH("LEFT"); output:SetJustifyV("TOP")
    local tab = CreateFrame("Button", "CopperwiseMarketTab", ah, "AuctionHouseFrameDisplayModeTabTemplate")
    tab:SetText("Copperwise")
    PanelTemplates_TabResize(tab, 20, nil, 70)
    local previous = ah.Tabs[#ah.Tabs - 1] or ah.AuctionsTab
    -- LibAHTab uses a separate tab array. If its row already exists, append to it;
    -- if created later, its own root anchors after our newly registered native tab.
    local library = LibStub and LibStub:GetLibrary("LibAHTab-1-0", true)
    local libraryTabs = library and library.internalState and library.internalState.Tabs
    if libraryTabs and #libraryTabs > 0 then previous = libraryTabs[#libraryTabs] end
    tab:SetPoint("LEFT", previous, "RIGHT", -15, 0)
    tab.displayMode = mode
    tab:SetID(#ah.Tabs)
    ah.tabsForDisplayMode[mode] = #ah.Tabs
    PanelTemplates_SetNumTabs(ah, #ah.Tabs)
    PanelTemplates_DeselectTab(tab)
    tab:SetScript("OnClick", guard(function()
        ah:SetDisplayMode(mode)
        ah:SetTitle("Copperwise")
        PanelTemplates_SelectTab(tab)
    end))
    hooksecurefunc(ah, "SetDisplayMode", function(_, current)
        if current ~= mode then
            panel:Hide(); PanelTemplates_DeselectTab(tab)
            cancel("Left Copperwise AH tab; previous complete scan preserved.")
        end
    end)
    panel:SetScript("OnHide", function() cancel("Copperwise AH tab hidden; scan stopped.") end)
    render()
end

frame:SetScript("OnUpdate", guard(function()
    if not active then return end
    if GetTime() - active.started > TOTAL_TIMEOUT then
        finish("failed", "Full scan timed out; prior complete scan preserved.")
    elseif active.waiting and GetTime() > active.deadline then
        finish("failed", "Response timed out; close/reopen AH before another scan.")
    elseif active.batch then process()
    elseif active.nextPage ~= nil then dispatch(active.nextPage) end
    render()
end))

frame:SetScript("OnEvent", guard(function(_, event, argument)
    local kind
    if event == "COMMODITY_SEARCH_RESULTS_UPDATED" or event == "ITEM_SEARCH_RESULTS_UPDATED" then
        kind = "search"
    elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" or event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED" then
        kind = "browse"
    elseif event == "OWNED_AUCTIONS_UPDATED" then kind = "owned"
    elseif event == "BIDS_UPDATED" then kind = "bids"
    elseif event == "REPLICATE_ITEM_LIST_UPDATE" then kind = "replicate" end
    local token = kind and requestToken(kind, argument)
    if token and externalPending[token] then
        externalPending[token] = nil
        lastTraffic = GetTime()
    end
    if event == "PLAYER_LOGIN" then
        if type(CopperwiseDB) ~= "table" or CopperwiseDB.version ~= 1 then CopperwiseDB = {version=1, markets={}} end
        if type(CopperwiseDB.markets) ~= "table" then CopperwiseDB.markets = {} end
        setupHooks()
    elseif event == "AUCTION_HOUSE_SHOW" then
        houseOpen, lastTraffic = true, GetTime()
        setupPanel()
    elseif event == "AUCTION_HOUSE_CLOSED" then
        houseOpen = false
        cancel("Auction house closed; previous complete scan preserved.")
        reopenRequired, externalPending = false, {}
    elseif active and (event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" or event == "AUCTION_HOUSE_BROWSE_RESULTS_ADDED") then
        receive()
    elseif active and (event == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED"
        or event == "AUCTION_HOUSE_BROWSE_FAILURE" or event == "AUCTION_HOUSE_SHOW_ERROR") then
        finish("failed", event .. "; prior complete scan preserved.")
    end
    render()
end))

for _, event in ipairs({"PLAYER_LOGIN", "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED",
    "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", "AUCTION_HOUSE_BROWSE_RESULTS_ADDED",
    "COMMODITY_SEARCH_RESULTS_UPDATED", "ITEM_SEARCH_RESULTS_UPDATED", "OWNED_AUCTIONS_UPDATED",
    "BIDS_UPDATED", "REPLICATE_ITEM_LIST_UPDATE", "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
    "AUCTION_HOUSE_BROWSE_FAILURE", "AUCTION_HOUSE_SHOW_ERROR"}) do
    pcall(frame.RegisterEvent, frame, event)
end
