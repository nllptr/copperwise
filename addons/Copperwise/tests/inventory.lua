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
    for _, name in ipairs({"SetPoint", "SetFrameStrata", "SetMovable", "EnableMouse", "RegisterForDrag",
        "StartMoving", "StopMovingOrSizing", "RegisterEvent", "SetJustifyH", "SetJustifyV",
        "SetHighlightTexture", "SetAllPoints", "SetFontString", "SetWidth", "SetColorTexture",
        "ClearAllPoints", "SetAutoFocus", "SetMaxLetters", "ClearFocus", "SetWordWrap"}) do
        methods[name] = function() end
    end
    function methods:GetWidth() return 140 end
    function methods:GetCenter() return 100, 100 end
    function methods:GetEffectiveScale() return 2 end
    function methods:HookScript(name, fn) self.scripts[name] = fn end
    function methods:SetTexture(value) self.texture = value end
    function methods:SetEnabled(value) self.enabled = value end
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
    function methods:IsShown() return self.shown end
    function methods:Show() self.shown = true end
    function methods:Hide() self.shown = false end
    env.CreateFrame = function(kind, name)
        local value = widget(kind)
        if name then env[name] = value end
        value.TitleText = widget("FontString")
        state.frames[#state.frames+1] = value
        return value
    end
    env.GetCursorPosition = function() return state.cursorX or 400, state.cursorY or 200 end
    env.Minimap = widget("Minimap")
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
local function suggested(row)
    for _, action in ipairs(row.actions) do
        if action.recommended then return action.text end
    end
    return ""
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
    contains(ui:rows()[1].value.text, "95c")
    contains(suggested(ui:rows()[1]), "Vendor")
    local detail = ui:select(1)
    contains(detail, "AH asking / owned quantity: 100c")
    contains(detail, "AH estimated proceeds (5% cut): 95c")
    contains(detail, "Suggested destination: Vendor")
end)

test("missing vendor metadata sorts last without choosing a destination, then refreshes", function()
    local unknown = {id=1, name="A missing vendor"}
    local ui = inventory({unknown, {id=2, name="Complete", sell=1}}, {[1]=1000, [2]=100})
    contains(ui:rows()[1].label.text, "Complete")
    contains(ui:rows()[2].status.text, "Unavailable — vendor metadata loading")
    local detail = ui:select(2)
    contains(detail, "Vendor sell / owned quantity: unavailable")
    contains(detail, "AH estimated proceeds (5% cut): 950c")
    contains(detail, "Suggested destination: unavailable (both values required)")
    unknown.sell = 0
    ui:refresh()
    contains(ui:rows()[1].label.text, "A missing vendor")
    contains(ui:rows()[1].value.text, "950c")
    contains(suggested(ui:rows()[1]), "AH")
    detail = ui:select(1)
    contains(detail, "Vendor sell / owned quantity: 0c")
    contains(detail, "Suggested destination: AH")
end)

test("no retained observation withholds AH values and directs the player to the AH tab", function()
    local ui = inventory({{id=1, name="No scan", sell=100}})
    contains(ui:rows()[1].status.text, "Unavailable — no comparable retained AH value")
    local detail = ui:select(1)
    contains(detail, "AH asking / owned quantity: unavailable")
    contains(detail, "AH estimated proceeds (5% cut): unavailable")
    contains(detail, "Vendor sell / owned quantity: 100c")
    contains(detail, "Suggested destination: unavailable (both values required)")
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
    for index = 1, 3 do
        contains(rows[index].value.text, "95c")
        contains(suggested(rows[index]), "AH")
    end
    contains(rows[4].status.text, "Unavailable — observed empty supply")
end)

