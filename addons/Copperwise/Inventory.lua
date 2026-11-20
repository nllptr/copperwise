Copperwise = {}
local CW = Copperwise
local frame = CreateFrame("Frame")
local window, output, list, listContent
local quantityInput, quantityLabel, editButton, actionMessage, scanWarning
local sectionLabels = {}
local buttons = {}
local lastOrder = {}
local displayedComparisons = {}
local rows, selected, candidate, candidateAt, dirtyAt = {}, nil, nil, 0, 0
local settled, hasSnapshot = false, false
local selectedMarked = false
local holdingsDirty = true

local function visible()
    return window and window:IsShown()
end

local function needsHoldings()
    return visible() or (CW.ReviewVisible and CW.ReviewVisible())
        or (CW.PostingNeedsHoldings and CW.PostingNeedsHoldings())
end

function CW.InvalidateHoldings()
    holdingsDirty, settled, candidate, dirtyAt = true, false, nil, GetTime()
    if CW.InvalidateReview then CW.InvalidateReview() end
end

function CW.FormatMoney(value)
    if value == nil then return "unavailable" end
    if type(GetCoinTextureString) == "function" then return GetCoinTextureString(value) end
    if type(GetMoneyString) == "function" then return GetMoneyString(value) end
    local gold = math.floor(value / 10000)
    local silver = math.floor(value / 100) % 100
    local copper = value % 100
    return string.format("%dg %ds %dc", gold, silver, copper)
end
local money = CW.FormatMoney

function CW.AvailableItem(id)
    if settled and not CursorHasItem() then return rows[id] end
end

function CW.HoldingsSettled()
    return settled and not CursorHasItem()
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

local function renderScanWarning()
    local summary = CW.ScanSummary and CW.ScanSummary()
    if summary and time() - summary.observedAt > staleMinutes() * 60 then
        local age = math.max(0, math.floor((time() - summary.observedAt) / 60))
        scanWarning.message:SetText("Market scan is outdated (" .. age .. " min)")
        scanWarning.help = "All retained AH prices come from the same complete scan."
            .. "\nObserved: " .. date("%Y-%m-%d %H:%M:%S %Z", summary.observedAt)
            .. "\nMarket: " .. summary.context
            .. "\nWarning threshold: " .. staleMinutes() .. " minutes."
            .. "\nRefresh with Full scan in the Copperwise auction-house tab."
        scanWarning:Show()
    else
        scanWarning:Hide()
    end
end

local function flatButton(parent, width, height)
    local control = CreateFrame("Button", nil, parent)
    control:SetSize(width, height)
    control.border = control:CreateTexture(nil, "BACKGROUND")
    control.border:SetAllPoints()
    control.border:SetColorTexture(0.42, 0.44, 0.40, 1)
    control.fill = control:CreateTexture(nil, "BORDER")
    control.fill:SetPoint("TOPLEFT", 1, -1)
    control.fill:SetPoint("BOTTOMRIGHT", -1, 1)
    control.fill:SetColorTexture(0.16, 0.18, 0.16, 1)
    local label = control:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER")
    control:SetFontString(label)
    local hover = control:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints(); hover:SetColorTexture(1, 1, 1, 0.10)
    control:SetHighlightTexture(hover)
    return control
end

