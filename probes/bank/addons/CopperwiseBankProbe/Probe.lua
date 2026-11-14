local session
local bankOpen = false
local confirmed = false
local samples = {2447, 2770, 5206}
local frame = CreateFrame("Frame")

local function record(message)
    local line = string.sub("t=" .. tostring(time()) .. " " .. message, 1, 700)
    print("Copperwise bank probe: " .. line)
    if session then
        table.insert(session.events, line)
        if #session.events > 180 then table.remove(session.events, 1) end
    end
end

local function readContainers(ids)
    local api = C_Container
    if not api or not api.GetContainerNumSlots or not api.GetContainerItemInfo then
        error("required C_Container API unavailable")
    end
    local rows, coverage = {}, {}
    for _, id in ipairs(samples) do rows[id] = {count = 0, slots = {}} end
    for _, bag in ipairs(ids) do
        local size = api.GetContainerNumSlots(bag)
        if type(size) ~= "number" or size < 0 or size ~= math.floor(size) then
            error("invalid slot count container=" .. bag)
        end
        if bag == -1 and size == 0 then error("main bank slots unavailable") end
        table.insert(coverage, bag .. ":" .. size)
        for slot = 1, size do
            local info = api.GetContainerItemInfo(bag, slot)
            if info then
                local id = info.itemID or tonumber((info.hyperlink or ""):match("item:(%d+)"))
                if not id then error("occupied slot has no item identity") end
                if type(info.stackCount) ~= "number" or info.stackCount <= 0
                    or info.stackCount ~= math.floor(info.stackCount) then
                    error("invalid stackCount")
                end
                -- Locked containers are not a completed observation, even for non-samples.
                if info.isLocked then error("locked slot; retry after movement settles") end
                local row = rows[id]
                if row then
                    row.count = row.count + info.stackCount
                    table.insert(row.slots, bag .. ":" .. slot .. "x" .. info.stackCount)
                end
            end
        end
    end
    return {rows = rows, observedAt = time(), coverage = table.concat(coverage, ",")}
end

local function show(location, observation, state)
    record(location .. " state=" .. state .. " observed-at="
        .. tostring(observation and observation.observedAt or "unknown")
        .. " containers:slots=" .. tostring(observation and observation.coverage or "unknown"))
    for _, id in ipairs(samples) do
        local row = observation and observation.rows[id]
        record(location .. " item=" .. id .. " count=" .. tostring(row and row.count or "unknown")
            .. " state=" .. (row and state or "unknown")
            .. " slots=" .. (row and table.concat(row.slots, ",") or "unknown"))
    end
end

local function snapshot(reason)
    if not session then return end
    record("snapshot=" .. reason .. " bank-access=" .. (bankOpen and "open-event" or "closed/unobserved")
        .. "; excludes cursor/equipment/guild-bank/other-characters; no atomic-count guarantee")
    local ok, bags = pcall(readContainers, {0, 1, 2, 3, 4})
    if not ok then record("bags read failed: " .. tostring(bags)) end
    show("bags", ok and bags or nil, ok and "observed" or "unknown")
    if bankOpen then
        local success, bank = pcall(readContainers, {-1, 5, 6, 7, 8, 9, 10, 11})
        confirmed = success
        if success then
            CopperwiseBankEvidence.bank = bank
        else
            record("bank read failed; previous observation retained as cached: " .. tostring(bank))
        end
    end
    local bank = CopperwiseBankEvidence.bank
    show("bank", bank, confirmed and "confirmed" or (bank and "cached" or "unknown"))
end

SLASH_COPPERWISEBANKPROBE1 = "/cwbank"
SlashCmdList.COPPERWISEBANKPROBE = function(message)
    local command, argument = (message or ""):match("^(%S*)%s*(.-)%s*$")
    if command == "note" then
        record("operator-note=" .. argument)
    elseif command == "sample" then
        local id = tonumber(argument)
        if not id or id < 1 or id ~= math.floor(id) then
            record("usage: /cwbank sample <positive item ID>")
            return
        end
        for _, existing in ipairs(samples) do if existing == id then snapshot("sample") return end end
        if #samples >= 6 then record("six-sample limit; reload to restore defaults") return end
        table.insert(samples, id)
        snapshot("sample")
    elseif command == "" or command == "status" then
        snapshot("manual")
    else
        record("commands: /cwbank [status | sample <item ID> | note <outcome>]")
    end
end

for _, event in ipairs({"PLAYER_LOGIN", "BANKFRAME_OPENED", "BANKFRAME_CLOSED",
    "PLAYERBANKSLOTS_CHANGED", "PLAYERBANKBAGSLOTS_CHANGED", "BAG_UPDATE_DELAYED"}) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        if type(CopperwiseBankEvidence) ~= "table" or CopperwiseBankEvidence.version ~= 1 then
            CopperwiseBankEvidence = {version = 1, sessions = {}}
        end
        session = {events = {}}
        table.insert(CopperwiseBankEvidence.sessions, session)
        while #CopperwiseBankEvidence.sessions > 5 do table.remove(CopperwiseBankEvidence.sessions, 1) end
        local version, build, _, interface = GetBuildInfo()
        record("client=" .. tostring(version) .. " build=" .. tostring(build)
            .. " interface=" .. tostring(interface) .. " platform="
            .. (IsMacClient and IsMacClient() and "macOS" or "other/unknown"))
        record("APIs=C_Container.GetContainerNumSlots/GetContainerItemInfo; assumed classic bank=-1,5-11"
            .. "; NUM_BAG_SLOTS=" .. tostring(NUM_BAG_SLOTS)
            .. " NUM_BANKBAGSLOTS=" .. tostring(NUM_BANKBAGSLOTS)
            .. "; verify IDs/coverage against visible bank; reopen bank after reload")
    elseif event == "BANKFRAME_OPENED" then
        bankOpen = true
    elseif event == "BANKFRAME_CLOSED" then
        bankOpen, confirmed = false, false
    end
    snapshot(event)
end)
