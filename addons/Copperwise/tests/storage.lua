-- Run from the repository root with Lua 5.1 or newer.
local function snapshot(at, price)
    return {observedAt=at, full=true, count=1, context="Realm / Alliance / region 1",
        items={["42:0:0:0"]={key={itemID=42}, minimum=price, units=7}}}
end
local key = "1:5:Realm:Alliance"
local function login(account, character, realm, faction, region)
    Copperwise = {}
    CopperwiseAccountDB, CopperwiseDB = account, character
    local frame = {}
    function frame:SetScript(name, fn) self[name] = fn end
    function frame:RegisterEvent() end
    CreateFrame = function() return frame end
    GetRealmName = function() return realm or "Realm" end
    UnitFactionGroup = function() return faction or "Alliance" end
    GetCurrentRegion = function() return region or 1 end
    C_AuctionHouse = {
        SendBrowseQuery=function() end,
        MakeItemKey=function(id) return {itemID=id} end,
        GetItemKeyInfo=function() return {isCommodity=true} end,
    }
    hooksecurefunc = function() end
    dofile("addons/Copperwise/Storage.lua")
    dofile("addons/Copperwise/Scan.lua")
    frame.OnEvent(frame, "PLAYER_LOGIN")
    return Copperwise.ObservationFor(42)
end
local function test(name, fn)
    fn()
    print("PASS: " .. name)
end

test("pre-account-wide snapshots are not imported", function()
    assert(login(nil, {version=1, markets={[key]=snapshot(100, 250)}}) == nil)
end)

test("characters read shared prices, supply and original source time", function()
    local account = {version=1, markets={[key]=snapshot(100, 250)}}
    local observation = login(account, {version=1, saleIntent={[42]=3}})
    assert(observation.minimum == 250 and observation.units == 7 and observation.observedAt == 100)
    observation = login(account, {version=1, saleIntent={[42]=1}})
    assert(observation.minimum == 250 and CopperwiseDB.saleIntent[42] == 1)
    assert(account.saleIntent == nil)
end)

test("unsupported versions are preserved and unavailable", function()
    for _, version in ipairs({0, 2, "1"}) do
        local account = {version=version, markets={[key]=snapshot(100, 250)}}
        assert(login(account, nil) == nil)
        assert(CopperwiseAccountDB == account and account.version == version)
        assert(account.markets[key].observedAt == 100)
        assert(Copperwise.notice)
        Copperwise.Scan()
        assert(CopperwiseAccountDB == account and account.markets[key].observedAt == 100)
    end
end)

test("malformed account data is preserved rather than reset", function()
    for _, account in ipairs({"invalid", {version=1}, {markets={}}}) do
        assert(login(account, nil) == nil)
        assert(CopperwiseAccountDB == account and Copperwise.notice)
    end
end)

test("complete empty markets survive character switching", function()
    local empty = snapshot(100, 250)
    empty.items, empty.count = {}, 0
    local observation = login({version=1, markets={[key]=empty}}, nil)
    assert(observation.empty and observation.units == 0 and observation.minimum == nil)
    assert(observation.observedAt == 100 and observation.full)
end)

test("realm, faction and region isolate shared observations", function()
    local account = {version=1, markets={[key]=snapshot(100, 250)}}
    assert(login(account, nil, "Other") == nil)
    assert(login(account, nil, "Realm", "Horde") == nil)
    assert(login(account, nil, "Realm", "Alliance", 2) == nil)
    assert(login(account, nil).minimum == 250)
end)
