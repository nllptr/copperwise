local CW = Copperwise
local entries, choices
local revisions, revision = {}, 0
local MAX_UNITS = 2147483647

function CW.IsPositiveWhole(value)
    return type(value) == "number" and value > 0 and value <= MAX_UNITS and value % 1 == 0
end
local whole = CW.IsPositiveWhole

function CW.IntentRevision(id)
    return revisions[id] or 0
end

local function changed(id)
    revision = revision + 1
    revisions[id] = revision
    if CW.InvalidateReview then CW.InvalidateReview() end
end

function CW.SaleIntent(id)
    return entries and entries[id]
end

function CW.SaleIntents()
    return entries or {}
end

function CW.LoadIntent()
    entries, choices = nil, nil
    CW.intentNotice = nil
    if CopperwiseDB == nil then CopperwiseDB = {} end
    if type(CopperwiseDB) ~= "table" then
        CW.intentNotice = "Character saved data unavailable; sale intent preserved and editing disabled."
        return
    end
    if CopperwiseDB.salePlan == nil then CopperwiseDB.salePlan = {version=1, items={}} end
    local plan = CopperwiseDB.salePlan
    -- Version 1 is the character sale-plan baseline. Future changes must migrate
    -- sequentially on a copy, publishing only after the entire upgrade validates.
    local valid = type(plan) == "table" and plan.version == 1 and type(plan.items) == "table"
    if valid then
        for id, entry in pairs(plan.items) do
            if not whole(id) or type(entry) ~= "table" or not whole(entry.quantity)
                or (entry.destination ~= "AH" and entry.destination ~= "Vendor")
                or type(entry.name) ~= "string" then valid = false; break end
        end
    end
    if not valid then
        CW.intentNotice = "Unsupported or malformed sale plan; saved data preserved and editing disabled."
        return
    end
    local preferences = CopperwiseDB.itemChoices
    if preferences == nil then preferences = {version=1, items={}} end
    valid = type(preferences) == "table" and preferences.version == 1 and type(preferences.items) == "table"
    if valid then
        for id, choice in pairs(preferences.items) do
            if not whole(id) or type(choice) ~= "table" or type(choice.name) ~= "string"
                or (choice.destination ~= "Keep" and choice.destination ~= "Vendor" and choice.destination ~= "AH")
                or type(choice.observedQuantity) ~= "number" or choice.observedQuantity < 0
                or choice.observedQuantity > MAX_UNITS or choice.observedQuantity % 1 ~= 0 then valid = false; break end
        end
    end
    if not valid then
        CW.intentNotice = "Unsupported or malformed item choices; saved data preserved and editing disabled."
        return
    end
    CopperwiseDB.itemChoices = preferences
    entries, choices = plan.items, preferences.items
end

function CW.ChangeIntent(id, action, quantity, destination)
    if not entries then return false, CW.intentNotice or "Sale intent is not loaded." end
    local entry = entries[id]
    if action == "remove" then
        entries[id] = nil
        changed(id)
        return true
    end
    if not whole(quantity) then return false, "Enter positive whole item units (maximum " .. MAX_UNITS .. ")." end
    if action == "edit" then
        if not entry then return false, "Select a marked item first." end
        entry.quantity = quantity
        changed(id)
        return true
    end
    if action ~= "mark" then return false, "Unknown sale-intent action." end
    local item = CW.AvailableItem(id)
    if not item or item.id ~= id then return false, "Wait for current bag holdings to settle." end
    if destination ~= "AH" and destination ~= "Vendor" then return false, "A complete destination comparison is required." end
    local remaining = math.max(0, item.quantity - (entry and entry.quantity or 0))
    if quantity > remaining then return false, "Only unmarked bag units can be added." end
    if entry then
        if entry.quantity > MAX_UNITS - quantity then return false, "Intended quantity is too large." end
        entry.quantity = entry.quantity + quantity
    else
        entries[id] = {quantity=quantity, destination=destination, name=item.name}
    end
    changed(id)
    return true
end

-- Item choices survive completed sales; sale intent remains a quantity-based queue.
function CW.ItemChoice(id)
    local choice = choices and choices[id]
    return choice and choice.destination or (entries and entries[id] and entries[id].destination)
end

function CW.ItemChoices()
    return choices or {}
end

function CW.SetItemChoice(id, destination)
    if not choices then return false, CW.intentNotice or "Item choices are not loaded." end
    if destination == nil then
        choices[id], entries[id] = nil, nil
        changed(id)
        return true
    end
    if destination ~= "Keep" and destination ~= "Vendor" and destination ~= "AH" then
        return false, "Choose Keep, Vendor or AH."
    end
    if not CW.HoldingsSettled() then return false, "Wait for current bag holdings to settle." end
    local item = CW.AvailableItem(id)
    local existing = choices[id] or entries[id]
    if not item and not existing then return false, "Item is not currently available." end
    local quantity = item and item.quantity or 0
    choices[id] = {destination=destination, name=item and item.name or existing.name, icon=item and item.icon or (existing and existing.icon), observedQuantity=quantity}
    entries[id] = destination ~= "Keep" and quantity > 0
        and {destination=destination, name=choices[id].name, icon=choices[id].icon, quantity=quantity} or nil
    changed(id)
    return true
end

function CW.ClearItemChoices(destination)
    if not choices then return false, CW.intentNotice or "Item choices are not loaded." end
    for id, choice in pairs(choices) do
        if choice.destination == destination then choices[id], entries[id] = nil, nil; changed(id) end
    end
    -- Include quantity-only intent created before item choices were introduced.
    for id, entry in pairs(entries) do
        if entry.destination == destination then entries[id] = nil; changed(id) end
    end
    return true
end

function CW.SyncItemChoices()
    if not choices or not CW.HoldingsSettled() then return end
    for id, choice in pairs(choices) do
        local item = CW.AvailableItem(id)
        local quantity = item and item.quantity or 0
        if item and item.icon then choice.icon = item.icon end
        local acquired = math.max(0, quantity - choice.observedQuantity)
        if acquired > 0 and choice.destination ~= "Keep" then
            local entry = entries[id]
            -- Newly acquired units cover an existing shortage before increasing
            -- intent; otherwise consuming and reacquiring units would double-count.
            local intended = entry and entry.quantity or 0
            local shortage = math.max(0, intended - choice.observedQuantity)
            local total = intended + math.max(0, acquired - shortage)
            if total <= MAX_UNITS then
                entries[id] = {destination=choice.destination, name=choice.name, icon=choice.icon, quantity=total}
                changed(id)
            end
        end
        choice.observedQuantity = quantity
    end
end

-- A confirmed native post can consume only the reviewed intent revision.
function CW.ConfirmPostedIntent(id, quantity, intended, expectedRevision)
    local entry = entries and entries[id]
    if not entry or entry.destination ~= "AH" or entry.quantity ~= intended
        or (expectedRevision ~= nil and CW.IntentRevision(id) ~= expectedRevision) then
        return false, "Sale intent changed while posting; saved intent was not reduced."
    end
    if not whole(quantity) or quantity > entry.quantity then return false, "Posted quantity is invalid." end
    entry.quantity = entry.quantity - quantity
    if entry.quantity == 0 then entries[id] = nil end
    changed(id)
    return true
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function() CW.LoadIntent(); CW.Render() end)
