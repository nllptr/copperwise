local frame = CreateFrame("Frame")
local elapsed, attempts, lastRevision = 0, 0, nil
local session
local api = C_AddOns or {}
local loadAddon = api.LoadAddOn or LoadAddOn
local function record(message)
    local line = string.format("t=%s %s", tostring(GetTime()), message)
    print("Copperwise probe: " .. line)
    table.insert(session.events, line)
    if #session.events > 300 then table.remove(session.events, 1) end
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    local version, build, buildDate, interface = GetBuildInfo()
    session = { version = version, build = build, buildDate = buildDate,
        interface = interface, startedAt = time(), events = {} }
    CopperwiseDeliveryEvidence = CopperwiseDeliveryEvidence or {}
    table.insert(CopperwiseDeliveryEvidence, session)
    if #CopperwiseDeliveryEvidence > 5 then table.remove(CopperwiseDeliveryEvidence, 1) end
    record(string.format("client=%s build=%s interface=%s loadAPI=%s", tostring(version), tostring(build), tostring(interface), type(loadAddon)))
    record("companion connection UNKNOWN; source timestamps are payload claims")
    frame:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        if elapsed < 5 or attempts >= 36 then return end
        elapsed = 0
        attempts = attempts + 1
        if type(loadAddon) ~= "function" then
            record("LoadAddOn unavailable; experiment stopped")
            frame:SetScript("OnUpdate", nil)
            return
        end
        local ok, loaded, reason = pcall(loadAddon, "CopperwiseDeliveryData")
        local payload = CopperwiseDeliveryPayload
        local revision = type(payload) == "table" and payload.revision or nil
        record(string.format("attempt=%d callOK=%s loaded=%s reason=%s revision=%s", attempts, tostring(ok), tostring(loaded), tostring(reason), tostring(revision)))
        if revision and revision ~= lastRevision then
            record(string.format("VISIBLE revision=%s observedAt=%s downloadedAt=%s importedAt=%s", tostring(revision), tostring(payload.observedAt), tostring(payload.downloadedAt), tostring(time())))
            lastRevision = revision
        end
        if attempts == 36 then record("experiment ended; compare visible revisions with companion exports") end
    end)
end)
