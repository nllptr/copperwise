local frame = CreateFrame("Frame")
local panel, output, tab, postButton, handoffButton, session, preview
local houseOpen, attempted, surfaceReady = false, false, false
local state = "No item prepared."
local pendingChat = {}
local postPendingRender = false
local mode = {"CopperwisePostingProbePanel"}

local function record(message)
    local line = string.sub("t=" .. time() .. " " .. message, 1, 900)
    -- Chat output can enter tainted native print handlers. Flush on the next
    -- frame, outside restricted transaction calls and synchronous events.
    table.insert(pendingChat, "Copperwise posting: " .. line)
    while #pendingChat > 200 do table.remove(pendingChat, 1) end
    if session then
        table.insert(session, line)
        while #session > 200 do table.remove(session, 1) end
    end
end

local function render()
    if output then output:SetText(state) end
    if postButton then postButton:SetEnabled(preview ~= nil and not attempted) end
    if handoffButton then handoffButton:SetEnabled(preview ~= nil and not attempted) end
end

local function invalidate(reason)
    preview = nil
    state = reason
    record(reason)
    render()
end

local function guard(action)
    return function(...)
        local ok, err = pcall(action, ...)
        if not ok then invalidate("Refused/error: " .. tostring(err) .. "; no automatic retry.") end
    end
end

local function api(name, ...)
    local fn = C_AuctionHouse and C_AuctionHouse[name]
    if type(fn) ~= "function" then error("C_AuctionHouse." .. name .. " unavailable") end
    return fn(...)
end

local function readinessFailure()
    if not houseOpen or not panel or not panel:IsShown() then return "open /cwpost at an auctioneer first" end
    if attempted then return "one action used; inspect native Auctions and close/reopen AH before another" end
    if not surfaceReady then return "native posting surface unavailable" end
    if not C_AuctionHouse or type(C_AuctionHouse.IsThrottledMessageSystemReady) ~= "function" then
        return "native AH readiness unavailable"
    end
    if not C_AuctionHouse.IsThrottledMessageSystemReady() then return "AH busy/throttled" end
    local queue = Auctionator and Auctionator.AH and Auctionator.AH.Queue
    if queue and type(queue.queue) == "table" and #queue.queue > 0 then return "wait for Auctionator work to finish" end
end

local function ready()
    local reason = readinessFailure()
    if reason then error(reason) end
end

local function inspect(bag, slot, quantity, price, duration)
    local location = ItemLocation:CreateFromBagAndSlot(bag, slot)
    local info = C_Container.GetContainerItemInfo(bag, slot)
    if not info or info.isLocked or not info.hyperlink then error("slot empty, locked or metadata unavailable") end
    if quantity > info.stackCount then error("quantity exceeds selected bag stack; no cross-stack posting in this probe") end
    if not api("IsSellItemValid", location, false) then error("selected bag item cannot be posted") end
    local status = api("GetItemCommodityStatus", location)
    if status ~= Enum.ItemCommodityStatus.Commodity and status ~= Enum.ItemCommodityStatus.Item then
        error("commodity classification unavailable")
    end
    local commodity = status == Enum.ItemCommodityStatus.Commodity
    -- Keep item-based investigation to one item: no implicit multisell semantics.
    if not commodity and quantity ~= 1 then error("noncommodity sample must have quantity 1") end
    local deposit
    if commodity then deposit = api("CalculateCommodityDeposit", info.itemID, duration, quantity)
    else deposit = api("CalculateItemDeposit", location, duration, quantity) end
    if type(deposit) ~= "number" or deposit < 0 then error("deposit unavailable") end
    if deposit > GetMoney() then error("insufficient money for reported deposit") end
    return {bag=bag, slot=slot, quantity=quantity, price=price, duration=duration,
        link=info.hyperlink, itemID=info.itemID, count=info.stackCount, deposit=deposit,
        commodity=commodity, location=location}
end

