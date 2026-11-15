-- Synthetic acceptance through production login, Inventory rows and row clicks.
-- Run from the repository root: luajit addons/Copperwise/tests/inventory.lua
-- Native APIs/widgets are simulated; no game process or real saved data is used.
local function inventory(items, prices, character)
    local env = setmetatable({}, {__index=_G})
    local state = {clock=0, frames={}, widgets={}}
    local methods = {}
    local function widget(kind)
        local value = setmetatable({kind=kind, scripts={}, shown=true}, {__index=methods})
        state.widgets[#state.widgets+1] = value
        return value
    end
    for _, name in ipairs({"SetPoint", "SetMovable", "EnableMouse", "RegisterForDrag",
        "StartMoving", "StopMovingOrSizing", "RegisterEvent", "SetJustifyH", "SetJustifyV",
        "SetHighlightTexture", "SetWidth", "SetTexture", "SetColorTexture",
        "ClearAllPoints", "SetAutoFocus", "SetMaxLetters", "ClearFocus"}) do
        methods[name] = function() end
    end
    function methods:SetSize(_, height) self.height = height end
    function methods:SetHeight(height) self.height = height end
    function methods:GetHeight() return self.height or 500 end
    function methods:SetVerticalScroll(value) self.scroll = value end
    function methods:GetVerticalScroll() return self.scroll or 0 end
    function methods:SetScrollChild(child) self.child = child end
    function methods:SetText(value) self.text = value end
    function methods:SetScript(name, fn) self.scripts[name] = fn end
    function methods:CreateFontString() return widget("FontString") end
    function methods:CreateTexture() return widget("Texture") end
    function methods:Show() self.shown = true end
    function methods:Hide() self.shown = false end
    env.CreateFrame = function(kind)
        local value = widget(kind)
        value.TitleText = widget("FontString")
        state.frames[#state.frames+1] = value
        return value
    end
    env.GetTime = function() return state.clock end
    env.time = function() return state.now or 1000 end
    env.date = function() return "synthetic source time" end
    env.CursorHasItem = function() return false end
    env.GetCoinTextureString = function(value) return value .. "c" end
    env.GetRealmName = function() return "Test Realm" end
    env.UnitFactionGroup = function() return "Alliance" end
    env.GetCurrentRegion = function() return 3 end
    env.hooksecurefunc = function() end
    env.UISpecialFrames, env.SlashCmdList = {}, {}
    env.C_Container = {
        GetContainerNumSlots=function(bag) return bag == 0 and #items or 0 end,
        GetContainerItemInfo=function(_, slot)
            local item = items[slot]
            return {itemID=item.id, stackCount=item.quantity or 1, iconFileID=123}
        end,
    }
    env.C_Item = {GetItemInfo=function(id)
        for _, item in ipairs(items) do
            if item.id == id then
                return item.name, nil, nil, nil, nil, nil, nil, nil, nil, 123, item.sell
            end
        end
    end}
    local function forbidden() error("Inventory must not send market requests") end
    env.C_AuctionHouse = {
        MakeItemKey=function(id) return {itemID=id} end,
        GetItemKeyInfo=function() return {isCommodity=true} end,
        SendBrowseQuery=forbidden, RequestMoreBrowseResults=forbidden,
        SendSearchQuery=forbidden, SendSellSearchQuery=forbidden,
    }
    local summaries = {}
    for id, price in pairs(prices or {}) do
        summaries[tostring(id)] = {key={itemID=id}, minimum=price, units=10}
    end
    env.CopperwiseDB = character
    env.CopperwiseAccountDB = {version=1, markets={}}
    if prices then
        env.CopperwiseAccountDB.markets["3:10:Test Realm:Alliance"] = {
            full=true, count=1, observedAt=900, context="Test Realm / Alliance / region 3",
            items=summaries,
        }
    end
    for _, name in ipairs({"Inventory", "Storage", "Intent", "Scan"}) do
        local chunk = assert(loadfile("addons/Copperwise/" .. name .. ".lua"))
        setfenv(chunk, env)()
    end
    for _, frame in ipairs(state.frames) do
        if frame.scripts.OnEvent then frame.scripts.OnEvent(frame, "PLAYER_LOGIN") end
    end
    local inventoryFrame = state.frames[1]
    function state:refresh()
        for _ = 1, 5 do
            self.clock = self.clock + 0.25
            inventoryFrame.scripts.OnUpdate(inventoryFrame, 0.25)
        end
    end
    function state:rows()
        local result = {}
        for _, value in ipairs(self.widgets) do
            if value.kind == "Button" and value.shown and value.label then result[#result+1] = value end
        end
        return result
    end
    function state:select(index)
        local row = self:rows()[index]
        row.scripts.OnClick(row)
        for _, value in ipairs(self.widgets) do
            if value.kind == "FontString" and value.text and value.text:find("Item ID:", 1, true) then
                return value.text
            end
        end
        error("No selected item detail")
    end
    state.env = env
    function state:command(text) env.SlashCmdList.COPPERWISE(text) end
    state:refresh()
    env.SlashCmdList.COPPERWISE()
    return state
end
local function contains(text, expected)
    assert(text:find(expected, 1, true), "Expected '" .. expected .. "' in '" .. text .. "'")
end
local function test(name, fn)
    fn()
    print("PASS: " .. name)
end

test("equal net proceeds prefer Vendor and preserve gross asking detail", function()
    local ui = inventory({{id=1, name="Tie", sell=95}}, {[1]=100})
    contains(ui:rows()[1].value.text, "95c — Vendor")
    local detail = ui:select(1)
    contains(detail, "AH asking / owned quantity: 100c")
    contains(detail, "AH estimated proceeds (5% cut): 95c")
    contains(detail, "Preferred destination: Vendor")
end)

test("missing vendor metadata sorts last without choosing a destination, then refreshes", function()
    local unknown = {id=1, name="A missing vendor"}
    local ui = inventory({unknown, {id=2, name="Complete", sell=1}}, {[1]=1000, [2]=100})
    contains(ui:rows()[1].label.text, "Complete")
    contains(ui:rows()[2].value.text, "Unavailable — vendor metadata loading")
    local detail = ui:select(2)
    contains(detail, "Vendor sell / owned quantity: unavailable")
    contains(detail, "AH estimated proceeds (5% cut): 950c")
    contains(detail, "Preferred destination: unavailable (both values required)")
    unknown.sell = 0
    ui:refresh()
    contains(ui:rows()[1].label.text, "A missing vendor")
    contains(ui:rows()[1].value.text, "950c — AH")
    detail = ui:select(1)
    contains(detail, "Vendor sell / owned quantity: 0c")
    contains(detail, "Preferred destination: AH")
end)

test("no retained observation withholds AH values and directs the player to the AH tab", function()
    local ui = inventory({{id=1, name="No scan", sell=100}})
    contains(ui:rows()[1].value.text, "Unavailable — no comparable retained AH value")
    local detail = ui:select(1)
    contains(detail, "AH asking / owned quantity: unavailable")
    contains(detail, "AH estimated proceeds (5% cut): unavailable")
    contains(detail, "Vendor sell / owned quantity: 100c")
    contains(detail, "Preferred destination: unavailable (both values required)")
    contains(detail, "Full scan in the Copperwise auction-house tab")
    assert(not detail:find("Retained full-scan observation", 1, true))
end)

test("equal ranking totals sort by name then stable identity, incomplete comparisons last", function()
    local ui = inventory({
        {id=5, name="A unavailable", sell=1},
        {id=3, name="Zebra", sell=1},
        {id=2, name="Amber", sell=1},
        {id=1, name="Amber", sell=1},
    }, {[1]=100, [2]=100, [3]=100})
    local rows = ui:rows()
    contains(rows[1].label.text, "Amber")
    contains(rows[2].label.text, "Amber")
    contains(rows[3].label.text, "Zebra")
    contains(rows[4].label.text, "A unavailable")
    contains(ui:select(1), "Item ID: 1\n")
    contains(ui:select(2), "Item ID: 2\n")
    contains(ui:select(3), "Item ID: 3\n")
    for index = 1, 3 do contains(rows[index].value.text, "95c — AH") end
    contains(rows[4].value.text, "Unavailable — observed empty supply")
end)

test("ranking compares net AH proceeds with vendor totals rather than gross asking", function()
    local ui = inventory({
        {id=1, name="Z vendor wins", sell=96},
        {id=2, name="A gross higher", sell=0},
    }, {[1]=100, [2]=101})
    contains(ui:rows()[1].label.text, "Z vendor wins")
    contains(ui:rows()[1].value.text, "96c — Vendor")
    contains(ui:rows()[2].value.text, "95c — AH")
end)


test("AH recommendations warn strictly after the default hour", function()
    local ui = inventory({{id=1, name="AH", sell=1}}, {[1]=100})
    ui.now = 4500 -- retained source is 900
    ui:refresh()
    assert(not ui:rows()[1].value.text:find("stale", 1, true))
    ui.now = 4501
    ui:refresh()
    contains(ui:rows()[1].value.text, "AH (stale price)")
    contains(ui:select(1), "Warning: AH price exceeds the stale threshold (60 minutes).")
end)

test("stale configuration survives login and rejects invalid input without changing intent", function()
    local character = {saleIntent={[1]=3}}
    local ui = inventory({{id=1, name="AH", sell=1}}, {[1]=100}, character)
    ui:command("stale 1")
    contains(ui:rows()[1].value.text, "AH (stale price)")
    assert(character.staleMinutes == 1 and character.saleIntent[1] == 3)
    ui = inventory({{id=1, name="AH", sell=1}}, {[1]=100}, character)
    contains(ui:rows()[1].value.text, "AH (stale price)")
    for _, input in ipairs({"stale 0", "stale -1", "stale nan", "stale inf", "stale 1 extra"}) do
        ui:command(input)
        assert(character.staleMinutes == 1)
    end
    ui:command("stale 2")
    assert(not ui:rows()[1].value.text:find("stale", 1, true))
end)

test("old Vendor recommendations and unavailable comparisons have no stale warning", function()
    local ui = inventory({{id=1, name="Vendor", sell=100}, {id=2, name="Empty", sell=1}}, {[1]=100})
    ui.now = 10000
    ui:refresh()
    for index, row in ipairs(ui:rows()) do
        assert(not row.value.text:find("stale", 1, true))
        assert(not ui:select(index):find("Warning:", 1, true))
    end
end)
