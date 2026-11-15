-- Production scan lifecycle through native events, public actions and observations.
-- Run: luajit addons/Copperwise/tests/scan.lua
local function session()
    local env = setmetatable({}, {__index=_G})
    local s = {clock=10, ready=true, full=true, frames={}, requests=0,
        rows={{itemKey={itemID=42}, totalQuantity=7, minPrice=250}}}
    local methods = {}
    for _, name in ipairs({"SetPoint", "SetSize", "SetJustifyH", "SetJustifyV", "SetEnabled", "SetID", "RegisterEvent", "SetTitle"}) do
        methods[name] = function() end
    end
    local function widget() return setmetatable({scripts={}, shown=true}, {__index=methods}) end
    function methods:SetScript(name, fn) self.scripts[name] = fn end
    function methods:SetText(text) self.text = text end
    function methods:CreateFontString() s.output = widget(); return s.output end
    function methods:IsShown() return self.shown end
    function methods:Hide() self.shown=false; if self.scripts.OnHide then self.scripts.OnHide(self) end end
    function methods:Show() self.shown=true end
    env.CreateFrame = function()
        local frame = widget(); s.frames[#s.frames+1] = frame; return frame
    end
    env.Copperwise = {}
    env.GetTime = function() return s.clock end
    env.time = function() return 1000 + math.floor(s.clock) end
    env.date = function(_, at) return tostring(at) end
    env.print = function() end
    env.GetBuildInfo = function() return "test", "test", "", 16001 end
    env.GetRealmName = function() return s.realm or "Realm" end
    env.UnitFactionGroup = function() return s.faction or "Alliance" end
    env.GetCurrentRegion = function() return s.region or 3 end
    env.C_AuctionHouse = {
        MakeItemKey=function(id) return {itemID=id} end,
        GetItemKeyInfo=function() return {isCommodity=true} end,
        IsThrottledMessageSystemReady=function() return s.ready end,
        GetBrowseResults=function() return s.rows end,
        HasFullBrowseResults=function() return s.full end,
        SendBrowseQuery=function() s.requests=s.requests+1 end,
        RequestMoreBrowseResults=function() s.requests=s.requests+1 end,
    }
    env.hooksecurefunc = function(target, name, hook)
        local original=target[name]
        target[name]=function(...) local result=original(...); hook(...); return result end
    end
    for _, name in ipairs({"PanelTemplates_TabResize", "PanelTemplates_SetNumTabs", "PanelTemplates_DeselectTab", "PanelTemplates_SelectTab"}) do
        env[name]=function() end
    end
    env.AuctionHouseFrameDisplayMode = {}
    env.AuctionHouseFrame = widget()
    env.AuctionHouseFrame.Tabs = {widget(), widget(), widget()}
    env.AuctionHouseFrame.tabsForDisplayMode = {}
    function env.AuctionHouseFrame:SetDisplayMode(mode)
        if mode == env.AuctionHouseFrameDisplayMode.CopperwiseMarket then self.CopperwiseMarketPanel:Show() end
    end
    for _, name in ipairs({"Storage", "Scan"}) do
        setfenv(assert(loadfile("addons/Copperwise/" .. name .. ".lua")), env)()
    end
    function s:event(event)
        for _, frame in ipairs(self.frames) do if frame.scripts.OnEvent then frame.scripts.OnEvent(frame, event) end end
    end
    function s:tick(seconds)
        self.clock=self.clock+seconds
        for _, frame in ipairs(self.frames) do if frame.scripts.OnUpdate then frame.scripts.OnUpdate(frame, seconds) end end
    end
    function s:start()
        self:event("AUCTION_HOUSE_CLOSED"); self:event("AUCTION_HOUSE_SHOW")
        env.AuctionHouseFrame:SetDisplayMode(env.AuctionHouseFrameDisplayMode.CopperwiseMarket)
        self:tick(3); env.Copperwise.Scan()
    end
    function s:receive() self:event("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED"); self:tick(0.25) end
    function s:observation() return env.Copperwise.ObservationFor(42) end
    function s:preserved()
        local observation=self:observation()
        assert(observation.minimum==250 and observation.units==7 and observation.observedAt==self.sourceTime and observation.full)
    end
    s.env=env
    s:event("PLAYER_LOGIN"); s:start(); s:receive()
    assert(env.Copperwise.attempt.state=="complete")
    s.sourceTime=s:observation().observedAt
    return s
end
local function test(name, fn) fn(session()); print("PASS: " .. name) end

test("partial cumulative pages wait for readiness and only publish complete coverage", function(s)
    s.full=false; s.rows={{itemKey={itemID=42}, totalQuantity=1, minPrice=10}}
    s:start(); s:receive(); s:preserved()
    s.ready=false; local requests=s.requests; s:tick(1)
    assert(s.env.Copperwise.attempt.state=="throttled" and s.requests==requests)
    s.ready=true; s:tick(1)
    assert(s.requests==requests+1)
    s.full=true; s.rows={{itemKey={itemID=42}, totalQuantity=9, minPrice=300}, {itemKey={itemID=43}, totalQuantity=2, minPrice=100}}
    s:receive()
    assert(s:observation().units==9 and s:observation().minimum==300)
    assert(s.env.Copperwise.ObservationFor(43).units==2)
end)

for _, stop in ipairs({"cancel", "close", "leave", "competing", "failure", "timeout", "total timeout"}) do
    test(stop .. " preserves observations and ignores late results", function(s)
        s:start()
        if stop=="cancel" then s.env.Copperwise.Cancel()
        elseif stop=="close" then s:event("AUCTION_HOUSE_CLOSED")
        elseif stop=="leave" then s.env.AuctionHouseFrame:SetDisplayMode({})
        elseif stop=="competing" then s.env.C_AuctionHouse.SendBrowseQuery({})
        elseif stop=="failure" then s:event("AUCTION_HOUSE_BROWSE_FAILURE")
        elseif stop=="timeout" then s:tick(31)
        else s.full=false; s:receive(); s.ready=false; s:tick(181) end
        local outcome=s.env.Copperwise.attempt.state
        assert(outcome=="cancelled" or outcome=="failed")
        local requests=s.requests
        s.rows={}; s:receive(); s:tick(1)
        assert(s.requests==requests and s.env.Copperwise.attempt.state==outcome)
        s:preserved()
        s.ready=true; s.full=true; s:start(); s:receive()
        assert(s.env.Copperwise.attempt.state=="complete" and s:observation().empty)
    end)
end

test("market reads isolate realm faction and region without deleting compatible data", function(s)
    s.realm="Other"; assert(s:observation()==nil); s.realm=nil
    s.faction="Horde"; assert(s:observation()==nil); s.faction=nil
    s.region=1; assert(s:observation()==nil); s.region=nil
    s:event("PLAYER_LOGIN"); s:preserved()
end)

test("complete empty and missing buyout remain distinct from a zero price", function(s)
    s.rows={}; s:start(); s:receive()
    assert(s:observation().empty and s:observation().units==0 and s:observation().minimum==nil)
    s.rows={{itemKey={itemID=42}, totalQuantity=8, minPrice=0}}; s:start(); s:receive()
    assert(not s:observation().empty and s:observation().units==8 and s:observation().minimum==nil)
end)