local function renderList()
    local ready = settled and not CursorHasItem()
    local choices, present = {}, {}
    if ready then displayedComparisons = {} end
    local function add(id, row)
        local destination = CW.ItemChoice and CW.ItemChoice(id)
        local intent = CW.SaleIntent and CW.SaleIntent(id)
        if not row.icon then
            local _, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(id)
            row.icon = icon
        end
        local item = withQuantity(row, row.quantity)
        choices[#choices+1] = {item=item, comparison=comparison(item), destination=destination,
            marked=intent ~= nil, identity=id .. ":item"}
        present[id] = true
    end
    for id, row in pairs(rows) do add(id, row) end
    for id, choice in pairs(CW.ItemChoices and CW.ItemChoices() or {}) do
        if not present[id] then add(id, {id=id, name=choice.name, icon=choice.icon, quantity=0, support="not currently in bags"}) end
    end
    for id, intent in pairs(CW.SaleIntents and CW.SaleIntents() or {}) do
        if not present[id] then add(id, {id=id, name=intent.name, icon=intent.icon, quantity=0, support="not currently in bags"}) end
    end
    local order = {Vendor=2, AH=3, Keep=4}
    table.sort(choices, function(a, b)
        local ai, bi = order[a.destination] or 1, order[b.destination] or 1
        if ai ~= bi then return ai < bi end
        if not ready then
            ai, bi = lastOrder[a.identity], lastOrder[b.identity]
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
    local offset, index = 0, 0
    for section, name in ipairs({"Uncategorized", "To vendor", "To AH", "To keep"}) do
        local count = 0
        for _, choice in ipairs(choices) do if (order[choice.destination] or 1) == section then count = count + 1 end end
        local heading = sectionLabels[section]
        if not heading then
            heading = listContent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            heading:SetHeight(20)
            heading:SetJustifyV("MIDDLE")
            sectionLabels[section] = heading
            if section == 1 then
                heading.assign = flatButton(listContent, 134, 20)
                heading.assign:SetText("Assign recommended")
                heading.assign:SetScript("OnClick", function()
                    if not CW.HoldingsSettled() then return end
                    local assigned = 0
                    for id, row in pairs(rows) do
                        if not CW.ItemChoice(id) then
                            local values = comparison(row)
                            if not values.reason and values.destination then
                                local ok = CW.SetItemChoice(id, values.destination)
                                if ok then assigned = assigned + 1 end
                            end
                        end
                    end
                    actionMessage = "Assigned recommendations for " .. assigned .. " item types."
                    CW.Render()
                end)
            else
                heading.clear = flatButton(listContent, 48, 20)
                local destination = ({"", "Vendor", "AH", "Keep"})[section]
                heading.clear:SetText("Clear")
                heading.clear:SetScript("OnClick", function()
                    local ok, reason = CW.ClearItemChoices(destination)
                    actionMessage = ok and ("Returned all " .. destination .. " items to Uncategorized.") or reason
                    CW.Render()
                end)
            end
        end
        heading:ClearAllPoints(); heading:SetPoint("TOPLEFT", 2, -offset)
        heading:SetText(name .. " (" .. count .. ")"); heading:Show()
        if heading.assign then
            local eligible = false
            for _, choice in ipairs(choices) do
                if not choice.destination and not choice.comparison.reason and choice.comparison.destination then eligible = true; break end
            end
            heading.assign:ClearAllPoints(); heading.assign:SetPoint("TOPRIGHT", -2, -offset)
            heading.assign:SetEnabled(eligible and ready and not CW.intentNotice); heading.assign:Show()
        end
        if heading.clear then
            heading.clear:ClearAllPoints(); heading.clear:SetPoint("TOPRIGHT", -2, -offset)
            heading.clear:SetEnabled(count > 0 and not CW.intentNotice); heading.clear:Show()
        end
        offset = offset + 26
        for _, choice in ipairs(choices) do
            if (order[choice.destination] or 1) == section then
                index = index + 1
                local button = buttons[index]
                if not button then
                    button = CreateFrame("Button", nil, listContent)
                    button:SetSize(216, 38)
                    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
                    button.icon = button:CreateTexture(nil, "ARTWORK")
                    button.icon:SetSize(22, 22); button.icon:SetPoint("TOPLEFT", 2, -3)
                    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    button.label:SetPoint("TOPLEFT", 30, -4); button.label:SetWidth(180)
                    button.label:SetWordWrap(false); button.label:SetJustifyH("LEFT")
                    button.value = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    button.value:SetPoint("TOPLEFT", 30, -21); button.value:SetWidth(80); button.value:SetJustifyH("LEFT")
                    button.status = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    button.status:SetPoint("TOPLEFT", 112, -21); button.status:SetWidth(100)
                    button.status:SetJustifyH("LEFT"); button.status:SetWordWrap(false)
                    button.actions = {}
                    for n, destination in ipairs({"Keep", "Vendor", "AH"}) do
                        local toggle = flatButton(listContent, 47, 24)
                        toggle:SetScript("OnClick", function()
                            local chosen = CW.ItemChoice(button.itemID)
                            local ok, reason = CW.SetItemChoice(button.itemID, chosen ~= destination and destination or nil)
                            actionMessage = ok and nil or reason
                            local intent = CW.SaleIntent(button.itemID)
                            if quantityInput and selected == button.itemID then
                                quantityInput:SetText(intent and tostring(intent.quantity) or ""); quantityInput:ClearFocus()
                            end
                            CW.Render()
                        end)
                        toggle:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetText(self.help); GameTooltip:Show()
                        end)
                        toggle:SetScript("OnLeave", function() GameTooltip:Hide() end)
                        button.actions[n] = toggle
                    end
                    button:SetScript("OnClick", function(self)
                        selected, selectedMarked, actionMessage = self.itemID, self.marked, nil
                        local intent = CW.SaleIntent(selected)
                        if quantityInput then quantityInput:SetText(intent and tostring(intent.quantity) or "") end
                        CW.Render()
                    end)
                    buttons[index] = button
                end
                local item, values = choice.item, choice.comparison
                local intent = CW.SaleIntent(item.id)
                button.itemID, button.marked = item.id, choice.marked
                button:ClearAllPoints(); button:SetPoint("TOPLEFT", 0, -offset)
                button.icon:SetTexture(item.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
                button.label:SetText((selected == item.id and "|cffffd100" or "") .. item.name .. " (" .. item.quantity .. ")")
                button.value:SetText(values.value ~= nil and money(values.value) or "—")
                button.status:SetText(intent and ("Sell " .. intent.quantity) or (choice.destination == "Keep" and "Kept" or (values.reason and ("Unavailable — " .. values.reason) or "")))
                for n, destination in ipairs({"Keep", "Vendor", "AH"}) do
                    local toggle = button.actions[n]
                    toggle:ClearAllPoints(); toggle:SetPoint("TOPLEFT", 220 + (n-1)*46, -offset)
                    local chosen = choice.destination == destination
                    local recommended = choice.destination == nil and values.destination == destination
                    toggle.selected, toggle.recommended = chosen, recommended
                    if chosen then
                        toggle.border:SetColorTexture(0.92, 0.76, 0.39, 1)
                        toggle.fill:SetColorTexture(0.72, 0.58, 0.28, 1)
                    elseif recommended then
                        toggle.border:SetColorTexture(0.92, 0.76, 0.39, 1)
                        toggle.fill:SetColorTexture(0.28, 0.26, 0.18, 1)
                    else
                        toggle.border:SetColorTexture(0.42, 0.44, 0.40, 1)
                        toggle.fill:SetColorTexture(0.16, 0.18, 0.16, 1)
                    end
                    toggle:SetText((chosen and "|cff171a16" or recommended and "|cffffd580" or "|cffd4d9ce") .. destination .. "|r")
                    toggle.help = chosen and (destination .. " selected. Click again to return " .. item.name .. " to Uncategorized.")
                        or (destination == "Keep" and "Keep this item type, including newly acquired quantities."
                            or ("Assign this item type to " .. destination .. ", regardless of estimated value. No sale is made."))
                    if recommended then toggle.help = "Copperwise recommends " .. destination .. ". " .. toggle.help end
                    toggle:SetEnabled(not CW.intentNotice and (chosen or ready)); toggle:Show()
                end
                button:Show(); offset = offset + 40
            end
        end
    end
    for i = index + 1, #buttons do
        buttons[i]:Hide()
        for _, toggle in ipairs(buttons[i].actions) do toggle:Hide() end
    end
    listContent:SetHeight(math.max(1, offset))
    list:SetVerticalScroll(math.min(list:GetVerticalScroll(), math.max(0, offset - list:GetHeight())))
end

function CW.Render()
    if not output or not visible() or (CW.Scanning and CW.Scanning()) then return end
    if CW.SyncItemChoices then CW.SyncItemChoices() end
    renderScanWarning()
    local intent = CW.SaleIntent and CW.SaleIntent(selected)
    local owned = rows[selected]
    local remaining = owned and owned.quantity or 0
    if selectedMarked and not intent then selectedMarked = false end
    if intent then selectedMarked = true end
    renderList()
    local item = owned
    if not item and intent then item = {id=selected, name=intent.name, icon=intent.icon, quantity=0, support="not currently in bags"} end
    if item then item = withQuantity(item, selectedMarked and intent.quantity or remaining) end
    local text = "Select a bag item from the list.\nBackpack and bags only; bank and equipment excluded."
    local values = item and comparison(item)
    if item then
        text = (item.link or item.name) .. "\nItem ID: " .. item.id
            .. "\nBag quantity (last settled): " .. (hasSnapshot and (owned and owned.quantity or 0) or "unavailable")
            .. "\nSelected quantity: " .. item.quantity .. (selectedMarked and " marked units" or " unmarked units")
            .. "\nVendor sell / unit: " .. money(item.sell)
            .. (intent and "\nVendor sell / selected quantity: " or "\nVendor sell / owned quantity: ") .. money(values.vendor)
            .. (intent and "\nAH asking / selected quantity: " or "\nAH asking / owned quantity: ") .. money(values.asking)
            .. "\nAH estimated proceeds (5% cut): " .. money(values.proceeds)
            .. "\nSuggested destination: " .. (values.destination or "unavailable (both values required)")
            .. "\nSupport: " .. item.support
    end
    if intent then
        local available = hasSnapshot and (rows[selected] and rows[selected].quantity or 0)
        text = text .. "\n\nSale intent: " .. intent.destination .. " — " .. intent.quantity .. " units"
            .. "\nCurrently available in bags: " .. (available or "unavailable")
            .. "\nCovered intent: " .. (available and math.min(available, intent.quantity) or "unavailable")
            .. "\nShortage: " .. (available and math.max(0, intent.quantity - available) or "unavailable")
        if intent.destination == "Vendor" then text = text .. "\nSell with the normal merchant UI; remove intent explicitly." end
    end
    local choice = CW.ItemChoice and CW.ItemChoice(selected)
    if choice then text = text .. "\nItem choice: " .. choice .. " (this character; applies to newly acquired quantities)" end
    if CW.intentNotice then text = text .. "\n" .. CW.intentNotice end
    if actionMessage then text = text .. "\n" .. actionMessage end
    if quantityInput then
        if intent and selectedMarked then
            quantityLabel:Show(); quantityInput:Show(); editButton:Show()
        else
            quantityLabel:Hide(); quantityInput:Hide(); editButton:Hide()
        end
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
        scanWarning = CreateFrame("Button", "CopperwiseScanWarning", window)
        scanWarning:SetSize(360, 24)
        scanWarning:SetPoint("TOPLEFT", 22, -33)
        scanWarning.icon = scanWarning:CreateTexture(nil, "ARTWORK")
        scanWarning.icon:SetSize(22, 22)
        scanWarning.icon:SetPoint("LEFT", 0, 0)
        scanWarning.icon:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
        scanWarning.message = scanWarning:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        scanWarning.message:SetPoint("LEFT", 28, 0)
        scanWarning:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.help)
            GameTooltip:Show()
        end)
        scanWarning:SetScript("OnLeave", function() GameTooltip:Hide() end)
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