test("ranking compares net AH proceeds with vendor totals rather than gross asking", function()
    local ui = inventory({
        {id=1, name="Z vendor wins", sell=96},
        {id=2, name="A gross higher", sell=0},
    }, {[1]=100, [2]=101})
    contains(ui:rows()[1].label.text, "Z vendor wins")
    contains(ui:rows()[1].value.text, "96c")
    contains(suggested(ui:rows()[1]), "Vendor")
    contains(ui:rows()[2].value.text, "95c")
    contains(suggested(ui:rows()[2]), "AH")
end)


test("the window warns about the full scan strictly after the default hour", function()
    local ui = inventory({{id=1, name="AH", sell=1}}, {[1]=100})
    ui.now = 4500 -- retained source is 900
    ui:refresh()
    assert(not ui.env.CopperwiseScanWarning.shown)
    ui.now = 4501
    ui:refresh()
    assert(ui.env.CopperwiseScanWarning.shown)
    contains(ui.env.CopperwiseScanWarning.message.text, "Market scan is outdated (60 min)")
    contains(ui.env.CopperwiseScanWarning.help, "Warning threshold: 60 minutes.")
    assert(not suggested(ui:rows()[1]):find("!", 1, true))
    assert(not ui:select(1):find("Warning:", 1, true))
end)

test("stale configuration survives login and rejects invalid input without changing intent", function()
    local character = {saleIntent={[1]=3}}
    local ui = inventory({{id=1, name="AH", sell=1}}, {[1]=100}, character)
    ui:command("stale 1")
    assert(ui.env.CopperwiseScanWarning.shown)
    assert(character.staleMinutes == 1 and character.saleIntent[1] == 3)
    ui = inventory({{id=1, name="AH", sell=1}}, {[1]=100}, character)
    assert(ui.env.CopperwiseScanWarning.shown)
    for _, input in ipairs({"stale 0", "stale -1", "stale nan", "stale inf", "stale 1 extra"}) do
        ui:command(input)
        assert(character.staleMinutes == 1)
    end
    ui:command("stale 2")
    assert(not ui.env.CopperwiseScanWarning.shown)
end)

test("the shared scan warning applies with Vendor and unavailable selections", function()
    local ui = inventory({{id=1, name="Vendor", sell=100}, {id=2, name="Empty", sell=1}}, {[1]=100})
    ui.now = 10000
    ui:refresh()
    assert(ui.env.CopperwiseScanWarning.shown)
    for index, row in ipairs(ui:rows()) do
        assert(not (suggested(row) or ""):find("!", 1, true))
        assert(not ui:select(index):find("Warning:", 1, true))
    end
end)

local function choose(ui, id, destination)
    for _, row in ipairs(ui:rows()) do
        if row.itemID == id then
            local n = destination == "Keep" and 1 or destination == "Vendor" and 2 or 3
            row.actions[n].scripts.OnClick()
            return
        end
    end
    error("Missing item row")
end
local function clear(ui, label)
    for _, widget in ipairs(ui.widgets) do
        if widget.kind == "FontString" and widget.text and widget.text:find(label, 1, true) == 1 and widget.clear then
            widget.clear.scripts.OnClick()
            return
        end
    end
    error("Missing clear button")
end

