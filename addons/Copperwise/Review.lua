local CW = Copperwise
local panel, content, summary, durationButton
local widgets, edits = {}, {}
local duration = 3 -- Target client: 2 / 8 / 24 hours, not retail durations.
local hours = {2, 8, 24}
local elapsed = 0

local function money(value)
    if value == nil then return "unavailable" end
    return GetCoinTextureString(value)
end

local function whole(value)
    return type(value) == "number" and value > 0 and value <= 2147483647 and value % 1 == 0
end

local function native(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, ...)
    if ok then return value end
end

-- Preparation is ephemeral. It never changes saved intent or invokes posting.
local function prepare(id, intent)
    local row = {id=id, name=intent.name, intended=intent.quantity, stacks={}, eligible=0}
    local observation = CW.ObservationFor(id)
    row.price = edits[id] or (observation and observation.minimum)
    row.observedAt = observation and observation.observedAt
    if not whole(row.price) then row.price = nil end
    local item = CW.AvailableItem(id)
    if not CW.HoldingsSettled() then row.reason = "Bag holdings are settling"
    elseif not item then row.reason = "Not currently in bags"
    elseif item.support ~= "comparable commodity" then row.reason = item.support
    else
        row.name = item.name
        local remaining = intent.quantity
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if remaining > 0 and info and info.itemID == id and not info.isLocked then
                    local location = ItemLocation:CreateFromBagAndSlot(bag, slot)
                    local valid = native(C_AuctionHouse.IsSellItemValid, location, false)
                    local status = native(C_AuctionHouse.GetItemCommodityStatus, location)
                    if valid and status == Enum.ItemCommodityStatus.Commodity then
                        local units = math.min(remaining, info.stackCount)
                        local deposit = native(C_AuctionHouse.CalculateCommodityDeposit, id, duration, units)
                        if type(deposit) ~= "number" or deposit < 0 or deposit % 1 ~= 0 then deposit = nil end
                        row.stacks[#row.stacks+1] = {bag=bag, slot=slot, location=location,
                            itemID=id, link=info.hyperlink, count=info.stackCount,
                            quantity=units, price=row.price, duration=duration, deposit=deposit}
                        row.eligible = row.eligible + units
                        remaining = remaining - units
                    end
                end
            end
        end
        if row.eligible == 0 then row.reason = "No supported sellable source stacks" end
    end
    row.shortage = item and math.max(0, intent.quantity - item.quantity) or nil
    if CW.HoldingsSettled() and not item then row.shortage = intent.quantity end
    row.deposit = #row.stacks > 0 and 0 or nil
    for _, stack in ipairs(row.stacks) do
        if stack.deposit == nil then row.deposit = nil; break end
        row.deposit = row.deposit + stack.deposit
    end
    if not row.reason and not row.price then row.reason = "Unit buyout unavailable; enter copper or run Full scan" end
    if not row.reason and row.deposit == nil then row.reason = "Native deposit unavailable" end
    if not row.reason and row.deposit > GetMoney() then row.reason = "Insufficient money for deposit" end
    row.ready = row.reason == nil and row.eligible > 0
    return row
end

local function label(parent, x, y, width, template)
    local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", x, y); text:SetWidth(width); text:SetJustifyH("LEFT")
    return text
end

