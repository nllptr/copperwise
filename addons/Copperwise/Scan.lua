local frame = CreateFrame("Frame")
local active, result
local houseOpen, ownRequest, hooksReady, reopenRequired = false, false, false, false
local lastTraffic = 0
local externalPending = {}
local responseEvents = {
    SendSearchQuery="search", SendSellSearchQuery="search",
    RefreshItemSearchResults="search", RefreshCommoditySearchResults="search",
    RequestMoreItemSearchResults="search", RequestMoreCommoditySearchResults="search",
    SendBrowseQuery="browse", SearchForFavorites="browse", RequestMoreBrowseResults="browse",
    QueryOwnedAuctions="owned", QueryBids="bids", ReplicateItems="replicate",
}
local MAX_REQUESTS, MAX_ROWS, TIMEOUT, QUIET = 3, 500, 15, 2
local observed = {}

local function value(v)
    if v == nil then return "unavailable" end
    return tostring(v)
end

local function record(message)
    Copperwise.lastDiagnostic = message
end

local function api(name, ...)
    local fn = C_AuctionHouse and C_AuctionHouse[name]
    if type(fn) ~= "function" then error("C_AuctionHouse." .. name .. " unavailable") end
    return fn(...)
end

local function render()
    Copperwise.attempt = result
    if Copperwise.Render then Copperwise.Render() end
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
    if active then reopenRequired = true end
    finish("failed", reason)
end

local function guard(fn, eventFailure)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            if active and eventFailure then fail(tostring(err)) else
                record("refused/error: " .. tostring(err))
                Copperwise.notice = tostring(err)
                render()
            end
        end
    end
end

local function externalRequest(name, argument)
    lastTraffic = GetTime()
    if not ownRequest then
        local kind = responseEvents[name]
        local id = kind == "search" and (type(argument) == "table" and argument.itemID or argument) or kind
        local token = tostring(kind) .. ":" .. tostring(id)
        if externalPending[token] then externalPending.uncertain = true end
        externalPending[token] = true
    end
    if not ownRequest and (active or (result and result.state == "partial")) then
        -- Results are shared caches: a competing request invalidates attribution.
        result.full = false
        if active or result.state == "partial" then reopenRequired = true end
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
            hooksecurefunc(C_AuctionHouse, name, function(argument) externalRequest(requestName, argument) end)
        elseif name == "SendSearchQuery" then error("modern native AH search unavailable") end
    end
    hooksReady = true
end

local function ready()
    if not houseOpen then error("visit an auctioneer first") end
    if reopenRequired then error("close and reopen AH before another scan; prior response attribution is uncertain") end
    if not hooksReady then error("query observation hooks unavailable") end
    if not observed.AUCTION_HOUSE_CLOSED or not observed.ITEM_SEARCH_RESULTS_UPDATED
        or not observed.COMMODITY_SEARCH_RESULTS_UPDATED then error("required AH events unavailable") end
    if next(externalPending) then error("another AH request is outstanding; wait for completion or close/reopen AH") end
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
    if more then name, argument = "RequestMoreCommoditySearchResults", r.itemID end
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
    local item = Copperwise.SelectedItem()
    if not item then error("select a settled bag item first") end
    local key = api("MakeItemKey", item.id, 0, 0, 0)
    local info = api("GetItemKeyInfo", key)
    if not info or type(info.isCommodity) ~= "boolean" then
        result = {itemID=item.id, name=item.name, key=key, started=time(), requests=0,
            state="metadata loading", reason="Wait for item information, then click Scan again."}
        render()
        return
    end
    if not info.isCommodity then error("unsupported item: only comparable commodities can be scanned") end
    local context = (GetRealmName() or "unknown") .. " / " .. (UnitFactionGroup("player") or "unknown")
        .. " / region " .. value(GetCurrentRegion and GetCurrentRegion())
    result = {itemID=item.id, name=item.name, key=key, commodity=true, context=context,
        started=time(), requests=0, state="ready"}
    request(false)
end

local function more()
    if active then error("already waiting for results or item information") end
    if not result or result.state ~= "partial" or result.requests >= MAX_REQUESTS then
        error("More is only available after partial results and within the request bound")
    end
    request(true)
end