test("explicit choices override estimates, switch destinations and can be cleared", function()
    local ui = inventory({{id=1, name="Ore", quantity=5, sell=1}, {id=2, name="Egg", sell=100}}, {[1]=100, [2]=1})
    choose(ui, 1, "Vendor"); choose(ui, 2, "AH")
    assert(ui.env.Copperwise.SaleIntent(1).destination == "Vendor")
    assert(ui.env.Copperwise.SaleIntent(2).destination == "AH")
    choose(ui, 1, "Keep")
    assert(not ui.env.Copperwise.SaleIntent(1))
    assert(ui.env.Copperwise.ItemChoice(1) == "Keep")
    assert(#ui:rows() == 2)
    clear(ui, "To AH")
    assert(not ui.env.Copperwise.ItemChoice(2))
    assert(ui.env.Copperwise.ItemChoice(1) == "Keep")
    choose(ui, 1, "Keep")
    assert(not ui.env.Copperwise.ItemChoice(1))
end)

test("Keep and forced sales work without a price comparison", function()
    local ui = inventory({{id=1, name="Bread", quantity=3}})
    choose(ui, 1, "Vendor")
    assert(ui.env.Copperwise.SaleIntent(1).quantity == 3)
    choose(ui, 1, "AH")
    assert(ui.env.Copperwise.SaleIntent(1).destination == "AH")
    choose(ui, 1, "Keep")
    assert(not ui.env.Copperwise.SaleIntent(1))
end)

test("character choices survive reload, keep new items excluded and add newly acquired sale units once", function()
    local character, items = {}, {{id=1, name="Bandage", quantity=4, sell=1}, {id=2, name="Ore", quantity=5, sell=1}}
    local ui = inventory(items, nil, character)
    choose(ui, 1, "Keep"); choose(ui, 2, "AH")
    ui = inventory(items, nil, character)
    assert(ui.env.Copperwise.ItemChoice(1) == "Keep")
    items[1].quantity, items[2].quantity = 8, 9
    ui:refresh(); ui:refresh()
    assert(not ui.env.Copperwise.SaleIntent(1))
    assert(ui.env.Copperwise.SaleIntent(2).quantity == 9)
    local cw = ui.env.Copperwise
    assert(cw.ConfirmPostedIntent(2, 9, 9, cw.IntentRevision(2)))
    ui:refresh()
    assert(not cw.SaleIntent(2))
    assert(cw.ItemChoice(2) == "AH")
    items[2].quantity = 1; ui:refresh()
    items[2].quantity = 4; ui:refresh(); ui:refresh()
    assert(cw.SaleIntent(2).quantity == 3)
end)

test("category clear includes absent items and leaves other categories unchanged", function()
    local items = {{id=1, name="Ore", sell=1}, {id=2, name="Bread", sell=1}}
    local ui = inventory(items)
    choose(ui, 1, "Vendor"); choose(ui, 2, "Keep")
    table.remove(items, 1); ui:refresh()
    clear(ui, "To vendor")
    assert(not ui.env.Copperwise.ItemChoice(1) and not ui.env.Copperwise.SaleIntent(1))
    assert(ui.env.Copperwise.ItemChoice(2) == "Keep")
    clear(ui, "To keep")
    assert(not ui.env.Copperwise.ItemChoice(2))
end)

test("malformed choices preserve saved data and disable editing", function()
    local bad = {version=99, items={}}
    local ui = inventory({{id=1, name="Bread", sell=1}}, nil, {itemChoices=bad})
    assert(ui.env.CopperwiseDB.itemChoices == bad)
    assert(ui.env.Copperwise.intentNotice)
    local ok = ui.env.Copperwise.SetItemChoice(1, "Keep")
    assert(not ok)
end)

test("new holdings cover retained shortages before increasing the sale queue", function()
    local items = {{id=1, name="Ore", quantity=10, sell=1}}
    local ui = inventory(items)
    choose(ui, 1, "AH")
    items[1].quantity = 2; ui:refresh()
    items[1].quantity = 7; ui:refresh()
    assert(ui.env.Copperwise.SaleIntent(1).quantity == 10)
    items[1].quantity = 12; ui:refresh()
    assert(ui.env.Copperwise.SaleIntent(1).quantity == 12)
end)

test("clearing and switching choices invalidate reviewed posting revisions", function()
    local ui = inventory({{id=1, name="Ore", quantity=5, sell=1}})
    choose(ui, 1, "AH")
    local cw = ui.env.Copperwise
    local revision = cw.IntentRevision(1)
    clear(ui, "To AH")
    choose(ui, 1, "AH")
    assert(not cw.ConfirmPostedIntent(1, 5, 5, revision))
    revision = cw.IntentRevision(1)
    choose(ui, 1, "Vendor")
    assert(not cw.ConfirmPostedIntent(1, 5, 5, revision))
    assert(cw.SaleIntent(1).quantity == 5 and cw.SaleIntent(1).destination == "Vendor")
end)

test("flat segments show recommendations only while uncategorized and one saved choice", function()
    local ui = inventory({{id=1, name="Ore", quantity=5, sell=1}}, {[1]=100})
    local row = ui:rows()[1]
    assert(row.actions[3].recommended and not row.actions[3].selected)
    choose(ui, 1, "Vendor")
    row = ui:rows()[1]
    assert(row.actions[2].selected and not row.actions[1].selected and not row.actions[3].selected)
    for _, action in ipairs(row.actions) do assert(not action.recommended) end
    choose(ui, 1, "AH")
    row = ui:rows()[1]
    assert(row.actions[3].selected and not row.actions[2].selected)
    choose(ui, 1, "AH")
    row = ui:rows()[1]
    assert(row.actions[3].recommended and not row.actions[3].selected)
end)

test("categorized icons survive removal from bags and reload without item metadata", function()
    local character, items = {}, {{id=1, name="Ore", sell=1}}
    local ui = inventory(items, nil, character)
    choose(ui, 1, "AH")
    local icon = ui:rows()[1].icon.texture
    assert(icon == 123)
    table.remove(items, 1); ui:refresh()
    assert(ui:rows()[1].icon.texture == icon)
    ui = inventory(items, nil, character)
    assert(ui:rows()[1].icon.texture == icon)
    assert(ui.env.Copperwise.SaleIntent(1).quantity == 1)
    choose(ui, 1, "Keep")
    assert(ui:rows()[1].icon.texture == icon)
end)

test("assign recommended categorizes only eligible uncategorized items", function()
    local ui = inventory({{id=1, name="Ore", sell=1}, {id=2, name="Egg", sell=200},
        {id=3, name="Unknown"}, {id=4, name="Kept", sell=1}}, {[1]=100, [2]=100, [3]=100, [4]=100})
    choose(ui, 4, "Keep")
    local assign
    for _, widget in ipairs(ui.widgets) do if widget.assign then assign = widget.assign end end
    assert(assign and assign.enabled)
    assign.scripts.OnClick()
    local cw = ui.env.Copperwise
    assert(cw.ItemChoice(1) == "AH" and cw.ItemChoice(2) == "Vendor")
    assert(cw.ItemChoice(3) == nil and cw.ItemChoice(4) == "Keep")
    assert(not assign.enabled)
    assign.scripts.OnClick()
    assert(cw.SaleIntent(1).quantity == 1)
end)

test("minimap button toggles Inventory without changing item choices", function()
    local ui = inventory({{id=1, name="Ore", sell=1}})
    choose(ui, 1, "Keep")
    local button, window = ui.env.CopperwiseMinimapButton, ui.env.CopperwiseInventory
    assert(button and window:IsShown())
    button.scripts.OnClick()
    assert(not window:IsShown())
    button.scripts.OnClick()
    assert(window:IsShown())
    assert(ui.env.Copperwise.ItemChoice(1) == "Keep")
end)

test("minimap dragging follows the rim and persists the angle across login", function()
    local character = {}
    local ui = inventory({}, nil, character)
    local button = ui.env.CopperwiseMinimapButton
    button.scripts.OnDragStart(button)
    assert(button.dragging and math.abs(character.minimapAngle) < 0.001)
    ui.cursorX, ui.cursorY = 200, 400
    button.scripts.OnUpdate(button)
    assert(math.abs(character.minimapAngle - 90) < 0.001)
    button.scripts.OnDragStop(button)
    assert(not button.dragging and not button.scripts.OnUpdate)
    ui = inventory({}, nil, character)
    assert(character.minimapAngle == 90)
    button = ui.env.CopperwiseMinimapButton
    button.scripts.OnDragStart(button)
    button.scripts.OnHide(button)
    assert(not button.scripts.OnUpdate)
end)
