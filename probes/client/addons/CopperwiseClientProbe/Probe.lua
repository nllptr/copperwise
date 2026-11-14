local _, Probe = ...
local session, window, search, selection, result, chartHost
local selectedItem
local tooltipMode = "not installed"
local modifierMode = "not installed"
local samples = {
    {id = 2447, alias = "Peacebloom", values = {
        {lower = 70, median = 100, upper = 140, stock = 160},
        {lower = 80, median = 120, upper = 160, stock = 140},
        {lower = 100, median = 150, upper = 200, stock = 90},
        {lower = 90, median = 130, upper = 180, stock = 110},
        {lower = 100, median = 140, upper = 180, stock = 80},
    }},
    {id = 2770, alias = "Copper Ore", values = {
        {lower = 240, median = 300, upper = 360, stock = 40},
        {lower = 200, median = 260, upper = 320, stock = 70},
        {lower = 180, median = 230, upper = 280, stock = 100},
        {lower = 150, median = 200, upper = 250, stock = 130},
        {lower = 140, median = 180, upper = 230, stock = 150},
    }},
}

local function record(message)
    local line = string.sub("t=" .. tostring(GetTime()) .. " " .. message, 1, 320)
    print("Copperwise client probe: " .. line)
    if session then
        table.insert(session.events, line)
        if #session.events > 120 then table.remove(session.events, 1) end
    end
end

local function attempt(label, action)
    local ok, err = pcall(action)
    if not ok then record(label .. " FAILED: " .. tostring(err)) end
    return ok
end

local function sampleByID(id)
    for _, item in ipairs(samples) do
        if item.id == id then return item end
    end
end

local function localName(item)
    local lookup = C_Item and C_Item.GetItemInfo or GetItemInfo
    if lookup then
        local ok, name = pcall(lookup, item.id)
        if ok and type(name) == "string" then return name end
    end
    return item.alias
end

local function label(parent, value, x, y, template)
    local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    text:SetText(value)
    return text
end

local function selectSample(item)
    if not window then record("window unavailable; inspect login diagnostics") return end
    selectedItem = item
    if chartHost then chartHost:Hide() end
    if not item then
        selection:SetText("No matching sample. Try Peacebloom, Copper Ore, 2447 or 2770.")
        result:SetText("Only two synthetic sample items are available; no real market history is loaded.")
        record("lookup: no matching sample; previous graphs hidden")
        return
    end
    selection:SetText(localName(item) .. " (sample item " .. item.id .. ")")
    -- Reuse each item's graph host; repeated searches do not accumulate frames.
    if not item.chartHost then
        item.chartHost = CreateFrame("Frame", nil, window)
        item.chartHost:SetAllPoints(window)
        item.graphOK = attempt("graphs item=" .. item.id, function()
            Probe.DrawGraphs(item.chartHost, item.values, session.sampleObservedAt)
        end)
        if not item.graphOK then item.chartHost:Hide() end
    end
    chartHost = item.chartHost
    if item.graphOK then
        chartHost:Show()
        result:SetText("SYNTHETIC 4-hour coverage | " .. date("%Y-%m-%d", session.sampleObservedAt)
            .. " | local zone: " .. date("%Z %z", session.sampleObservedAt)
            .. "\nSpread bounds show the middle 50% of sample asking prices, not confidence or sales.")
        record("graphs constructed item=" .. item.id .. " first=" .. (session.sampleObservedAt - 4 * 3600)
            .. " last=" .. session.sampleObservedAt .. "; visual alignment/readability UNVERIFIED")
    else
        result:SetText("Graph capability failed. See chat diagnostics; window/lookup remain available.")
    end
end

local function findSample(query)
    query = string.lower((query or ""):match("^%s*(.-)%s*$"))
    local match
    if query ~= "" then
        for _, item in ipairs(samples) do
            if query == tostring(item.id) or string.find(string.lower(item.alias), query, 1, true)
                or string.find(string.lower(localName(item)), query, 1, true) then
                if match then selectSample(nil) record("lookup ambiguous; enter an exact sample name or ID") return end
                match = item
            end
        end
    end
    selectSample(match)