function CW.RenderReview()
    if not panel or not panel:IsShown() then return end
    local rows, present = {}, {}
    for id, intent in pairs(CW.SaleIntents()) do
        if intent.destination == "AH" then
            present[id] = true
            rows[#rows+1] = prepare(id, intent)
        end
    end
    for id in pairs(edits) do if not present[id] then edits[id] = nil end end
    table.sort(rows, function(a,b) if a.name ~= b.name then return a.name < b.name end; return a.id < b.id end)
    local intended, eligible, ready, pending, gross, deposits, unknownPrice, unknownDeposit = 0, 0, 0, 0, 0, 0, 0, 0
    for index, row in ipairs(rows) do
        intended, eligible = intended + row.intended, eligible + row.eligible
        if row.ready then ready = ready + 1 end
        if not row.ready or row.eligible < row.intended then pending = pending + 1 end
        if row.eligible > 0 then
            if row.price then gross = gross + row.price * row.eligible else unknownPrice = unknownPrice + 1 end
            if row.deposit ~= nil then deposits = deposits + row.deposit else unknownDeposit = unknownDeposit + 1 end
        end
        local widget = widgets[index]
        if not widget then
            widget = CreateFrame("Frame", nil, content)
            widget:SetSize(650, 90)
            widget.title = label(widget, 0, -2, 620, "GameFontNormal")
            widget.terms = label(widget, 0, -22, 620)
            widget.state = label(widget, 0, -42, 620)
            widget.inputLabel = label(widget, 0, -65, 125)
            widget.inputLabel:SetText("Unit buyout (copper)")
            widget.input = CreateFrame("EditBox", nil, widget, "InputBoxTemplate")
            widget.input:SetSize(110, 20); widget.input:SetPoint("TOPLEFT", 135, -62)
            widget.input:SetAutoFocus(false); widget.input:SetMaxLetters(10)
            widget.input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
            widget.save = CreateFrame("Button", nil, widget, "UIPanelButtonTemplate")
            widget.save:SetSize(70, 22); widget.save:SetPoint("TOPLEFT", 255, -62); widget.save:SetText("Apply")
            widget.reset = CreateFrame("Button", nil, widget, "UIPanelButtonTemplate")
            widget.reset:SetSize(110, 22); widget.reset:SetPoint("TOPLEFT", 335, -62); widget.reset:SetText("Use scan price")
            widgets[index] = widget
        end
        if widget.id ~= row.id then widget.input:ClearFocus(); widget.input:SetText("") end
        widget.id = row.id
        widget:SetPoint("TOPLEFT", 0, -(index-1)*94)
        widget.title:SetText(row.name .. " (" .. row.id .. ") — intended " .. row.intended .. "; eligible " .. row.eligible
            .. (row.shortage and row.shortage > 0 and ("; short " .. row.shortage) or ""))
        widget.terms:SetText("Unit " .. money(row.price) .. "; eligible total " .. money(row.price and row.eligible > 0 and row.price * row.eligible or nil)
            .. "; " .. hours[duration] .. "h; deposit " .. money(row.deposit) .. "; " .. #row.stacks .. " source stacks")
        widget.state:SetText((row.ready and "Ready" or ("Pending: " .. (row.reason or "unavailable")))
            .. (row.eligible < row.intended and "; remainder stays pending" or "")
            .. (edits[row.id] and "; edited price" or (row.observedAt and ("; scan " .. date("%H:%M %d/%m", row.observedAt)) or "")))
        if not widget.input:HasFocus() then widget.input:SetText(row.price and tostring(row.price) or "") end
        local id = row.id
        widget.save:SetScript("OnClick", function()
            local value = tonumber(widget.input:GetText())
            if not whole(value) then widget.state:SetText("Enter positive whole copper, maximum 2147483647."); return end
            local intent = CW.SaleIntent(id)
            if not intent or intent.destination ~= "AH" then CW.RenderReview(); return end
            edits[id] = value; widget.input:ClearFocus(); CW.RenderReview()
        end)
        widget.reset:SetScript("OnClick", function() edits[id] = nil; widget.input:ClearFocus(); CW.RenderReview() end)
        widget:Show()
    end
    for index = #rows+1, #widgets do widgets[index]:Hide(); widgets[index].id = nil end
    content:SetHeight(math.max(1, #rows*94))
    summary:SetText(#rows .. " AH items; " .. ready .. " ready; " .. pending .. " with pending units | intended " .. intended .. "; eligible " .. eligible
        .. "\nKnown gross " .. money(gross) .. "; estimated after 5% " .. money(math.floor(gross*95/100)) .. "; deposits " .. money(deposits)
        .. (unknownPrice > 0 and ("; prices unknown for " .. unknownPrice .. " entries") or "")
        .. (unknownDeposit > 0 and ("; deposits unknown for " .. unknownDeposit .. " entries") or "")
        .. (deposits > GetMoney() and "; known deposits exceed available money" or "")
        .. (CW.intentNotice and ("\n" .. CW.intentNotice) or "")
        .. (#rows == 0 and "\nMark items for AH in Inventory to build this list." or ""))
    durationButton:SetText("Duration: " .. hours[duration] .. " hours")
end

function CW.DiscardReview()
    edits, duration = {}, 3
    for _, widget in ipairs(widgets) do widget.input:ClearFocus(); widget.id = nil end
end

function CW.SetupReview(parent)
    panel = parent
    local heading = label(panel, 12, -170, 650, "GameFontNormal")
    heading:SetText("AH-marked sale plan — review only")
    durationButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    durationButton:SetSize(160, 23); durationButton:SetPoint("TOPLEFT", 12, -194)
    durationButton:SetScript("OnClick", function() duration = duration % 3 + 1; CW.RenderReview() end)
    local cancel = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    cancel:SetSize(160, 23); cancel:SetPoint("TOPLEFT", 180, -194); cancel:SetText("Cancel review")
    cancel:SetScript("OnClick", function() CW.DiscardReview(); CW.RenderReview() end)
    local post = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    post:SetSize(160, 23); post:SetPoint("TOPLEFT", 348, -194); post:SetText("Post all (soon)"); post:Disable()
    summary = label(panel, 12, -225, 650)
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 12, -284); scroll:SetPoint("BOTTOMRIGHT", -32, 12)
    content = CreateFrame("Frame", nil, scroll); content:SetSize(650, 1); scroll:SetScrollChild(content)
    panel:HookScript("OnShow", CW.RenderReview)
    panel:HookScript("OnHide", CW.DiscardReview)
    panel:HookScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed >= 0.5 then elapsed = 0; CW.RenderReview() end
    end)
end
