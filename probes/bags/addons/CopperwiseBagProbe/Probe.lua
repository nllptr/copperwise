local session
local samples = {2447, 2770, 2515}
local frame = CreateFrame("Frame")

local function record(message)
    local line = string.sub("t=" .. tostring(time()) .. " " .. message, 1, 500)
    print("Copperwise bag probe: " .. line)
    if session then
        table.insert(session.events, line)
        if #session.events > 180 then table.remove(session.events, 1) end
    end
end

local function snapshot(reason)
    if not session then return end
    local container = C_Container
    local lookup = C_Item and C_Item.GetItemInfo or GetItemInfo
    if not container or not container.GetContainerNumSlots or not container.GetContainerItemInfo
        or not lookup then error("required container/item metadata API unavailable") end
    -- Rebuild from slots each time; event deltas must never accumulate quantities.
    local rows = {}
    for _, id in ipairs(samples) do rows[id] = {count = 0, slots = {}} end
    for bag = 0, 4 do
        for slot = 1, container.GetContainerNumSlots(bag) do
            local info = container.GetContainerItemInfo(bag, slot)
            if info then
                local id = info.itemID or tonumber((info.hyperlink or ""):match("item:(%d+)"))
                local row = rows[id]
                if row then
                    if type(info.stackCount) ~= "number" then error("missing stackCount") end
                    row.count = row.count + info.stackCount
                    table.insert(row.slots, bag .. ":" .. slot .. "x" .. info.stackCount
                        .. (info.isLocked and "(locked)" or ""))
                end
            end
        end
    end
    record("snapshot=" .. reason .. " coverage=backpack+bags0-4; excludes cursor/equipment/bank")
    for _, id in ipairs(samples) do
        local row = rows[id]
        local name, _, _, _, _, _, _, _, _, _, sell = lookup(id)
        local value = "unavailable"
        if name and type(sell) == "number" then
            value = sell .. " copper/unit; bag-total=" .. sell * row.count .. " copper"
        end
        record("item=" .. id .. " count=" .. row.count .. " vendor-sell=" .. value
            .. " slots=" .. table.concat(row.slots, ","))
    end
end

local function scan(reason)
    local ok, err = pcall(snapshot, reason)
    if not ok then record("FAILED snapshot discarded; " .. tostring(err)) end
end

SLASH_COPPERWISEBAGPROBE1 = "/cwbags"
SlashCmdList.COPPERWISEBAGPROBE = function(message)
    local command, argument = (message or ""):match("^(%S*)%s*(.-)%s*$")
    if command == "note" then
        record("operator-note=" .. argument)
    elseif command == "sample" then
        local id = tonumber(argument)
        if not id or id < 1 or id ~= math.floor(id) then
            record("usage: /cwbags sample <positive item ID>")
            return
        end
        for _, existing in ipairs(samples) do if existing == id then scan("sample") return end end
        if #samples >= 6 then record("six-sample limit; reload to restore defaults") return end
        table.insert(samples, id)
        scan("sample")
    elseif command == "" or command == "status" then
        scan("manual")
    else
        record("commands: /cwbags [status | sample <item ID> | note <outcome>]")
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        if type(CopperwiseBagEvidence) ~= "table" then CopperwiseBagEvidence = {} end
        session = {events = {}}
        table.insert(CopperwiseBagEvidence, session)
        while #CopperwiseBagEvidence > 5 do table.remove(CopperwiseBagEvidence, 1) end
        local version, build, _, interface = GetBuildInfo()
        record("client=" .. tostring(version) .. " build=" .. tostring(build)
            .. " interface=" .. tostring(interface) .. " platform="
            .. (IsMacClient and IsMacClient() and "macOS" or "other/unknown"))
        record("APIs=C_Container.GetContainerNumSlots/GetContainerItemInfo; item="
            .. (C_Item and C_Item.GetItemInfo and "C_Item.GetItemInfo" or "GetItemInfo")
            .. " return11=vendor-sell; no merchant purchase prices queried")
    end
    scan(event)
end)
