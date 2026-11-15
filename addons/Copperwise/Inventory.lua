Copperwise = {}
local CW = Copperwise
local frame = CreateFrame("Frame")
local window, output, list, listContent
local markButton, quantityInput, addButton, editButton, removeButton, actionMessage
local sectionLabels = {}
local buttons = {}
local lastOrder = {}
local displayedComparisons = {}
local rows, selected, candidate, candidateAt, dirtyAt = {}, nil, nil, 0, 0
local settled = false

local function money(value)
    if value == nil then return "unavailable" end
    if type(GetCoinTextureString) == "function" then return GetCoinTextureString(value) end
    if type(GetMoneyString) == "function" then return GetMoneyString(value) end
    local gold = math.floor(value / 10000)
    local silver = math.floor(value / 100) % 100
    local copper = value % 100
    return string.format("%dg %ds %dc", gold, silver, copper)
end

function CW.SelectedItem()
    if settled and not CursorHasItem() then return rows[selected] end
end

local function comparison(item)
    local ready = settled and not CursorHasItem()
    if not ready and displayedComparisons[item.id] then return displayedComparisons[item.id] end
    local observation = CW.ObservationFor and CW.ObservationFor(item.id)
    local asking, proceeds, vendor, destination, value
    -- Display the last settled holdings during bag/cursor activity. Actions
    -- must use SelectedItem(), which remains unavailable until holdings settle.
    if observation and observation.minimum ~= nil then asking = observation.minimum * item.quantity end
    if asking ~= nil then proceeds = math.floor(asking * 95 / 100) end
    if item.sell ~= nil then vendor = item.sell * item.quantity end
    if proceeds ~= nil and vendor ~= nil then
        destination = proceeds > vendor and "AH" or "Vendor"
        value = math.max(proceeds, vendor)
    end
    local reason
    if item.support ~= "comparable commodity" then reason = item.support
    elseif asking == nil then
        reason = observation and (observation.empty and "observed empty supply" or "asking price unavailable")
            or "no comparable retained AH value"
    elseif vendor == nil then reason = "vendor metadata loading" end
    local values = {observation=observation, asking=asking, proceeds=proceeds, vendor=vendor, destination=destination, value=value, reason=reason}
    if ready then displayedComparisons[item.id] = values end
    return values
end

-- Re-evaluate against wall time even when holdings/comparisons are retained.
local function staleMinutes()
    local minutes = type(CopperwiseDB) == "table" and CopperwiseDB.staleMinutes
    if type(minutes) ~= "number" or minutes <= 0 or minutes ~= minutes or minutes == math.huge then return 60 end
    return minutes
end

local function stale(values)
    return values.destination == "AH" and values.observation
        and time() - values.observation.observedAt > staleMinutes() * 60
end

