local frame = CreateFrame("Frame")
local session

local function record(message)
    local line = string.format("t=%s %s", tostring(GetTime()), message)
    print("Copperwise probe: " .. line)
    table.insert(session.events, line)
    if #session.events > 300 then table.remove(session.events, 1) end
end

local function showStatus()
    if not session then return end
    if session.revision then
        record(string.format("LOADED revision=%s observedAt=%s downloadedAt=%s exportedAt=%s importedAt=%s sourceAgeSeconds=%s",
            tostring(session.revision), tostring(session.observedAt),
            tostring(session.downloadedAt), tostring(session.exportedAt),
            tostring(session.importedAt), tostring(time() - session.observedAt)))
    else
        record("NO DATA: no valid probe payload was loaded")
    end
    record("companion connection UNKNOWN; newer exports UNKNOWN; refresh only at login or user /reload")
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    frame:UnregisterEvent("PLAYER_LOGIN")
    local version, build, buildDate, interface = GetBuildInfo()
    session = { version = version, build = build, buildDate = buildDate,
        interface = interface, importedAt = time(), events = {} }
    -- Capture only the dataset already loaded by the ordinary addon dependency.
    -- Status commands never load files or replace this session's snapshot.
    local payload = CopperwiseDeliveryPayload
    if type(payload) == "table" and type(payload.revision) == "number"
        and payload.revision > 0 and type(payload.observedAt) == "number"
        and payload.observedAt > 0 then
        session.revision = payload.revision
        session.observedAt = payload.observedAt
        session.downloadedAt = payload.downloadedAt
        session.exportedAt = payload.exportedAt
    end
    CopperwiseDeliveryEvidence = CopperwiseDeliveryEvidence or {}
    table.insert(CopperwiseDeliveryEvidence, session)
    if #CopperwiseDeliveryEvidence > 5 then table.remove(CopperwiseDeliveryEvidence, 1) end
    record(string.format("client=%s build=%s interface=%s evidenceSession=%d", tostring(version), tostring(build), tostring(interface), #CopperwiseDeliveryEvidence))
    showStatus()
end)

SLASH_COPPERWISEDELIVERYPROBE1 = "/cwprobe"
SlashCmdList["COPPERWISEDELIVERYPROBE"] = showStatus