end

local function buildWindow()
    window = CreateFrame("Frame", "CopperwiseClientProbeWindow", UIParent)
    window:SetSize(620, 530)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:EnableMouse(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    local background = window:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(window)
    background:SetColorTexture(0.04, 0.06, 0.09, 0.97)
    label(window, "Copperwise capability probe — SYNTHETIC DATA ONLY", 18, -18, "GameFontNormalLarge")
    label(window, "Sample name or ID (Peacebloom / Copper Ore):", 18, -49)
    search = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    search:SetSize(340, 24)
    search:SetPoint("TOPLEFT", window, "TOPLEFT", 24, -70)
    search:SetAutoFocus(false)
    search:SetMaxLetters(80)
    search:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        attempt("lookup", function() findSample(self:GetText()) end)
    end)
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local find = CreateFrame("Button", nil, window, "UIPanelButtonTemplate")
    find:SetSize(126, 24)
    find:SetPoint("LEFT", search, "RIGHT", 14, 0)
    find:SetText("Find sample")
    find:SetScript("OnClick", function()
        search:ClearFocus()
        attempt("lookup", function() findSample(search:GetText()) end)
    end)
    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, 0)
    close:SetScript("OnClick", function() window:Hide() end)
    selection = label(window, "", 18, -108, "GameFontNormal")
    result = label(window, "", 18, -472)
    result:SetWidth(584)
    result:SetJustifyH("LEFT")
    table.insert(UISpecialFrames, "CopperwiseClientProbeWindow")
    window:Hide()
    selectSample(samples[1])
end

function CopperwiseClientProbeToggle()
    attempt("toggle window", function()
        if not window then record("window unavailable; inspect login diagnostics") return end
        if window:IsShown() then window:Hide() else window:Show() end
        record("window shown=" .. tostring(window:IsShown()) .. "; away-from-AH use UNVERIFIED")
    end)
end

function CopperwiseClientProbeHovered()
    attempt("hovered item binding", function()
        if not GameTooltip or not GameTooltip:IsShown() or not GameTooltip.GetItem then
            record("hover: no visible item tooltip") return
        end
        local _, link = GameTooltip:GetItem()
        local item = type(link) == "string" and sampleByID(tonumber(link:match("item:(%d+)")))
        if not item then record("hover: no supported sample item in GameTooltip") return end
        if not window then record("hover: window unavailable") return end
        selectSample(item)
        window:Show()
        record("hover binding opened sample item=" .. item.id)
    end)
end

BINDING_HEADER_COPPERWISE_CLIENT_PROBE = "Copperwise Client Probe"
BINDING_NAME_COPPERWISE_CLIENT_TOGGLE = "Toggle sample history window"
BINDING_NAME_COPPERWISE_CLIENT_HOVERED = "Open hovered sample item"

local function appendTooltip(tooltip)
    if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then return end
    if tooltip.IsForbidden and tooltip:IsForbidden() then return end
    if not tooltip.GetItem or tooltip.copperwiseSampleAdded then return end
    local _, link = tooltip:GetItem()
    local item = type(link) == "string" and sampleByID(tonumber(link:match("item:(%d+)")))
    if not item then return end
    local last = item.values[#item.values]
    tooltip:AddLine("Copperwise SAMPLE — not market data", 0.3, 0.85, 1)
    tooltip:AddLine(string.format("Median %dc/unit; spread %d–%dc; stock %d units",
        last.median, last.lower, last.upper, last.stock), 1, 1, 1, true)
    tooltip:AddLine("Synthetic sample age: " .. math.max(0, time() - session.sampleObservedAt)
        .. "s; spread is not confidence.", 0.8, 0.8, 0.8, true)
    tooltip.copperwiseSampleAdded = true
    record("tooltip sample lines appended item=" .. item.id .. "; readability UNVERIFIED")
end

local function installTooltips()
    for _, tooltip in ipairs({GameTooltip, ItemRefTooltip}) do
        tooltip:HookScript("OnTooltipCleared", function(self) self.copperwiseSampleAdded = nil end)
    end
    local callback = function(tooltip) attempt("tooltip addition", function() appendTooltip(tooltip) end) end
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, callback)
        tooltipMode = "item post-call registered (runtime behavior UNVERIFIED)"
    else
        local count = 0
        for _, tooltip in ipairs({GameTooltip, ItemRefTooltip}) do
            if tooltip.HasScript and tooltip:HasScript("OnTooltipSetItem") then
                tooltip:HookScript("OnTooltipSetItem", callback)
                count = count + 1
            end
        end
        tooltipMode = "legacy item hooks registered=" .. count .. " (runtime behavior UNVERIFIED)"
    end
    record("tooltip: " .. tooltipMode)