local function prepare(arguments)
    ready()
    preview = nil
    local fields = {}
    for word in arguments:gmatch("%S+") do
        local n = tonumber(word)
        if not n or n ~= math.floor(n) or n < 0 or n > 2147483647 then error("use whole numeric arguments") end
        table.insert(fields, n)
    end
    if #fields ~= 5 then error("use /cwpost prepare <bag 0-4> <slot> <quantity> <copper price> <duration 1-3>") end
    local bag, slot, quantity, price, duration = unpack(fields)
    if bag > 4 or slot < 1 or quantity < 1 or price < 1 or duration < 1 or duration > 3 then error("arguments outside probe bounds") end
    preview = inspect(bag, slot, quantity, price, duration)
    state = "Review before posting:\n" .. preview.link .. "\nBag " .. bag .. ", slot " .. slot
        .. "; available in stack: " .. preview.count .. "\nQuantity: " .. quantity
        .. "\n" .. (preview.commodity and "Unit buyout" or "Single item buyout") .. ": " .. price .. " copper"
        .. "\nTotal buyout: " .. price * quantity .. " copper\nDuration index: " .. duration
        .. " (1=2h, 2=8h, 3=24h)\nReported deposit: " .. preview.deposit
        .. " copper\n\nPost once creates a real listing at these terms.\nNative Sell fallback only prepares Blizzard's controls; it does not post."
    record("prepared item=" .. preview.itemID .. " bag=" .. bag .. " slot=" .. slot .. " quantity=" .. quantity
        .. " copper-price=" .. price .. " commodity=" .. tostring(preview.commodity)
        .. " duration=" .. duration .. " deposit=" .. preview.deposit)
    render()
end

local function post()
    local reason = readinessFailure()
    if reason then invalidate("Refused: " .. reason .. "; no post sent."); return end
    local p = preview
    if not p then invalidate("Prepare and review an item first; no post sent."); return end
    -- Use the reviewed ItemLocation, as Auctionator does. Recheck its current
    -- contents and deposit without creating a second location or touching UI.
    if not C_Item.DoesItemExist(p.location) or C_Item.GetItemLink(p.location) ~= p.link
        or C_Item.GetStackCount(p.location) ~= p.count then
        invalidate("Selected item/stack changed; prepare again. No post sent.")
        return
    end
    local deposit
    if p.commodity then deposit = C_AuctionHouse.CalculateCommodityDeposit(p.itemID, p.duration, p.quantity)
    else deposit = C_AuctionHouse.CalculateItemDeposit(p.location, p.duration, p.quantity) end
    if deposit ~= p.deposit or type(deposit) ~= "number" or GetMoney() < deposit then
        invalidate("Deposit or available money changed; prepare again. No post sent.")
        return
    end
    -- Consume in Lua state before dispatch, but do not disable the clicked
    -- button, render, print or enter pcall before the restricted API call.
    attempted, preview = true, nil
    postPendingRender = true
    state = "Posting attempted; outcome unconfirmed. Inspect native Auctions."
    local needsConfirmation
    if p.commodity then
        needsConfirmation = C_AuctionHouse.PostCommodity(p.location, p.duration, p.quantity, p.price)
    else
        needsConfirmation = C_AuctionHouse.PostItem(p.location, p.duration, p.quantity, nil, p.price)
    end
    record("direct-call returned item=" .. p.itemID .. " quantity=" .. p.quantity .. " price=" .. p.price
        .. " duration=" .. p.duration .. " needsConfirmation=" .. tostring(needsConfirmation))
    if needsConfirmation then
        invalidate("Native confirmation required; not confirmed by probe. Inspect native UI before another action.")
    end
    render()
end

