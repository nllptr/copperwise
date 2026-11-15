Copperwise = {}
local CW = Copperwise
local frame = CreateFrame("Frame")
local window, output, list, listContent
local quantityInput, quantityLabel, editButton, actionMessage
local sectionLabels = {}
local buttons = {}
local lastOrder = {}
local displayedComparisons = {}
local rows, selected, candidate, candidateAt, dirtyAt = {}, nil, nil, 0, 0
local settled = false
local selectedMarked = false

local function money(value)
    if value == nil then return "unavailable" end
    if type(GetCoinTextureString) == "function" then return GetCoinTextureString(value) end
    if type(GetMoneyString) == "function" then return GetMoneyString(value) end
    local gold = math.floor(value / 10000)
    local silver = math.floor(value / 100) % 100
    local copper = value % 100
    return string.format("%dg %ds %dc", gold, silver, copper)
end

function CW.AvailableItem(id)
    if settled and not CursorHasItem() then return rows[id] end
end

function CW.SelectedItem()
    return CW.AvailableItem(selected)
end

local function withQuantity(item, quantity)
    return {id=item.id, name=item.name, quantity=quantity, sell=item.sell,
        icon=item.icon, link=item.link, support=item.support}
end

local function comparison(item)
    local ready = settled and not CursorHasItem()
    local identity = item.id .. ":" .. item.quantity
    if not ready and displayedComparisons[identity] then return displayedComparisons[identity] end
    local observation = CW.ObservationFor and CW.ObservationFor(item.id)
    local asking, proceeds, vendor, destination, value
    -- Display the last settled holdings during bag/cursor activity. Actions
    -- must use AvailableItem(), which remains unavailable until holdings settle.
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
    if ready then displayedComparisons[identity] = values end
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
    if ready then displayedComparisons = {} end
    for id, row in pairs(rows) do
        local intent = CW.SaleIntent and CW.SaleIntent(id)
        local remaining = math.max(0, row.quantity - (intent and intent.quantity or 0))
        if remaining > 0 then
            local item = withQuantity(row, remaining)
            choices[#choices+1] = {item=item, comparison=comparison(item), marked=false, identity=id .. ":inventory"}
        end
        if intent then
            local item = withQuantity(row, intent.quantity)
            choices[#choices+1] = {item=item, comparison=comparison(item), marked=true, identity=id .. ":marked"}
        end
    end
    for id, intent in pairs(CW.SaleIntents and CW.SaleIntents() or {}) do
        if not rows[id] then
            local item = {id=id, name=intent.name, quantity=intent.quantity, support="not currently in bags"}
            choices[#choices+1] = {item=item, comparison=comparison(item), marked=true, identity=id .. ":marked"}
        end
    end
    table.sort(choices, function(a, b)
        if a.marked ~= b.marked then return b.marked end
        -- Keep the last settled order throughout bag/cursor activity.
        if not ready then
            local ai, bi = lastOrder[a.identity], lastOrder[b.identity]
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
        for index, choice in ipairs(choices) do lastOrder[choice.identity] = index end
    end
    local height = #choices * 40 + 48
    listContent:SetHeight(math.max(1, height))
    local maxScroll = math.max(0, height - list:GetHeight())
    list:SetVerticalScroll(math.min(list:GetVerticalScroll(), maxScroll))
    local offset, previousSection, sections = 0, nil, 0
    for index, choice in ipairs(choices) do
        local intent = CW.SaleIntent and CW.SaleIntent(choice.item.id)
        local section = choice.marked and "Marked for sale" or "Unmarked inventory"
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
            button:SetSize(280, 38)
            button:SetPoint("TOPLEFT", 0, -(index - 1) * 40)
            button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
            button.icon = button:CreateTexture(nil, "ARTWORK")
            button.icon:SetSize(22, 22)
            button.icon:SetPoint("TOPLEFT", 2, -3)
            button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            button.label:SetPoint("TOPLEFT", 30, -4)
            button.label:SetWidth(145)
            button.label:SetWordWrap(false)
            button.label:SetJustifyH("LEFT")
            button.value = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            button.value:SetPoint("TOPRIGHT", -2, -4)
            button.value:SetWidth(100)
            button.value:SetJustifyH("RIGHT")
            button.status = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            button.status:SetPoint("TOPLEFT", 30, -21)
            button.status:SetWidth(248)
            button.status:SetJustifyH("LEFT")
            button.status:SetWordWrap(false)
            button.toggle = CreateFrame("Button", nil, listContent, "UIPanelButtonTemplate")
            button.toggle:SetSize(72, 26)
            button.toggle:SetScript("OnClick", function()
                local id = button.itemID
                local intent = CW.SaleIntent(id)
                local ok, reason
                if button.marked then
                    ok, reason = CW.ChangeIntent(id, "remove")
                else
                    local item = CW.AvailableItem(id)
                    if not item then return end
                    local remaining = math.max(0, item.quantity - (intent and intent.quantity or 0))
                    if remaining == 0 then return end
                    local values = comparison(withQuantity(item, remaining))
                    if values.reason or not values.destination then return end
                    ok, reason = CW.ChangeIntent(id, "mark", remaining, intent and intent.destination or values.destination)
                end
                actionMessage = ok and nil or reason
                if selected == id then
                    local entry = CW.SaleIntent(id)
                    quantityInput:SetText(entry and tostring(entry.quantity) or "")
                    quantityInput:ClearFocus()
                end
                CW.Render()
            end)
            button.toggle:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.help)
                GameTooltip:Show()
            end)
            button.toggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
            button:SetScript("OnClick", function(self)
                selected = self.itemID
                selectedMarked = self.marked
                actionMessage = nil
                local intent = CW.SaleIntent and CW.SaleIntent(selected)
                if quantityInput then quantityInput:SetText(intent and tostring(intent.quantity) or "") end
                CW.Render()
            end)
            buttons[index] = button
        end
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT", 0, -offset)
        button.toggle:ClearAllPoints()
        button.toggle:SetPoint("TOPLEFT", 284, -offset)
        offset = offset + 40
        local item, values = choice.item, choice.comparison
        button.itemID, button.marked = item.id, choice.marked
        button.icon:SetTexture(item.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        button.label:SetText((selected == item.id and selectedMarked == choice.marked and "|cffffd100" or "") .. item.name
            .. " (" .. item.quantity .. ")")
        button.value:SetText(values.value ~= nil and money(values.value) or "—")
        local bagQuantity = rows[item.id] and rows[item.id].quantity or 0
        button.status:SetText(choice.marked and ("Sell " .. intent.quantity .. "; bags "
            .. (ready and bagQuantity or "checking")
            .. (ready and bagQuantity < intent.quantity and ("; short " .. (intent.quantity - bagQuantity)) or ""))
            or (values.reason and ("Unavailable — " .. values.reason) or (intent and "Unmarked remainder" or "")))
        local destination = intent and intent.destination or values.destination
        local oldPrice = destination == "AH" and values.observation
            and time() - values.observation.observedAt > staleMinutes() * 60
        if choice.marked or (ready and not values.reason and destination) then
            button.toggle:SetText((destination == "AH" and "|cffffd100" or "|cff99ddaa")
                .. destination .. (choice.marked and " ×" or (intent and " +" or "")) .. (oldPrice and " !" or "") .. "|r")
            button.toggle.help = choice.marked and ("Unmark " .. item.name .. " from " .. destination .. ". No sale is made.")
                or ((intent and "Add " or "Mark ") .. item.quantity .. " units of " .. item.name
                    .. " for " .. destination .. ". No sale is made.")
            if oldPrice then button.toggle.help = button.toggle.help .. " AH price exceeds " .. staleMinutes() .. " minutes." end
            button.toggle:Show()
        else button.toggle:Hide() end
        button:Show()
    end
    for index = sections + 1, #sectionLabels do sectionLabels[index]:Hide() end
    for index = #choices + 1, #buttons do buttons[index]:Hide(); buttons[index].toggle:Hide() end
end

function CW.Render()
    if not output then return end
    local intent = CW.SaleIntent and CW.SaleIntent(selected)
    local owned = rows[selected]
    local remaining = math.max(0, (owned and owned.quantity or 0) - (intent and intent.quantity or 0))
    if selectedMarked and not intent then selectedMarked = false end
    if intent and remaining == 0 then selectedMarked = true end
    renderList()
    local item = owned
    if not item and intent then item = {id=selected, name=intent.name, quantity=0, support="not currently in bags"} end
    if item then item = withQuantity(item, selectedMarked and intent.quantity or remaining) end
    local text = "Select a bag item from the list.\nBackpack and bags only; bank and equipment excluded."
    local values = item and comparison(item)
    if item then
        text = (item.link or item.name) .. "\nItem ID: " .. item.id
            .. "\nBag quantity (last settled): " .. (owned and owned.quantity or 0)
            .. "\nSelected quantity: " .. item.quantity .. (selectedMarked and " marked units" or " unmarked units")
            .. "\nVendor sell / unit: " .. money(item.sell)
            .. (intent and "\nVendor sell / selected quantity: " or "\nVendor sell / owned quantity: ") .. money(values.vendor)
            .. (intent and "\nAH asking / selected quantity: " or "\nAH asking / owned quantity: ") .. money(values.asking)
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
    if quantityInput then
        if intent and selectedMarked then
            quantityLabel:Show(); quantityInput:Show(); editButton:Show()
        else
            quantityLabel:Hide(); quantityInput:Hide(); editButton:Hide()
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
        window:SetSize(960, 760)
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
        list:SetWidth(360)
        listContent = CreateFrame("Frame", nil, list)
        listContent:SetSize(360, 1)
        list:SetScrollChild(listContent)
        output = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        output:SetPoint("TOPLEFT", 425, -40)
        output:SetPoint("BOTTOMRIGHT", -22, 80)
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
        quantityLabel = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        quantityLabel:SetPoint("BOTTOMLEFT", 425, 52)
        quantityLabel:SetText("Units to sell")
        quantityInput = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
        quantityInput:SetSize(90, 24)
        quantityInput:SetPoint("BOTTOMLEFT", 432, 23)
        quantityInput:SetAutoFocus(false)
        quantityInput:SetMaxLetters(10)
        quantityInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        editButton = button("Save quantity", 535, 23, 130, function() change("edit", tonumber(quantityInput:GetText())) end)
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
