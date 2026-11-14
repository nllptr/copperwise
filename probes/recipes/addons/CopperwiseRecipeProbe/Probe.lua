local session
local professionOpen, merchantOpen = false, false
local frame = CreateFrame("Frame")
local function value(v)
    if v == nil then return "unavailable" end
    return tostring(v)
end

local function record(message)
    local line = string.sub("t=" .. time() .. " " .. message, 1, 900)
    print("Copperwise recipe probe: " .. line)
    if session then
        table.insert(session.events, line)
        while #session.events > 400 do table.remove(session.events, 1) end
    end
end

local function api(name, ...)
    local fn = C_TradeSkillUI and C_TradeSkillUI[name]
    if type(fn) ~= "function" then error("C_TradeSkillUI." .. name .. " unavailable") end
    return fn(...)
end

local function context()
    if not professionOpen then error("open your own profession window first") end
    -- Record rather than infer ownership when a context API is absent.
    local own = true
    for _, name in ipairs({"IsTradeSkillLinked", "IsTradeSkillGuild", "IsTradeSkillGuildMember", "IsNPCCrafting"}) do
        local fn = C_TradeSkillUI and C_TradeSkillUI[name]
        local result
        if type(fn) == "function" then result = fn() end
        record(name .. "=" .. value(result))
        if result ~= false then own = false end
    end
    local info = api("GetBaseProfessionInfo")
    record("profession=" .. value(info and info.professionName) .. " id="
        .. value(info and info.professionID) .. " skill=" .. value(info and info.skillLevel)
        .. " own-context-confirmed=" .. tostring(own))
    record("coverage=current opened profession/data source only; no complete catalog claim")
end

local function item(id)
    if not id then return "item=unavailable" end
    local lookup = C_Item and C_Item.GetItemInfo or GetItemInfo
    local name, sell
    if lookup then
        local info = {lookup(id)}
        name, sell = info[1], info[11]
    end
    return "item=" .. id .. " name=" .. value(name) .. " vendor-sell-copper/unit="
        .. value(sell) .. " acquisition-source=unknown vendor-purchase=unavailable"
end