local function handoff()
    ready()
    local p = preview
    if not p then error("prepare and review an item first") end
    local current = inspect(p.bag, p.slot, p.quantity, p.price, p.duration)
    if current.link ~= p.link or current.count ~= p.count or current.deposit ~= p.deposit
        or current.commodity ~= p.commodity then error("item/quantity/deposit changed; prepare again") end
    if not p.commodity then error("native handoff investigation currently supports commodity samples only") end
    local ah = AuctionHouseFrame
    local sell = ah and ah.CommoditiesSellFrame
    if not ah or type(ah.SetPostItem) ~= "function" or not sell or not sell.QuantityInput
        or not sell.PriceInput or not sell.Duration or not sell.Duration.Dropdown
        or type(sell.Duration.Dropdown.GenerateMenu) ~= "function" then error("native Sell controls unavailable") end
    -- This only prepares Blizzard's own visible sell surface. Never invoke its
    -- PostItem/StartPost methods, click its button, or call transaction APIs.
    attempted, preview = true, nil
    ah:SetPostItem(current.location)
    if not sell:IsShown() or sell:GetItem() ~= current.location then
        error("native Sell did not accept selected item; inspect native UI; nothing posted by probe")
    end
    sell.QuantityInput:SetQuantity(p.quantity)
    sell.PriceInput:SetAmount(p.price)
    sell.Duration:SetDuration(p.duration)
    sell.Duration.Dropdown:GenerateMenu()
    sell:UpdatePostState()
    if sell:GetQuantity() ~= p.quantity or sell:GetUnitPrice() ~= p.price
        or sell:GetDuration() ~= p.duration then
        error("native fields differ from preview; do not post until reviewed")
    end
    state = "Transferred to native Sell; no post request sent by Copperwise. "
        .. "Review all native fields, then use Blizzard's Post button yourself. "
        .. "Native search updates may change the displayed price; verify it before posting."
    record("native-handoff item=" .. p.itemID .. " quantity=" .. p.quantity .. " price=" .. p.price
        .. " duration=" .. p.duration .. "; preparation only, not a transaction")
    record(state)
    render()
end