local function renderList()
    local ready = settled and not CursorHasItem()
    local choices = {}
    for _, row in pairs(rows) do
        choices[#choices+1] = {item=row, comparison=comparison(row)}
    end
    for id, intent in pairs(CW.SaleIntents and CW.SaleIntents() or {}) do
        if not rows[id] then
            local item = {id=id, name=intent.name, quantity=0, support="not currently in bags"}
            choices[#choices+1] = {item=item, comparison={reason="not currently in bags"}}
        end
    end
    table.sort(choices, function(a, b)
        local am = CW.SaleIntent and CW.SaleIntent(a.item.id) ~= nil
        local bm = CW.SaleIntent and CW.SaleIntent(b.item.id) ~= nil
        if am ~= bm then return am end
        -- Keep the last settled order throughout bag/cursor activity.
        if not ready then
            local ai, bi = lastOrder[a.item.id], lastOrder[b.item.id]
            if ai ~= bi then return (ai or math.huge) < (bi or math.huge) end
        end
        local av, bv = a.comparison.value, b.comparison.value
        if (av ~= nil) ~= (bv ~= nil) then return av ~= nil end
        if av ~= bv then return av > bv end
        if a.item.name ~= b.item.name then return a.item.name < b.item.name end
        return a.item.id < b.item.id
    end)
    if ready then
        lastOrder = {}
        for index, choice in ipairs(choices) do lastOrder[choice.item.id] = index end
        for id in pairs(displayedComparisons) do
            if not rows[id] then displayedComparisons[id] = nil end
        end
    end
    local height = #choices * 54 + 48
    listContent:SetHeight(math.max(1, height))
    local maxScroll = math.max(0, height - list:GetHeight())
    list:SetVerticalScroll(math.min(list:GetVerticalScroll(), maxScroll))
    local offset, previousSection, sections = 0, nil, 0
    for index, choice in ipairs(choices) do
        local intent = CW.SaleIntent and CW.SaleIntent(choice.item.id)
        local section = intent and "Marked for sale" or "Unmarked inventory"
        if section ~= previousSection then
            sections = sections + 1
            local label = sectionLabels[sections]
            if not label then
                label = listContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                sectionLabels[sections] = label
            end
            label:SetPoint("TOPLEFT", 2, -offset)
            label:SetText(section)
            label:Show()
            offset = offset + 24
            previousSection = section
        end
        local button = buttons[index]
        if not button then
            button = CreateFrame("Button", nil, listContent)
            button:SetSize(330, 52)
            button:SetPoint("TOPLEFT", 0, -(index - 1) * 54)
            button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            button.icon = button:CreateTexture(nil, "ARTWORK")
            button.icon:SetSize(28, 28)
            button.icon:SetPoint("LEFT", 2, 0)
            button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            button.label:SetPoint("TOPLEFT", 36, -4)
            button.label:SetWidth(290)
            button.label:SetJustifyH("LEFT")
            button.value = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            button.value:SetPoint("TOPLEFT", 36, -25)
            button.value:SetWidth(290)
            button.value:SetJustifyH("LEFT")
            button:SetScript("OnClick", function(self)
                selected = self.itemID
                actionMessage = nil
                local intent = CW.SaleIntent and CW.SaleIntent(selected)
                if quantityInput then quantityInput:SetText(intent and tostring(intent.quantity) or "") end
                CW.Render()
            end)
            buttons[index] = button
        end
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", 0, -offset)
        offset = offset + 54
        local item, values = choice.item, choice.comparison
        button.itemID = item.id
        button.icon:SetTexture(item.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        button.label:SetText((selected == item.id and "|cffffd100" or "") .. item.name
            .. " (" .. item.quantity .. ")")
        button.value:SetText(intent and (intent.destination .. " — intended " .. intent.quantity
            .. "; bags " .. (ready and item.quantity or "checking")) or (values.value ~= nil and (money(values.value) .. " — " .. values.destination .. (stale(values) and " (stale price)" or ""))
            or ("Unavailable — " .. values.reason)))
        button:Show()
    end
    for index = sections + 1, #sectionLabels do sectionLabels[index]:Hide() end
    for index = #choices + 1, #buttons do buttons[index]:Hide() end
end

function CW.Render()
    if not output then return end
    renderList()
    local intent = CW.SaleIntent and CW.SaleIntent(selected)
    local item = rows[selected]
    if not item and intent then item = {id=selected, name=intent.name, quantity=0, support="not currently in bags"} end
    local text = "Select a bag item from the list.\nBackpack and bags only; bank and equipment excluded."
    local values = item and comparison(item)
    if item then
        text = (item.link or item.name) .. "\nItem ID: " .. item.id
            .. "\nBag quantity (last settled): " .. item.quantity
            .. "\nVendor sell / unit: " .. money(item.sell)
            .. "\nVendor sell / owned quantity: " .. money(values.vendor)
            .. "\nAH asking / owned quantity: " .. money(values.asking)
            .. "\nAH estimated proceeds (5% cut): " .. money(values.proceeds)
            .. "\nPreferred destination: " .. (values.destination or "unavailable (both values required)")
            .. "\nSupport: " .. item.support
    end
    if intent then
        local available = settled and not CursorHasItem() and (rows[selected] and rows[selected].quantity or 0)
        text = text .. "\n\nSale intent: " .. intent.destination .. " — " .. intent.quantity .. " units"
            .. "\nCurrently available in bags: " .. (available or "checking")
            .. "\nCovered intent: " .. (available and math.min(available, intent.quantity) or "checking")
            .. "\nShortage: " .. (available and math.max(0, intent.quantity - available) or "checking")
        if intent.destination == "Vendor" then text = text .. "\nSell with the normal merchant UI; remove intent explicitly." end
    end
    if CW.intentNotice then text = text .. "\n" .. CW.intentNotice end
    if actionMessage then text = text .. "\n" .. actionMessage end
    if markButton then
        local actionable = CW.SelectedItem()
        local destination = actionable and values and not values.reason and values.destination
        if destination and not intent then
            markButton:SetText("Sell on " .. destination .. (stale(values) and " (stale price)" or ""))
            markButton:Show()
        else markButton:Hide() end
        if actionable and intent then addButton:Show() else addButton:Hide() end
        if intent then
            quantityInput:Show(); editButton:Show(); removeButton:Show()
        else
            quantityInput:Hide(); editButton:Hide(); removeButton:Hide()
        end
    end
    if values and stale(values) then
        text = text .. "\nWarning: AH price exceeds the stale threshold (" .. staleMinutes() .. " minutes)."
    end
    local observation = values and values.observation
    if observation then
        text = text .. "\n\nRetained full-scan observation"
            .. "\nLowest observed asking / unit: " .. money(observation.minimum)
            .. "\nAvailable supply: " .. observation.units
            .. "\nCoverage: complete market summary" .. (observation.empty and " (item absent)" or "")
            .. "\nObserved locally: " .. date("%Y-%m-%d %H:%M:%S %Z", observation.observedAt)
            .. "\nAge: " .. math.max(0, math.floor((time() - observation.observedAt) / 60)) .. " minutes"
            .. "\nMarket: " .. observation.context
    else
        text = text .. "\n\nAH values unavailable for this selection."
    end
    if CW.attempt then
        text = text .. "\n\nLatest full scan: " .. CW.attempt.state .. "\n" .. CW.attempt.reason
    else
        text = text .. "\n\nNo scan attempted this session."
    end
    text = text .. "\n\nRefresh market data with Full scan in the Copperwise auction-house tab."
        .. "\nFaction AH only. AH estimates deduct 5%; deposits excluded."
        .. "\nRetained asking values are not live prices or completed sales."
    output:SetText(text)
end

local function snapshot()
    local nextRows, signature, locked = {}, {}, CursorHasItem()
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info then
                local id = info.itemID
                if not id or type(info.stackCount) ~= "number" then return nil end
                locked = locked or info.isLocked
                signature[#signature+1] = bag .. ":" .. slot .. ":" .. id .. ":" .. info.stackCount
                local row = nextRows[id] or {id=id, quantity=0, link=info.hyperlink}
                row.quantity = row.quantity + info.stackCount
                local name, _, _, _, _, _, _, _, _, icon, sell = C_Item.GetItemInfo(id)
                row.name, row.sell, row.icon = name or ("Item " .. id), sell, icon or info.iconFileID
                row.support = "metadata loading"
                if C_AuctionHouse and C_AuctionHouse.MakeItemKey and C_AuctionHouse.GetItemKeyInfo then
                    local key = C_AuctionHouse.MakeItemKey(id, 0, 0, 0)
                    local keyInfo = C_AuctionHouse.GetItemKeyInfo(key)
                    if keyInfo and type(keyInfo.isCommodity) == "boolean" then
                        row.support = keyInfo.isCommodity and "comparable commodity" or "unsupported (noncommodity)"
                    end
                end
                nextRows[id] = row
            end
        end
    end
    if locked then return nil end
    return table.concat(signature, "|"), nextRows
end

local function open()
    if not window then
        window = CreateFrame("Frame", "CopperwiseInventory", UIParent, "BasicFrameTemplateWithInset")
        window:SetSize(920, 760)
        window:SetPoint("CENTER")
        window:SetMovable(true)
        window:EnableMouse(true)
        window:RegisterForDrag("LeftButton")
        window:SetScript("OnDragStart", window.StartMoving)
        window:SetScript("OnDragStop", window.StopMovingOrSizing)
        window.TitleText:SetText("Copperwise — Inventory")
        table.insert(UISpecialFrames, "CopperwiseInventory")
        -- Keep a plain gray inset behind the native controls.
        local surface = window.Inset or window
        local background = surface:CreateTexture(nil, "BORDER", nil, -1)
        background:SetPoint("TOPLEFT", window, "TOPLEFT", 6, -28)
        background:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -6, 6)
        background:SetColorTexture(0.24, 0.24, 0.24, 1)
        list = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
        list:SetPoint("TOPLEFT", 22, -65)
        list:SetPoint("BOTTOMLEFT", 22, 25)
        list:SetWidth(330)
        listContent = CreateFrame("Frame", nil, list)
        listContent:SetSize(330, 1)
        list:SetScrollChild(listContent)
        output = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        output:SetPoint("TOPLEFT", 395, -40)
        output:SetPoint("BOTTOMRIGHT", -22, 115)
        output:SetJustifyH("LEFT")
        output:SetJustifyV("TOP")
        local function change(action, quantity, destination)
            local ok, reason = CW.ChangeIntent(selected, action, quantity, destination)
            actionMessage = ok and nil or reason
            local intent = CW.SaleIntent(selected)
            quantityInput:SetText(intent and tostring(intent.quantity) or "")
            quantityInput:ClearFocus()
            CW.Render()
        end
        local function button(label, x, y, width, click)
            local control = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
            control:SetSize(width, 24)
            control:SetPoint("BOTTOMLEFT", x, y)
            control:SetText(label)
            control:SetScript("OnClick", click)
            return control
        end
        markButton = button("", 395, 77, 270, function()
            local item = CW.SelectedItem()
            if not item then return end
            local values = comparison(item)
            if not values.reason then change("add", item.quantity, values.destination) end
        end)
        quantityInput = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
        quantityInput:SetSize(90, 24)
        quantityInput:SetPoint("BOTTOMLEFT", 402, 43)
        quantityInput:SetAutoFocus(false)
        quantityInput:SetMaxLetters(10)
        quantityInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        editButton = button("Set units", 505, 43, 95, function() change("edit", tonumber(quantityInput:GetText())) end)
        removeButton = button("Remove mark", 610, 43, 120, function() change("remove") end)
        addButton = button("Add bag units", 675, 77, 140, function()
            local item = CW.SelectedItem()
            local intent = CW.SaleIntent(selected)
            if item and intent then change("add", item.quantity, intent.destination) end
        end)
    end
    window:Show()
    CW.Render()
end

SLASH_COPPERWISE1 = "/copperwise"
SLASH_COPPERWISE2 = "/cw"
SlashCmdList.COPPERWISE = function(message)
    message = message or ""
    if message:match("^%s*stale") then
        local value = tonumber(message:match("^%s*stale%s+(%S+)%s*$"))
        if value and value > 0 and value < math.huge then
            if CopperwiseDB == nil then CopperwiseDB = {} end
            if type(CopperwiseDB) ~= "table" then
                print("Copperwise: Character settings unavailable; saved data preserved.")
                return
            end
            CopperwiseDB.staleMinutes = value
            CW.Render()
        else
            print("Copperwise: Use /cw stale <positive minutes>.")
        end
        print("Copperwise: Stale-price threshold: " .. staleMinutes() .. " minutes (this character).")
        return
    end
    open()
end
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("ITEM_LOCK_CHANGED")
frame:RegisterEvent("CURSOR_CHANGED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:SetScript("OnEvent", function(_, event)
    if event ~= "GET_ITEM_INFO_RECEIVED" then
        settled, candidate, dirtyAt = false, nil, GetTime()
    end
    CW.Render()
end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, dt)
    elapsed = elapsed + dt
    if elapsed < 0.25 then return end
    elapsed = 0
    local signature, nextRows = snapshot()
    if not signature then
        settled, candidate = false, nil
    elseif signature ~= candidate then
        settled, candidate, candidateAt = false, signature, GetTime()
    elseif GetTime() - candidateAt >= 0.75 and GetTime() - dirtyAt >= 0.75 then
        rows, settled = nextRows, true
    end
    CW.Render()
end)