end

local function installModifierObserver()
    if type(hooksecurefunc) ~= "function" or type(HandleModifiedItemClick) ~= "function" then
        modifierMode = "HandleModifiedItemClick secure post-hook unavailable"
    else
        hooksecurefunc("HandleModifiedItemClick", function(link)
            attempt("modifier observation", function()
                if IsAltKeyDown() and type(link) == "string" then
                    local id = tonumber(link:match("item:(%d+)"))
                    if sampleByID(id) then record("Alt modified-item path observed sample item=" .. id .. "; original action preservation UNVERIFIED") end
                end
            end)
        end)
        modifierMode = "secure post-hook registered; observation only, no click shortcut"
    end
    record("modifier: " .. modifierMode)
end

local function status()
    if not session then record("login initialization pending") return end
    print("Copperwise client probe: client=" .. tostring(session.version) .. " build=" .. tostring(session.build)
        .. " interface=" .. tostring(session.interface) .. " platform=" .. session.platform)
    print("Copperwise client probe: tooltip=" .. tooltipMode .. "; modifier=" .. modifierMode)
    print("Copperwise client probe: latest evidence (all capability verdicts require manual observations):")
    for index = math.max(1, #session.events - 7), #session.events do print(session.events[index]) end
end

SLASH_COPPERWISECLIENTPROBE1 = "/cwclient"
SlashCmdList["COPPERWISECLIENTPROBE"] = function(message)
    message = (message or ""):match("^%s*(.-)%s*$")
    if message == "status" then status()
    elseif message:match("^note%s+") then record("OPERATOR NOTE: " .. message:sub(6))
    elseif message == "" then CopperwiseClientProbeToggle()
    else record("commands: /cwclient | /cwclient status | /cwclient note <manual outcome>") end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("GET_ITEM_INFO_RECEIVED")
events:SetScript("OnEvent", function(_, event, itemID, success)
    if event == "GET_ITEM_INFO_RECEIVED" then
        if session and success and sampleByID(itemID) then record("sample item-name cache updated; repeat lookup if needed") end
        return
    end
    events:UnregisterEvent("PLAYER_LOGIN")
    local version, build, buildDate, interface = GetBuildInfo()
    local platform = IsMacClient and IsMacClient() and "macOS (version/architecture unknown)" or "unknown"
    session = {version = version, build = build, buildDate = buildDate, interface = interface,
        platform = platform, sampleObservedAt = time(), events = {}}
    CopperwiseClientEvidence = CopperwiseClientEvidence or {}
    table.insert(CopperwiseClientEvidence, session)
    if #CopperwiseClientEvidence > 5 then table.remove(CopperwiseClientEvidence, 1) end
    record("client=" .. tostring(version) .. " build=" .. tostring(build) .. " interface=" .. tostring(interface) .. " platform=" .. platform)
    attempt("window construction", buildWindow)
    attempt("tooltip hook installation", installTooltips)
    attempt("modifier hook installation", installModifierObserver)
    record("SYNTHETIC DATA ONLY; /cwclient opens window; configure keys in game Key Bindings")
end)