local function setup()
    if panel then return end
    local ah = AuctionHouseFrame
    if not ah or not ah.SetDisplayMode or not ah.Tabs or not ah.tabsForDisplayMode then error("modern native AH frame unavailable") end
    -- Do not hook restricted transaction functions: observe public events and
    -- verify outcomes in native Auctions instead. No shared transaction ownership
    -- is claimed by this probe.
    surfaceReady = true
    panel = CreateFrame("Frame", nil, ah)
    panel:SetPoint("TOPLEFT", 20, -65)
    panel:SetPoint("BOTTOMRIGHT", -20, 35)
    panel:Hide()
    ah.CopperwisePostingProbePanel = panel
    output = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    output:SetPoint("TOPLEFT", 12, -55)
    output:SetPoint("BOTTOMRIGHT", -12, 10)
    output:SetJustifyH("LEFT")
    output:SetJustifyV("TOP")
    local function button(label, x, action)
        local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        b:SetSize(170, 24)
        b:SetPoint("TOPLEFT", x, -10)
        b:SetText(label)
        b:SetScript("OnClick", guard(action))
        return b
    end
    panel.PostItem = post
    postButton = CreateFrame("Button", "CopperwisePostOnceButton", panel, "CopperwisePostingButtonTemplate")
    postButton:SetSize(140, 24)
    postButton:SetPoint("TOPLEFT", 12, -10)
    postButton:SetText("Post once")
    -- XML OnClick mirrors Auctionator's parent:PostItem() call. Never replace
    -- this with guard()/pcall or programmatically click it from slash commands.
    handoffButton = button("Native Sell fallback", 162, handoff)
    button("Cancel preview", 342, function() invalidate("Preview cancelled. Native Sell must be cleared separately after a handoff.") end)
    tab = CreateFrame("Button", "CopperwisePostingProbeTab", ah, "AuctionHouseFrameDisplayModeTabTemplate")
    tab:SetText("CW posting")
    PanelTemplates_TabResize(tab, 20, nil, 70)
    -- Append after all current native-template tabs, including the scan probe.
    local previous = ah.Tabs[#ah.Tabs - 1] or ah.AuctionsTab
    tab:SetPoint("LEFT", previous, "RIGHT", -15, 0)
    tab.displayMode = mode
    tab:SetID(#ah.Tabs)
    ah.tabsForDisplayMode[mode] = #ah.Tabs
    PanelTemplates_SetNumTabs(ah, #ah.Tabs)
    PanelTemplates_DeselectTab(tab)
    tab:SetScript("OnClick", guard(function()
        ah:SetDisplayMode(mode)
        ah:SetTitle("Copperwise — posting probe")
        PanelTemplates_SelectTab(tab)
    end))
    hooksecurefunc(ah, "SetDisplayMode", function(_, current)
        if current ~= mode then panel:Hide(); PanelTemplates_DeselectTab(tab) end
    end)
    panel:SetScript("OnHide", function() invalidate("Posting surface hidden; preview discarded. Any native transaction outcome still needs verification.") end)
    render()
end

SLASH_COPPERWISEPOSTINGPROBE1 = "/cwpost"
SlashCmdList.COPPERWISEPOSTINGPROBE = guard(function(message)
    local command, arguments = (message or ""):match("^(%S*)%s*(.-)%s*$")
    if command == "" then
        if not houseOpen then error("visit an auctioneer first") end
        setup()
        tab:Click()
    elseif command == "prepare" then prepare(arguments)
    elseif command == "cancel" then invalidate("Preview cancelled; no automatic action.")
    elseif command == "note" then record("operator-note=" .. arguments)
    elseif command == "status" then
        local version, build, _, interface = GetBuildInfo()
        record("client=" .. version .. " build=" .. build .. " interface=" .. interface
            .. " realm=" .. tostring(GetRealmName()) .. " faction=" .. tostring(UnitFactionGroup("player"))
            .. " region=" .. tostring(GetCurrentRegion()) .. " open=" .. tostring(houseOpen) .. " attempted=" .. tostring(attempted))
        record(state)
    else error("use /cwpost, prepare, cancel, status, note <observed outcome>; posting requires the button") end
end)

frame:SetScript("OnEvent", guard(function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        if type(CopperwisePostingEvidence) ~= "table" then CopperwisePostingEvidence = {} end
        session = {}
        table.insert(CopperwisePostingEvidence, session)
        while #CopperwisePostingEvidence > 5 do table.remove(CopperwisePostingEvidence, 1) end
        record("S08 probe loaded; /cwpost status; no transaction on login")
    elseif event == "AUCTION_HOUSE_SHOW" then
        houseOpen, attempted = true, false
        setup()
    elseif event == "AUCTION_HOUSE_CLOSED" then
        houseOpen = false
        invalidate("AH closed; preview discarded. Verify any prior request in native Auctions.")
    elseif event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
        if attempted then
            local _, blockedFunction = ...
            invalidate("Client blocked action: " .. tostring(blockedFunction) .. "; posting blocked; no retry sent.")
        end
    elseif event == "BAG_UPDATE" or event == "ITEM_LOCK_CHANGED" or event == "PLAYER_MONEY" then
        if preview then invalidate("Inventory/lock/money changed; prepare again after updates settle.") end
    else
        if attempted then
            local values = {}
            for i = 1, select("#", ...) do values[i] = tostring(select(i, ...)) end
            record("event=" .. event .. " args=" .. table.concat(values, ",") .. "; inspect native Auctions; not an attributed success")
        end
    end
end))
for _, event in ipairs({"PLAYER_LOGIN", "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED", "BAG_UPDATE",
    "ITEM_LOCK_CHANGED", "PLAYER_MONEY", "ADDON_ACTION_BLOCKED", "ADDON_ACTION_FORBIDDEN", "AUCTION_MULTISELL_START", "AUCTION_MULTISELL_UPDATE",
    "AUCTION_MULTISELL_FAILURE", "OWNED_AUCTIONS_UPDATED", "AUCTION_HOUSE_SHOW_ERROR", "UI_ERROR_MESSAGE"}) do
    local ok = pcall(frame.RegisterEvent, frame, event)
    if not ok then record("unsupported event=" .. event) end
end

frame:SetScript("OnUpdate", function()
    if postPendingRender then
        postPendingRender = false
        render()
        record("Post action consumed; " .. state)
    end
    if #pendingChat == 0 then return end
    local messages = pendingChat
    pendingChat = {}
    for _, message in ipairs(messages) do print(message) end
end)