local function recipe(id)
    context()
    local info = api("GetRecipeInfo", id)
    if not info then error("recipe metadata unavailable for " .. id) end
    record("recipe=" .. id .. " name=" .. value(info.name) .. " learned=" .. value(info.learned)
        .. " craftable=" .. value(info.craftable) .. " disabled=" .. value(info.disabled)
        .. " recipe-sourceType=" .. value(info.sourceType) .. " (not ingredient source)")
    local s = api("GetRecipeSchematic", id, false)
    if not s then error("schematic unavailable") end
    record("output " .. item(s.outputItemID) .. " recipeType=" .. value(s.recipeType)
        .. " yield-min=" .. value(s.quantityMin) .. " yield-max=" .. value(s.quantityMax))
    record("fixed-positive-yield=" .. tostring(type(s.quantityMin) == "number"
        and s.quantityMin > 0 and s.quantityMin == s.quantityMax)
        .. "; no assumed yield or crafting-cost estimate")
    if type(s.reagentSlotSchematics) ~= "table" then error("ingredient slots unavailable") end
    record("ingredient-slot-count=" .. #s.reagentSlotSchematics)
    for index, slot in ipairs(s.reagentSlotSchematics) do
        record("slot=" .. index .. " dataSlot=" .. value(slot.dataSlotIndex)
            .. " required=" .. value(slot.required) .. " quantity=" .. value(slot.quantityRequired)
            .. " reagentType=" .. value(slot.reagentType)
            .. " variable-quantity-entries=" .. value(slot.variableQuantities and #slot.variableQuantities))
        local choices = slot.reagents
        if type(choices) ~= "table" or #choices == 0 then
            record("slot=" .. index .. " identities unavailable; no complete ingredient claim")
        else
            record("slot=" .. index .. " alternatives=" .. #choices .. "; alternatives are not additive")
            for _, reagent in ipairs(choices) do
                record("slot=" .. index .. " " .. item(reagent.itemID)
                    .. " currencyID=" .. value(reagent.currencyID))
            end
        end
    end
end

local function catalog(offset)
    context()
    local ids = api("GetAllRecipeIDs")
    if type(ids) ~= "table" then error("recipe ID list unavailable") end
    local learned, unlearned, unknown = 0, 0, 0
    for _, id in ipairs(ids) do
        local info = api("GetRecipeInfo", id)
        if info and info.learned == true then learned = learned + 1
        elseif info and info.learned == false then unlearned = unlearned + 1
        else unknown = unknown + 1 end
    end
    record("GetAllRecipeIDs count=" .. #ids .. " learned=" .. learned .. " unlearned="
        .. unlearned .. " unknown=" .. unknown .. "; discovery observed, completeness unverified")
    for index = offset, math.min(offset + 14, #ids) do
        local info = api("GetRecipeInfo", ids[index])
        record("row=" .. index .. " recipe=" .. ids[index] .. " name=" .. value(info and info.name)
            .. " learned=" .. value(info and info.learned))
    end
    record("page-start=" .. offset .. "; next: /cwrecipes list " .. (offset + 15)
        .. "; inspect: /cwrecipes recipe <recipe ID>")
end

local function merchant(offset)
    if not merchantOpen then error("open a merchant first; no cached purchase quote") end
    if not GetMerchantNumItems or not GetMerchantItemID then error("merchant APIs unavailable") end
    record("merchant coverage=current vendor visible offers only; prices may vary by vendor/modifiers")
    for index = offset, math.min(offset + 14, GetMerchantNumItems()) do
        local info
        if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
            info = C_MerchantFrame.GetItemInfo(index)
        elseif GetMerchantItemInfo then
            local name, _, price, count, available, purchasable, _, extended = GetMerchantItemInfo(index)
            info = {name=name, price=price, stackCount=count, numAvailable=available,
                isPurchasable=purchasable, hasExtendedCost=extended}
        end
        if info then
            local unit = "unavailable"
            if info.hasExtendedCost == false and type(info.price) == "number"
                and type(info.stackCount) == "number" and info.stackCount > 0 then
                unit = tostring(info.price / info.stackCount)
            end
            record("merchant-slot=" .. index .. " item=" .. value(GetMerchantItemID(index))
                .. " name=" .. value(info.name) .. " bundle-price=" .. value(info.price)
                .. " bundle-count=" .. value(info.stackCount) .. " copper/unit=" .. unit
                .. " extended-cost=" .. value(info.hasExtendedCost) .. " available=" .. value(info.numAvailable)
                .. " purchasable=" .. value(info.isPurchasable))
        else record("merchant-slot=" .. index .. " metadata unavailable") end
    end
    record("no AH availability inferred; vendor and AH may both supply an item; source policy unresolved")
end

SLASH_COPPERWISERECIPEPROBE1 = "/cwrecipes"
SlashCmdList.COPPERWISERECIPEPROBE = function(message)
    local command, argument = (message or ""):match("^(%S*)%s*(.-)%s*$")
    local ok, err = pcall(function()
        if command == "note" then record("operator-note=" .. argument) return end
        if command == "" or command == "status" then context() return end
        local number = tonumber(argument)
        if argument == "" and (command == "list" or command == "merchant") then number = 1 end
        if not number or number < 1 or number ~= math.floor(number) then
            error("use list [row], recipe <ID>, merchant [row], status, note <outcome>")
        end
        if command == "list" then catalog(number)
        elseif command == "recipe" then recipe(number)
        elseif command == "merchant" then merchant(number)
        else error("unknown command") end
    end)
    if not ok then record("INCOMPLETE command; " .. tostring(err) .. "; preceding lines are partial evidence only") end
end

frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        if type(CopperwiseRecipeEvidence) ~= "table" then CopperwiseRecipeEvidence = {} end
        session = {events={}}
        table.insert(CopperwiseRecipeEvidence, session)
        while #CopperwiseRecipeEvidence > 5 do table.remove(CopperwiseRecipeEvidence, 1) end
        local version, build, _, interface = GetBuildInfo()
        record("client=" .. value(version) .. " build=" .. value(build) .. " interface=" .. value(interface)
            .. " platform=" .. (IsMacClient and IsMacClient() and "macOS" or "other/unknown"))
        record("read-only; open own profession then /cwrecipes list; merchant quotes require open vendor")
    elseif event == "TRADE_SKILL_SHOW" then professionOpen = true
    elseif event == "TRADE_SKILL_CLOSE" then professionOpen = false
    elseif event == "MERCHANT_SHOW" then merchantOpen = true
    elseif event == "MERCHANT_CLOSED" then merchantOpen = false end
    record("event=" .. event .. "; rerun command after UI data settles")
end)
for _, event in ipairs({"PLAYER_LOGIN", "TRADE_SKILL_SHOW", "TRADE_SKILL_CLOSE",
    "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_DATA_SOURCE_CHANGED", "MERCHANT_SHOW", "MERCHANT_CLOSED"}) do
    local ok, err = pcall(frame.RegisterEvent, frame, event)
    if not ok then record("unsupported event=" .. event .. " " .. tostring(err)) end
end
