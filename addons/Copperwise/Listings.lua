local CW = Copperwise
local frame = CreateFrame("Frame")
local selected, queued, request, result, waitingReason, queuedAt
local visible = false
local MAX_ROWS, MAX_REQUESTS = 10000, 20

local function changed()
    if CW.RenderReview then CW.RenderReview() end
end

local function finish(state, reason)
    if request and request.waiting then CW.AHResponseUncertain = true end
    request, CW.AHOperation = nil, nil
    if result then result.state, result.reason = state, reason end
    changed()
end

function CW.ItemListings(id)
    if result and result.id == id then return result end
end

function CW.ListingsWaitReason()
    return waitingReason or "Waiting to request current item listings…"
end

function CW.SelectListings(id, refresh)
    visible = true
    if selected == id and not refresh then
        if queued == id or (request and request.id == id) or (result and result.id == id) then return end
        -- Another AH request can clear an unsent selection. Requeue it once
        -- the review renders again, rather than leaving the table waiting forever.
    end
    if selected ~= id or refresh then queuedAt = nil end
    waitingReason = nil
    selected = id
    queued = id -- An old request drains before another item may query the shared cache.
    if not request then result = nil end
    changed()
end

function CW.CloseListings()
    visible, selected, queued, waitingReason, queuedAt = false, nil, nil, nil, nil
    if not request then result = nil end
end

function CW.InterruptListings(reason)
    queued = nil
    if request then finish("interrupted", reason) end
end

local function dispatch(more)
    local reason = CW.AHReadiness("listings", more and 0.2 or 2)
    if reason then result.reason = reason; return end
    if request.requests >= MAX_REQUESTS then finish("partial", "Item request limit reached; refresh manually."); return end
    request.requests = request.requests + 1
    request.waiting, request.deadline, request.more = true, GetTime()+20, nil
    result.state, result.reason = "loading", "Loading current item listings…"
    local ok, err
    if more then ok, err = CW.AHRequest("RequestMoreCommoditySearchResults", request.id)
    else ok, err = CW.AHRequest("SendSearchQuery", request.key, {}, false) end
    if not ok then finish("failed", tostring(err)) end
end

local function read()
    local r = request
    local full = C_AuctionHouse.HasFullCommoditySearchResults(r.id)
    local count = C_AuctionHouse.GetNumCommoditySearchResults(r.id)
    if type(full) ~= "boolean" or type(count) ~= "number" or count < 0 or count % 1 ~= 0 then
        error("Item coverage unavailable")
    end
    if count == 0 and not full then return end
    r.waiting = false
    if selected ~= r.id or not visible then
        if not full and visible then
            r.more = true -- Drain the old item completely before switching cache keys.
        else
            if not full then CW.AHResponseUncertain = true end
            request, CW.AHOperation, result = nil, nil, nil
        end
        return
    end
    if count > MAX_ROWS then finish("partial", "Item row limit reached; prices withheld."); return end
    local prices, seen, units = {}, {}, 0
    for index = 1, count do
        local row = C_AuctionHouse.GetCommoditySearchResultInfo(r.id, index)
        if not row or row.itemID and row.itemID ~= r.id or type(row.unitPrice) ~= "number"
            or row.unitPrice <= 0 or row.unitPrice % 1 ~= 0 or type(row.quantity) ~= "number"
            or row.quantity <= 0 or row.quantity % 1 ~= 0 then error("Incomplete item listing metadata") end
        if row.auctionID then
            if seen[row.auctionID] then error("Repeated auction identity; item coverage uncertain") end
            seen[row.auctionID] = true
        end
        prices[row.unitPrice] = (prices[row.unitPrice] or 0) + row.quantity
        units = units + row.quantity
    end
    local levels = {}
    for price, quantity in pairs(prices) do levels[#levels+1] = {price=price, quantity=quantity} end
    table.sort(levels, function(a,b) return a.price < b.price end)
    -- Each native response is cumulative; never add snapshots together.
    result.levels, result.units, result.observedAt = levels, units, time()
    result.full = full
    if full then
        finish("complete", count == 0 and "No current buyout listings. Enter a unit buyout." or "Current item listings loaded.")
    else
        r.more = true
        result.state, result.reason = "partial", "Partial item listings; collecting more…"
    end
end

frame:SetScript("OnUpdate", function()
    local ok, err = pcall(function()
        if request then
            if GetTime() > request.totalDeadline then finish("failed", "Item search timed out; close/reopen AH if a response is outstanding.")
            elseif request.waiting and GetTime() > request.deadline then finish("failed", "Item response timed out; close/reopen AH.")
            elseif request.more ~= nil then
                if visible then dispatch(request.more)
                else
                    if request.requests > 0 then CW.AHResponseUncertain = true end
                    finish("cancelled", "Item query stopped after leaving the tab.")
                end
            end
        elseif queued and visible then
            local reason = CW.AHReadiness("listings", 2)
            if reason then waitingReason = reason; return end
            local id = queued
            local key = C_AuctionHouse.MakeItemKey(id, 0, 0, 0)
            local info = C_AuctionHouse.GetItemKeyInfo(key)
            if not info or info.isCommodity == nil then
                waitingReason = "Loading item information…"
                queuedAt = queuedAt or GetTime()
                if GetTime() - queuedAt > 15 then
                    queued = nil
                    result = {id=id, levels={}, state="failed", reason="Item information did not load. Refresh item to retry."}
                    changed()
                end
                return
            end
            queued = nil
            result = {id=id, levels={}, state="loading", reason="Loading current listings…"}
            if info.isCommodity ~= true then finish("unsupported", "Only comparable commodities are supported."); return end
            CW.AHOperation = "listings"
            request = {id=id, key=key, requests=0, more=false, totalDeadline=GetTime()+90}
            dispatch(false)
        end
    end)
    if not ok then finish("failed", tostring(err)) end
end)
frame:SetScript("OnEvent", function(_, event, id)
    if event == "AUCTION_HOUSE_CLOSED" then
        request, queued, result, selected, CW.AHOperation = nil, nil, nil, nil, nil
        visible = false
    elseif request and request.waiting and id == request.id
        and (event == "COMMODITY_SEARCH_RESULTS_UPDATED" or event == "COMMODITY_SEARCH_RESULTS_ADDED") then
        local ok, err = pcall(read)
        if not ok then finish("failed", tostring(err)) end
    elseif request and (event == "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED" or event == "AUCTION_HOUSE_SHOW_ERROR") then
        finish("failed", event .. "; item prices withheld.")
    end
end)
for _, event in ipairs({"AUCTION_HOUSE_CLOSED", "COMMODITY_SEARCH_RESULTS_UPDATED",
    "COMMODITY_SEARCH_RESULTS_ADDED", "AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED", "AUCTION_HOUSE_SHOW_ERROR"}) do
    pcall(frame.RegisterEvent, frame, event)
end