local function readResults()
    local r = result
    if not api("HasSearchResults", r.key) then return end
    local full = api("HasFullCommoditySearchResults", r.itemID)
    local count = api("GetNumCommoditySearchResults", r.itemID)
    if type(full) ~= "boolean" or type(count) ~= "number" or count < 0 or count ~= math.floor(count) then
        error("result count/completeness unavailable")
    end
    -- An empty partial update can be a loading signal, not an empty market.
    if count == 0 and not full then return end
    local units, bidOnly, minimum, seen = 0, 0, nil, {}
    local covered = math.min(count, MAX_ROWS)
    for index = 1, covered do
        local row = api("GetCommoditySearchResultInfo", r.itemID, index)
        if not row or type(row.quantity) ~= "number" or row.quantity <= 0
            or row.quantity ~= math.floor(row.quantity) or row.auctionID == nil then
            error("row " .. index .. " incomplete; no complete stock/price summary")
        end
        if seen[row.auctionID] then error("duplicate auction ID; coverage unresolved") end
        seen[row.auctionID] = true
        if row.itemID ~= r.itemID then
            error("row identity differs from requested key")
        end
        if type(row.unitPrice) ~= "number" or row.unitPrice <= 0 then error("commodity price unavailable") end
        local price = row.unitPrice
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
        Copperwise.observation = {itemID=r.itemID, key=r.key, context=r.context, minimum=r.minimum,
            units=r.units, rows=r.rows, observedAt=r.observedAt, full=true}
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

Copperwise.Scan = guard(start)
Copperwise.More = guard(more)
Copperwise.Cancel = function() cancel() end
Copperwise.ScanBusy = function() return active ~= nil end

frame:SetScript("OnUpdate", guard(function()
    if active and GetTime() >= active.deadline then fail("Timed out waiting for attributable, usable results; not observed empty.") end
end, true))

frame:SetScript("OnEvent", guard(function(_, event, ...)
    local argument = ...
    local kind, id
    if event == "COMMODITY_SEARCH_RESULTS_UPDATED" or event == "ITEM_SEARCH_RESULTS_UPDATED" then
        kind = "search"
        id = type(argument) == "table" and argument.itemID or argument
    elseif event == "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" then kind, id = "browse", "browse"
    elseif event == "OWNED_AUCTIONS_UPDATED" then kind, id = "owned", "owned"
    elseif event == "BIDS_UPDATED" then kind, id = "bids", "bids"
    elseif event == "REPLICATE_ITEM_LIST_UPDATE" then kind, id = "replicate", "replicate" end
    if kind and externalPending[kind .. ":" .. tostring(id)] then
        externalPending[kind .. ":" .. tostring(id)] = nil
        lastTraffic = GetTime()
    end
    if event == "PLAYER_LOGIN" then
        setupHooks()
    elseif event == "AUCTION_HOUSE_SHOW" then
        houseOpen = true
        lastTraffic = GetTime()
    elseif event == "AUCTION_HOUSE_CLOSED" then
        houseOpen = false
        cancel("Auction house closed; local collection stopped.")
        reopenRequired = false
        externalPending = {}
    elseif event == "ITEM_KEY_ITEM_INFO_RECEIVED" then
        render()
    elseif active then
        if event == "COMMODITY_SEARCH_RESULTS_UPDATED" or event == "COMMODITY_SEARCH_RESULTS_ADDED" then
            local itemID = ...
            if result.commodity and itemID == result.itemID then readResults() end
        elseif event == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" or event == "AUCTION_HOUSE_BROWSE_FAILURE"
            or event == "AUCTION_HOUSE_SHOW_ERROR" or event == "UI_ERROR_MESSAGE" then
            local code = ...
            fail(event .. " code=" .. value(code) .. "; scope/result uncertain")
        else record("event=" .. event .. "; waiting within deadline") end
    end
end, true))

for _, event in ipairs({"PLAYER_LOGIN", "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED",
    "ITEM_KEY_ITEM_INFO_RECEIVED", "AUCTION_HOUSE_BROWSE_RESULTS_UPDATED",
    "OWNED_AUCTIONS_UPDATED", "BIDS_UPDATED", "REPLICATE_ITEM_LIST_UPDATE",
    "ITEM_SEARCH_RESULTS_UPDATED", "ITEM_SEARCH_RESULTS_ADDED", "COMMODITY_SEARCH_RESULTS_UPDATED",
    "COMMODITY_SEARCH_RESULTS_ADDED", "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED",
    "AUCTION_HOUSE_THROTTLED_MESSAGE_QUEUED", "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
    "AUCTION_HOUSE_THROTTLED_MESSAGE_RESPONSE_RECEIVED", "AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
    "AUCTION_HOUSE_BROWSE_FAILURE", "AUCTION_HOUSE_SHOW_ERROR", "UI_ERROR_MESSAGE"}) do
    local ok, err = pcall(frame.RegisterEvent, frame, event)
    observed[event] = ok
    if not ok then record("unsupported event=" .. event .. " " .. tostring(err)) end
end
