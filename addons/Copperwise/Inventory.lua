Copperwise = {}
local CW = Copperwise
local frame = CreateFrame("Frame")
local window, output, picker
local rows, selected, candidate, candidateAt, dirtyAt = {}, nil, nil, 0, 0
local settled = false

local function money(value)
    if value == nil then return "unavailable" end
    if type(GetCoinTextureString) == "function" then return GetCoinTextureString(value) end
    if type(GetMoneyString) == "function" then return GetMoneyString(value) end
    local gold = math.floor(value / 10000)
    local silver = math.floor(value / 100) % 100
    local copper = value % 100
    return string.format("%dg %ds %dc", gold, silver, copper)
end

function CW.SelectedItem()
    if settled and not CursorHasItem() then return rows[selected] end
end

function CW.Render()
    if not output then return end
    local item = rows[selected]
    local ready = CW.SelectedItem()
    local text = "Select a bag item from the menu.\nBackpack and bags only; bank and equipment excluded."
    if item then
        text = (item.link or item.name) .. "\nItem ID: " .. item.id
            .. "\nBag quantity: " .. (ready and tostring(item.quantity) or "updating — totals withheld")
            .. "\nVendor sell / unit: " .. money(item.sell)
            .. "\nVendor sell / owned quantity: " .. money(ready and item.sell and item.sell * item.quantity or nil)
            .. "\nSupport: " .. item.support
    end
    local observation = item and CW.ObservationFor and CW.ObservationFor(item.id)
    if observation then
        text = text .. "\n\nRetained full-scan observation"
            .. "\nLowest observed asking / unit: " .. money(observation.minimum)
            .. "\nAvailable supply: " .. observation.units
            .. "\nCoverage: complete market summary" .. (observation.empty and " (item absent)" or "")
            .. "\nObserved locally: " .. date("%Y-%m-%d %H:%M:%S %Z", observation.observedAt)
            .. "\nAge: " .. math.max(0, math.floor((time() - observation.observedAt) / 60)) .. " minutes"
            .. "\nMarket: " .. observation.context
    else
        text = text .. "\n\nAH values unavailable for this selection."
    end
    if CW.attempt then
        text = text .. "\n\nLatest full scan: " .. CW.attempt.state .. "\n" .. CW.attempt.reason
    else
        text = text .. "\n\nNo scan attempted this session."
    end
    text = text .. "\n\nRefresh market data with Full scan in the Copperwise auction-house tab."
        .. "\nRetained asking values are not live prices or completed sales."
    output:SetText(text)
end

local function snapshot()
    local nextRows, signature, locked = {}, {}, CursorHasItem()
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info then
                local id = info.itemID
                if not id or type(info.stackCount) ~= "number" then return nil end
                locked = locked or info.isLocked
                signature[#signature+1] = bag .. ":" .. slot .. ":" .. id .. ":" .. info.stackCount
                local row = nextRows[id] or {id=id, quantity=0, link=info.hyperlink}
                row.quantity = row.quantity + info.stackCount
                local name, _, _, _, _, _, _, _, _, _, sell = C_Item.GetItemInfo(id)
                row.name, row.sell = name or ("Item " .. id), sell
                row.support = "metadata loading"
                if C_AuctionHouse and C_AuctionHouse.MakeItemKey and C_AuctionHouse.GetItemKeyInfo then
                    local key = C_AuctionHouse.MakeItemKey(id, 0, 0, 0)
                    local keyInfo = C_AuctionHouse.GetItemKeyInfo(key)
                    if keyInfo and type(keyInfo.isCommodity) == "boolean" then
                        row.support = keyInfo.isCommodity and "comparable commodity" or "unsupported (noncommodity)"
                    end
                end
                nextRows[id] = row
            end
        end
    end
    if locked then return nil end
    return table.concat(signature, "|"), nextRows
end

local function open()
    if not window then
        window = CreateFrame("Frame", "CopperwiseInventory", UIParent, "BasicFrameTemplateWithInset")
        window:SetSize(620, 590)
        window:SetPoint("CENTER")
        window:SetMovable(true)
        window:EnableMouse(true)
        window:RegisterForDrag("LeftButton")
        window:SetScript("OnDragStart", window.StartMoving)
        window:SetScript("OnDragStop", window.StopMovingOrSizing)
        window.TitleText:SetText("Copperwise — Inventory")
        table.insert(UISpecialFrames, "CopperwiseInventory")
        picker = CreateFrame("Frame", "CopperwiseItemPicker", window, "UIDropDownMenuTemplate")
        picker:SetPoint("TOPLEFT", 0, -35)
        UIDropDownMenu_SetWidth(picker, 350)
        UIDropDownMenu_SetText(picker, "Select a bag item")
        UIDropDownMenu_Initialize(picker, function()
            local choices = {}
            for _, row in pairs(rows) do choices[#choices+1] = row end
            table.sort(choices, function(a,b) return a.name == b.name and a.id < b.id or a.name < b.name end)
            for _, row in ipairs(choices) do
                local id = row.id
                local info = UIDropDownMenu_CreateInfo()
                info.text, info.checked = row.name, selected == id
                info.func = function()
                    selected = id
                    UIDropDownMenu_SetText(picker, rows[id] and rows[id].name or "Item removed")
                    CW.Render()
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        output = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        output:SetPoint("TOPLEFT", 22, -85)
        output:SetPoint("BOTTOMRIGHT", -22, 20)
        output:SetJustifyH("LEFT")
        output:SetJustifyV("TOP")
    end
    window:Show()
    CW.Render()
end

SLASH_COPPERWISE1 = "/copperwise"
SLASH_COPPERWISE2 = "/cw"
SlashCmdList.COPPERWISE = open
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("ITEM_LOCK_CHANGED")
frame:RegisterEvent("CURSOR_CHANGED")
frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
frame:SetScript("OnEvent", function(_, event)
    if event ~= "GET_ITEM_INFO_RECEIVED" then
        settled, candidate, dirtyAt = false, nil, GetTime()
    end
    CW.Render()
end)
local elapsed = 0
frame:SetScript("OnUpdate", function(_, dt)
    elapsed = elapsed + dt
    if elapsed < 0.25 then return end
    elapsed = 0
    local signature, nextRows = snapshot()
    if not signature then
        settled, candidate = false, nil
    elseif signature ~= candidate then
        settled, candidate, candidateAt = false, signature, GetTime()
    elseif GetTime() - candidateAt >= 0.75 and GetTime() - dirtyAt >= 0.75 then
        rows, settled = nextRows, true
    end
    CW.Render()
end)
