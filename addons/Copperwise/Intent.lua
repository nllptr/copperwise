local CW = Copperwise
local entries
local MAX_UNITS = 2147483647

local function whole(value)
    return type(value) == "number" and value > 0 and value <= MAX_UNITS and value % 1 == 0
end

function CW.SaleIntent(id)
    return entries and entries[id]
end

function CW.SaleIntents()
    return entries or {}
end

function CW.LoadIntent()
    entries = nil
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
    entries = plan.items
end

function CW.ChangeIntent(id, action, quantity, destination)
    if not entries then return false, CW.intentNotice or "Sale intent is not loaded." end
    local entry = entries[id]
    if action == "remove" then
        entries[id] = nil
        return true
    end
    if not whole(quantity) then return false, "Enter positive whole item units (maximum " .. MAX_UNITS .. ")." end
    if action == "edit" then
        if not entry then return false, "Select a marked item first." end
        entry.quantity = quantity
        return true
    end
    if action ~= "add" then return false, "Unknown sale-intent action." end
    local item = CW.SelectedItem()
    if not item or item.id ~= id then return false, "Wait for current bag holdings to settle." end
    if destination ~= "AH" and destination ~= "Vendor" then return false, "A complete destination comparison is required." end
    if entry then
        if entry.quantity > MAX_UNITS - quantity then return false, "Intended quantity is too large." end
        entry.quantity = entry.quantity + quantity
    else
        entries[id] = {quantity=quantity, destination=destination, name=item.name}
    end
    return true
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function() CW.LoadIntent(); CW.Render() end)
