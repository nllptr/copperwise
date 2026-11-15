-- Run from the repository root with Lua 5.1 or newer.
local function snapshot(at, price, full)
    return {observedAt=at, full=full ~= false, count=1, context="Realm / Alliance / region 1",
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
    dofile("addons/Copperwise/Scan.lua")
    frame.OnEvent(frame, "PLAYER_LOGIN")
    return Copperwise.ObservationFor(42)
end

local function test(name, fn)
    fn()
    print("PASS: " .. name)
end

test("another character reads migrated prices, supply and original source time", function()
    login(nil, {version=1, markets={[key]=snapshot(100, 250)}})
    local observation = login(CopperwiseAccountDB, nil)
    assert(observation and observation.minimum == 250)
    assert(observation.units == 7 and observation.observedAt == 100 and observation.full)
end)

test("older characters cannot replace a newer complete market snapshot", function()
    local observation = login({version=1, markets={[key]=snapshot(200, 500)}},
        {version=1, markets={[key]=snapshot(100, 250)}})
    assert(observation.minimum == 500 and observation.observedAt == 200)
end)

test("a newer complete migration replaces old data but equal source times stay stable", function()
    local observation = login({version=1, markets={[key]=snapshot(100, 250)}},
        {version=1, markets={[key]=snapshot(200, 500)}})
    assert(observation.minimum == 500 and observation.observedAt == 200)
    observation = login(CopperwiseAccountDB, {version=1, markets={[key]=snapshot(200, 999)}})
    assert(observation.minimum == 500 and observation.observedAt == 200)
end)

test("partial and undated legacy snapshots do not replace complete observations", function()
    local account = {version=1, markets={[key]=snapshot(100, 250)}}
    local observation = login(account, {version=1, markets={[key]=snapshot(200, 999, false)}})
    assert(observation.minimum == 250 and observation.observedAt == 100)
    observation = login(account, {version=1, markets={[key]=snapshot(nil, 999)}})
    assert(observation.minimum == 250 and observation.observedAt == 100)
end)

test("complete empty markets survive character switching", function()
    local empty = snapshot(100, 250)
    empty.items, empty.count = {}, 0
    login(nil, {version=1, markets={[key]=empty}})
    local observation = login(CopperwiseAccountDB, nil)
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

test("characters retain their own sale intent while reading shared market data", function()
    local characterA = {version=1, markets={[key]=snapshot(100, 250)}, saleIntent={[42]=3}}
    login(nil, characterA)
    local account = CopperwiseAccountDB
    local characterB = {version=1, saleIntent={[42]=1}}
    assert(login(account, characterB).minimum == 250)
    assert(CopperwiseDB.saleIntent[42] == 1 and characterA.saleIntent[42] == 3)
    assert(account.saleIntent == nil)
end)
