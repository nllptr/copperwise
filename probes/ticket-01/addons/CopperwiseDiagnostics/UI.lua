local window, report, content
local function showReport(filter)
    local ok, results, failures = pcall(CopperwiseRunDiagnostics, filter)
    if not ok then print("Copperwise diagnostics: " .. tostring(results)); return end
    if not window then
        window = CreateFrame("Frame", "CopperwiseDiagnosticsWindow", UIParent, "BasicFrameTemplateWithInset")
        window:SetSize(800, 650)
        window:SetPoint("CENTER")
        window:SetMovable(true)
        window:EnableMouse(true)
        window:RegisterForDrag("LeftButton")
        window:SetScript("OnDragStart", window.StartMoving)
        window:SetScript("OnDragStop", window.StopMovingOrSizing)
        window.TitleText:SetText("Copperwise — controlled diagnostics (simulated)")
        table.insert(UISpecialFrames, "CopperwiseDiagnosticsWindow")
        local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 18, -40)
        scroll:SetPoint("BOTTOMRIGHT", -35, 18)
        content = CreateFrame("Frame", nil, scroll)
        content:SetWidth(735)
        report = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        report:SetPoint("TOPLEFT")
        report:SetWidth(735)
        report:SetJustifyH("LEFT")
        report:SetJustifyV("TOP")
        scroll:SetScrollChild(content)
        window.scroll = scroll
    end
    local version, build, _, interface = GetBuildInfo()
    local lines = {
        "CONTROLLED DIAGNOSTICS — synthetic API inputs, UI and clock",
        "Production Lua runs in isolation. No native AH requests or saved-data writes.",
        "These checks do not establish native-server behavior or actual metadata timing.",
        "Client: " .. version .. "; build " .. build .. "; interface " .. interface,
        "Run: " .. date("%Y-%m-%d %H:%M:%S %Z"),
        (#results - failures) .. "/" .. #results .. " passed; " .. failures .. " failed.",
        "",
    }
    for _, result in ipairs(results) do
        lines[#lines+1] = (result.ok and "PASS: " or "FAIL: ") .. result.name .. " — " .. result.title
        if result.error then lines[#lines+1] = tostring(result.error) end
    end
    lines[#lines+1] = "\nInspect one case with /cwdiag metadata (or empty, buyout, failure, timeout, partial, throttle)."
    for _, result in ipairs(results) do
        lines[#lines+1] = "\n=== " .. result.name .. ": simulated Inventory output ==="
        if #results == 1 and result.before then
            lines[#lines+1] = "BEFORE:\n" .. result.before
        end
        if result.intermediate then lines[#lines+1] = "INTERMEDIATE:\n" .. result.intermediate end
        lines[#lines+1] = "AFTER:\n" .. (result.after or "No Inventory output available")
    end
    report:SetText(table.concat(lines, "\n"))
    content:SetHeight(math.max(560, report:GetStringHeight() + 20))
    window.scroll:SetVerticalScroll(0)
    window:Show()
    print("Copperwise controlled diagnostics: " .. (#results - failures) .. "/" .. #results
        .. " passed (simulated; see /cwdiag).")
end
SLASH_COPPERWISEDIAGNOSTICS1 = "/cwdiag"
SlashCmdList.COPPERWISEDIAGNOSTICS = function(argument)
    local filter = argument:match("^%s*(.-)%s*$")
    showReport(filter == "" and "all" or filter)
end
