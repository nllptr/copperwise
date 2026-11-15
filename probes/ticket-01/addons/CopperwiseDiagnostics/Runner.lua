-- Each case gets isolated globals, fake UI, API inputs, clock and storage.
-- No fallback to _G: production code cannot reach native requests or saved data.
local sources = assert(CopperwiseDiagnosticSources, "Missing production bundle")
local function sandbox()
    local env = {}
    for _, name in ipairs({"assert", "error", "ipairs", "pairs", "next", "pcall",
        "select", "tonumber", "tostring", "type", "unpack"}) do env[name] = _G[name] end
    env.math, env.string, env.table = math, string, table
    local state = {clock=10, frames={}, requests=0, ready=true, full=true, sell=2,
        rows={{itemKey={itemID=2835}, totalQuantity=1804, minPrice=8}}}
    local methods = {}
    local function widget()
        return setmetatable({scripts={}, shown=true}, {__index=methods})
    end
    for _, name in ipairs({"SetSize", "SetPoint", "SetMovable", "EnableMouse",
        "RegisterForDrag", "StartMoving", "StopMovingOrSizing", "RegisterEvent",
        "SetJustifyH", "SetJustifyV", "SetEnabled", "SetID", "SetTitle"}) do
        methods[name] = function() end
    end
    function methods:SetScript(name, fn) self.scripts[name] = fn end
    function methods:SetText(value)
        self.text = value
        if value:find("Bag quantity:", 1, true) then state.inventory = value end
        if value:find("Full auction-house scan", 1, true) then state.panel = value end
    end
    function methods:CreateFontString() return widget() end
    function methods:IsShown() return self.shown end
    function methods:Hide()
        self.shown = false
        if self.scripts.OnHide then self.scripts.OnHide(self) end
    end
    function methods:Show() self.shown = true end
    env.CreateFrame = function(_, name)
        local frame = widget()
        frame.TitleText = widget()
        if name then env[name] = frame end
        state.frames[#state.frames+1] = frame
        return frame
    end
    env.GetTime = function() return state.clock end
    env.time = function() return 1800000000 + math.floor(state.clock) end
    env.date = function(_, timestamp) return "simulated time " .. timestamp end
    env.print = function() end
    env.GetBuildInfo = function() return "simulated", "diagnostic", "", 16001 end
    env.GetRealmName = function() return "Diagnostic Realm" end
    env.UnitFactionGroup = function() return "Alliance" end
    env.GetCurrentRegion = function() return 3 end
    env.CursorHasItem = function() return false end
    env.GetCoinTextureString = function(value) return tostring(value) .. " copper" end
    env.C_Container = {
        GetContainerNumSlots=function(bag) return bag == 0 and 1 or 0 end,
        GetContainerItemInfo=function() return {itemID=2835, stackCount=18,
            hyperlink="[Rough Stone — simulated]"} end,
    }
    env.C_Item = {GetItemInfo=function()
        return "Rough Stone", nil, nil, nil, nil, nil, nil, nil, nil, nil, state.sell
    end}
    env.C_AuctionHouse = {
        MakeItemKey=function(id) return {itemID=id} end,
        GetItemKeyInfo=function() return {isCommodity=true} end,
        IsThrottledMessageSystemReady=function() return state.ready end,
        GetBrowseResults=function() return state.rows end,
        HasFullBrowseResults=function() return state.full end,
        SendBrowseQuery=function()
            state.requests = state.requests + 1
            if state.dispatchError then error("Simulated request failure") end
        end,
        RequestMoreBrowseResults=function() state.requests = state.requests + 1 end,
    }
    env.hooksecurefunc = function(target, name, hook)
        local original = target[name]
        target[name] = function(...)
            local result = original(...)
            hook(...)
            return result
        end
    end
    env.SlashCmdList, env.UISpecialFrames = {}, {}
    env.UIDropDownMenu_Initialize = function(_, fn) state.menu = fn end
    env.UIDropDownMenu_CreateInfo = function() return {} end
    env.UIDropDownMenu_AddButton = function(info) state.select = info.func end
    for _, name in ipairs({"UIDropDownMenu_SetWidth", "UIDropDownMenu_SetText",
        "PanelTemplates_TabResize", "PanelTemplates_SetNumTabs",
        "PanelTemplates_DeselectTab", "PanelTemplates_SelectTab"}) do env[name] = function() end end
    env.AuctionHouseFrameDisplayMode = {}
    env.AuctionHouseFrame = widget()
    env.AuctionHouseFrame.Tabs = {widget(), widget(), widget()}
    env.AuctionHouseFrame.tabsForDisplayMode = {}
    function env.AuctionHouseFrame:SetDisplayMode()
        self.CopperwiseMarketPanel:Show()
    end
    for _, name in ipairs({"Inventory", "Storage", "Scan"}) do sources[name](env) end
    function state:event(name)
        for _, frame in ipairs(self.frames) do
            if frame.scripts.OnEvent then frame.scripts.OnEvent(frame, name) end
        end
    end
    function state:tick(seconds)
        self.clock = self.clock + seconds
        for _, frame in ipairs(self.frames) do
            if frame.scripts.OnUpdate then frame.scripts.OnUpdate(frame, seconds) end
        end
    end
    function state:receive()
        self:event("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED")
        self:tick(0.25)
    end
    function state:start()
        self:event("AUCTION_HOUSE_CLOSED")
        self:event("AUCTION_HOUSE_SHOW")
        env.AuctionHouseFrame:SetDisplayMode(env.AuctionHouseFrameDisplayMode.CopperwiseMarket)
        self:tick(3)
        env.Copperwise.Scan()
    end
    state:event("PLAYER_LOGIN")
    env.SlashCmdList.COPPERWISE()
    state:tick(0.25); state:tick(1)
    state.menu(); assert(state.select, "Missing diagnostic bag selection"); state.select()
    state:start(); state:receive()
    assert(env.Copperwise.attempt.state == "complete", "Baseline scan did not complete")
    state.baseline = state.inventory
    state.baselineTime = env.Copperwise.ObservationFor(2835).observedAt
    state.env = env
    return state
end

local function contains(text, expected)
    assert(text and text:find(expected, 1, true), "Expected visible text: " .. expected)
end
local function preserved(s)
    -- Check through public Inventory output, not the saved-variable shape.
    contains(s.inventory, "Lowest observed asking / unit: 8 copper")
    contains(s.inventory, "Available supply: 1804")
    contains(s.inventory, "Observed locally: simulated time " .. s.baselineTime)
    contains(s.inventory, "Coverage: complete market summary")
end
local cases = {
    {"metadata", "Unavailable vendor metadata becomes known zero without scanning", function(s)
        local requests = s.requests
        s.sell = nil
        s:event("GET_ITEM_INFO_RECEIVED"); s:tick(1)
        contains(s.inventory, "Vendor sell / unit: unavailable")
        contains(s.inventory, "Vendor sell / owned quantity: unavailable")
        s.unavailable = s.inventory
        s.sell = 0
        s:event("GET_ITEM_INFO_RECEIVED"); s:tick(1)
        contains(s.inventory, "Vendor sell / unit: 0 copper")
        contains(s.inventory, "Vendor sell / owned quantity: 0 copper")
        assert(s.requests == requests, "Metadata refresh sent a scan")
    end},
    {"empty", "Complete-empty coverage has zero supply and unavailable buyout", function(s)
        s.rows = {}
        s:start(); s:receive()
        contains(s.inventory, "Latest full scan: complete")
        contains(s.inventory, "Available supply: 0")
        contains(s.inventory, "Lowest observed asking / unit: unavailable")
        contains(s.inventory, "Coverage: complete market summary (item absent)")
    end},
    {"buyout", "A summary with no buyout never becomes a zero asking price", function(s)
        s.rows = {{itemKey={itemID=2835}, totalQuantity=42, minPrice=0}}
        s:start(); s:receive()
        contains(s.inventory, "Latest full scan: complete")
        contains(s.inventory, "Available supply: 42")
        contains(s.inventory, "Lowest observed asking / unit: unavailable")
    end},
    {"failure", "A failed refresh preserves the last complete observation", function(s)
        s.dispatchError = true
        s:start()
        contains(s.inventory, "Latest full scan: failed")
        contains(s.inventory, "Simulated request failure")
        preserved(s)
    end},
    {"timeout", "Missing response times out and ignores late results", function(s)
        s:start(); s:tick(31)
        contains(s.inventory, "Latest full scan: failed")
        contains(s.inventory, "Response timed out")
        preserved(s)
        s.rows = {}; s:receive()
        contains(s.inventory, "Latest full scan: failed")
        preserved(s)
    end},
    {"partial", "Partial coverage stays separate and total timeout preserves the snapshot", function(s)
        s.full = false
        s.rows = {{itemKey={itemID=2835}, totalQuantity=1, minPrice=1}}
        s:start(); s:receive()
        contains(s.inventory, "Latest full scan: partial")
        preserved(s)
        s.partial = s.inventory
        s.ready = false; s:tick(1)
        contains(s.inventory, "Latest full scan: throttled")
        local requests = s.requests
        s:tick(179)
        contains(s.inventory, "Latest full scan: failed")
        contains(s.inventory, "Full scan timed out")
        assert(s.requests == requests, "Sent request while throttled")
        preserved(s)
    end},
    {"throttle", "Query readiness pauses and resumes pagination", function(s)
        s.full = false
        s:start(); s:receive()
        s.ready = false
        local requests = s.requests
        s:tick(1)
        contains(s.inventory, "Latest full scan: throttled")
        assert(s.requests == requests, "Sent request while throttled")
        preserved(s)
        s.throttled = s.inventory
        s.ready = true; s:tick(1)
        contains(s.inventory, "Latest full scan: waiting")
        assert(s.requests == requests + 1, "Pagination did not resume")
        s.full = true; s:receive()
        contains(s.inventory, "Latest full scan: complete")
    end},
}

function CopperwiseRunDiagnostics(filter)
    local results, failures = {}, 0
    for _, case in ipairs(cases) do
        if not filter or filter == "all" or filter == case[1] then
            local s
            local ok, err = pcall(function() s = sandbox(); case[3](s) end)
            if not ok then failures = failures + 1 end
            results[#results+1] = {name=case[1], title=case[2], ok=ok, error=err,
                before=s and s.baseline, after=s and s.inventory,
                intermediate=s and (s.unavailable or s.partial or s.throttled)}
        end
    end
    assert(#results > 0, "Unknown case; use all, metadata, empty, buyout, failure, timeout, partial or throttle")
    return results, failures
end
