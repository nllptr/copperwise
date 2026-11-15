local CW = Copperwise
local VERSION = 1
-- Account-wide version 1 is the supported baseline. On a schema change, bump
-- VERSION and add migrations[oldVersion](db), returning the upgraded table.
-- Keep every intervening migration so updates can skip addon releases.
local migrations = {}

local function validMarkets(markets)
    if type(markets) ~= "table" then return false end
    for key, snapshot in pairs(markets) do
        if type(key) ~= "string" or type(snapshot) ~= "table" or snapshot.full ~= true
            or type(snapshot.items) ~= "table" or type(snapshot.observedAt) ~= "number"
            or type(snapshot.count) ~= "number" or type(snapshot.context) ~= "string" then return false end
        for identity, row in pairs(snapshot.items) do
            if type(identity) ~= "string" or type(row) ~= "table" or type(row.key) ~= "table"
                or type(row.key.itemID) ~= "number" or type(row.units) ~= "number"
                or (row.minimum ~= nil and type(row.minimum) ~= "number") then return false end
        end
    end
    return true
end

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, field in pairs(value) do result[key] = copy(field) end
    return result
end

function CW.LoadStorage()
    CW.markets = nil
    if CopperwiseAccountDB == nil then CopperwiseAccountDB = {version=VERSION, markets={}} end
    local db = CopperwiseAccountDB
    local ok, result = pcall(function()
        assert(type(db) == "table" and type(db.version) == "number"
            and db.version >= 1 and db.version % 1 == 0 and db.version <= VERSION,
            "Unsupported saved-data version; data preserved. Update Copperwise before scanning.")
        if db.version < VERSION then
            -- Upgrade a copy: a failed migration must not corrupt saved data.
            db = copy(db)
            while db.version < VERSION do
                local version = db.version
                assert(migrations[version], "Missing saved-data migration; data preserved.")
                db = migrations[version](db)
                assert(type(db) == "table", "Invalid saved-data migration; data preserved.")
                db.version = version + 1
            end
        end
        assert(validMarkets(db.markets), "Invalid saved market data; data preserved.")
        return db
    end)
    if not ok then CW.notice = tostring(result); return end
    CopperwiseAccountDB = result
    CW.markets = result.markets
end