local function createMinimapButton()
    if not Minimap or CW.minimapButton then return end
    local button = CreateFrame("Button", "CopperwiseMinimapButton", Minimap)
    button:SetSize(32, 32)
    local angle = type(CopperwiseDB) == "table" and CopperwiseDB.minimapAngle or 225
    if type(angle) ~= "number" or angle ~= angle or math.abs(angle) == math.huge then angle = 225 end
    local function position()
        local x, y = math.cos(math.rad(angle)), math.sin(math.rad(angle))
        if GetMinimapShape and GetMinimapShape() == "SQUARE" then
            local edge = math.max(math.abs(x), math.abs(y))
            x, y = x / edge, y / edge
        end
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", x * (Minimap:GetWidth()/2 + 5), y * (Minimap:GetHeight()/2 + 5))
    end
    local function drag()
        local mx, my = Minimap:GetCenter()
        if not mx or not my then return end
        local x, y = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        x, y = x/scale - mx, y/scale - my
        if x == 0 and y == 0 then return end
        angle = math.deg(math.atan2(y, x)) % 360
        if type(CopperwiseDB) == "table" then CopperwiseDB.minimapAngle = angle end
        position()
    end
    local function stop(self)
        self:SetScript("OnUpdate", nil)
        self.dragging = nil
    end
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self)
        self.dragging = true
        if GameTooltip then GameTooltip:Hide() end
        self:SetScript("OnUpdate", drag)
        drag()
    end)
    button:SetScript("OnDragStop", stop)
    button:SetScript("OnHide", stop)
    Minimap:HookScript("OnSizeChanged", position)
    position()
    button:SetFrameStrata("MEDIUM")
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("TOPLEFT", 7, -5)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Coin_01")
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    button:SetScript("OnClick", function(self)
        if self and self.dragging then return end
        if window and window:IsShown() then window:Hide() else open() end
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("Copperwise")
        GameTooltip:AddLine("Click to open or close Inventory.", 1, 1, 1)
        GameTooltip:AddLine("Drag to move around the minimap.", 0.75, 0.75, 0.75)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    CW.minimapButton = button
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
    if event == "PLAYER_LOGIN" then createMinimapButton() end
    CW.InvalidateHoldings()
end)
local elapsed, warningElapsed = 0, 0
frame:SetScript("OnUpdate", function(_, dt)
    if not needsHoldings() then return end
    warningElapsed = warningElapsed + dt
    if warningElapsed >= 1 then
        warningElapsed = 0
        if visible() and not (CW.Scanning and CW.Scanning()) then renderScanWarning() end
    end
    if not holdingsDirty then return end
    elapsed = elapsed + dt
    if elapsed < 0.25 then return end
    elapsed = 0
    local signature, nextRows = snapshot()
    if not signature then
        settled, candidate = false, nil
    elseif signature ~= candidate then
        settled, candidate, candidateAt = false, signature, GetTime()
    elseif GetTime() - candidateAt >= 0.75 and GetTime() - dirtyAt >= 0.75 then
        rows, settled, hasSnapshot = nextRows, true, true
        holdingsDirty = false
        if CW.SyncItemChoices then CW.SyncItemChoices() end
        CW.Render()
        if CW.InvalidateReview then CW.InvalidateReview() end
    end
end)
