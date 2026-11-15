local CW = Copperwise
local entries
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
