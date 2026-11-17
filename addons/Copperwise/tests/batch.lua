-- Simulated native boundary: all production modules, actual UI actions/events.
-- Run: luajit addons/Copperwise/tests/batch.lua
local function session(items, summaries, options)
    options = options or {}
    local env = setmetatable({}, {__index=_G})
    local s = {clock=10, frames={}, widgets={}, network={}, owned={}, posts={}, summaries=summaries,
        full=true, ready=true, confirmPosts=true, targetRequests={}, items=items}
    local methods = {}
    for _, name in ipairs({"SetPoint", "SetSize", "SetWidth", "SetHeight", "SetJustifyH", "SetJustifyV",
        "SetID", "RegisterEvent", "SetTitle", "SetHighlightTexture", "SetAllPoints", "SetColorTexture",
        "SetWordWrap", "ClearAllPoints", "SetAutoFocus", "SetMaxLetters", "SetNumeric", "SetTexture",
        "SetChecked", "SetScrollChild"}) do methods[name] = function() end end
    local function widget(kind) local w=setmetatable({scripts={}, shown=true, kind=kind}, {__index=methods}); s.widgets[#s.widgets+1]=w; return w end
    function methods:SetScript(name, fn) self.scripts[name]=fn end
    function methods:HookScript(name, fn)
        local previous=self.scripts[name]
        self.scripts[name]=function(...) if previous then previous(...) end; fn(...) end
    end
    function methods:SetText(value)
        self.text=tostring(value)
        if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self) end
    end
    function methods:GetText() return self.text or "" end
    function methods:SetEnabled(value) self.enabled=value end
    function methods:HasFocus() return false end
    function methods:ClearFocus() end
    function methods:CreateFontString() return widget("FontString") end
    function methods:CreateTexture() return widget("Texture") end
    function methods:IsShown() return self.shown end
    function methods:Show() local old=self.shown; self.shown=true; if not old and self.scripts.OnShow then self.scripts.OnShow(self) end end
    function methods:Hide() local old=self.shown; self.shown=false; if old and self.scripts.OnHide then self.scripts.OnHide(self) end end
    function methods:SetShown(value) if value then self:Show() else self:Hide() end end
    env.CreateFrame=function(kind, name, parent, template)
        local w=widget(kind); w.parent=parent
        if name then env[name]=w end
        if template == "CopperwisePostAllButtonTemplate" then w.scripts.OnClick=function() parent:PostAll() end end
        if template == "CopperwisePostItemButtonTemplate" then w.scripts.OnClick=function() parent:PostItem() end end
        s.frames[#s.frames+1]=w; return w
    end
    env.GetTime=function() return s.clock end
    env.time=function() return 1000+math.floor(s.clock) end
    env.date=function() return "test time" end
    env.print=function() end
    env.GetRealmName=function() return "Realm" end
    env.GetCurrentRegion=function() return 3 end
    env.UnitFactionGroup=function() return "Alliance" end
    env.CursorHasItem=function() return false end
    env.GetMoney=function() return s.money or 100000 end
    env.GetCoinTextureString=function(n) return n .. "c" end
    env.GetBuildInfo=function() return "test", "test", "", 16001 end
    env.SlashCmdList, env.StaticPopupDialogs, env.UISpecialFrames={}, {}, {}
    env.ItemLocation={CreateFromBagAndSlot=function(_, bag, slot) return {bag=bag, slot=slot} end}
    env.Enum={ItemCommodityStatus={Commodity=1}}
    local function source(location) return items[location.slot] end
    env.C_Container={
        GetContainerNumSlots=function(bag) return bag==0 and #items or 0 end,
        GetContainerItemInfo=function(_, slot)
            local item=items[slot]
            if item.quantity==0 then return end
            return {itemID=item.id, stackCount=item.quantity, hyperlink="item:"..item.id, isLocked=item.locked}
        end,
    }
    env.C_Item={
        GetItemInfo=function(id)
            for _, item in ipairs(items) do if item.id==id then return "Item "..id, nil,nil,nil,nil,nil,nil,nil,nil,123,item.sell end end
        end,
        DoesItemExist=function(location) return source(location).quantity>0 end,
        GetItemLink=function(location) return "item:"..source(location).id end,
        GetStackCount=function(location) return source(location).quantity end,
    }
    local function forbidden() error("Batch must not load individual listings") end
    env.C_AuctionHouse={
        MakeItemKey=function(id) return {itemID=id} end,
        GetItemKeyInfo=function(key)
            for _, item in ipairs(items) do if item.id==key.itemID then return {isCommodity=item.supported~=false} end end
        end,
        IsThrottledMessageSystemReady=function() return s.ready end,
        IsSellItemValid=function(location) return not source(location).invalid end,
        GetItemCommodityStatus=function() return 1 end,
        GetAvailablePostCount=function(location)
            local total=0; for _, item in ipairs(items) do if item.id==source(location).id then total=total+item.quantity end end; return total
        end,
        CalculateCommodityDeposit=function() return s.deposit or 100 end,
        SendSearchQuery=forbidden, RequestMoreCommoditySearchResults=forbidden,
        SearchForItemKeys=function(keys)
            s.targetRequests[#s.targetRequests+1]=keys
            local wanted={}; for _, key in ipairs(keys) do wanted[key.itemID]=true end
            s.responseRows={}
            for _, row in ipairs(s.summaries) do if wanted[row.itemKey.itemID] then s.responseRows[#s.responseRows+1]=row end end
            s.network[#s.network+1]="AUCTION_HOUSE_BROWSE_RESULTS_UPDATED"
        end,
        SendBrowseQuery=function() s.responseRows=nil; s.network[#s.network+1]="AUCTION_HOUSE_BROWSE_RESULTS_UPDATED" end,
        RequestMoreBrowseResults=function() s.network[#s.network+1]="AUCTION_HOUSE_BROWSE_RESULTS_ADDED" end,
        GetBrowseResults=function() return s.responseRows or s.summaries end,
        HasFullBrowseResults=function() return s.full end,
        QueryOwnedAuctions=function() s.network[#s.network+1]="OWNED_AUCTIONS_UPDATED" end,
        HasFullOwnedAuctionResults=function() return true end,
        GetNumOwnedAuctions=function() return #s.owned end,
        GetOwnedAuctionInfo=function(index) return s.owned[index] end,
        PostCommodity=function(location, duration, quantity, price)
            local id=source(location).id
            s.posts[#s.posts+1]={id=id, duration=duration, quantity=quantity, price=price}
            if s.blockPost then s:event("ADDON_ACTION_BLOCKED", "Copperwise"); return end
            if s.confirmPosts then
                s.owned[#s.owned+1]={auctionID=#s.owned+100, itemKey={itemID=id}, quantity=quantity, buyoutAmount=price}
                local remaining=quantity
                for _, item in ipairs(items) do if item.id==id then
                    local take=math.min(remaining,item.quantity); item.quantity=item.quantity-take; remaining=remaining-take
                end end
                s:event("BAG_UPDATE")
            end
            return s.needsConfirmation
        end,
    }
    env.hooksecurefunc=function(target, name, hook)
        local original=target[name]; target[name]=function(...) local value=original(...); hook(...); return value end
    end
    for _, name in ipairs({"PanelTemplates_TabResize", "PanelTemplates_SetNumTabs", "PanelTemplates_DeselectTab", "PanelTemplates_SelectTab"}) do env[name]=function() end end
    env.AuctionHouseFrameDisplayMode={}
    env.AuctionHouseFrame=widget(); env.AuctionHouseFrame.Tabs={widget(),widget(),widget()}; env.AuctionHouseFrame.tabsForDisplayMode={}
    function env.AuctionHouseFrame:SetDisplayMode(mode)
        if mode==env.AuctionHouseFrameDisplayMode.CopperwiseMarket then self.CopperwiseMarketPanel:Show() end
    end
    local saved={}
    for _, item in ipairs(items) do
        if item.destination and not saved[item.id] then saved[item.id]={quantity=item.intended or item.quantity, destination=item.destination, name="Item "..item.id} end
    end
    env.CopperwiseDB=options.character or {salePlan={version=1,items=saved}, minimumListedUnits=options.minimum}
    for _, name in ipairs({"Inventory", "Storage", "Intent", "Listings", "Posting", "Review", "Batch", "Scan"}) do
        setfenv(assert(loadfile("addons/Copperwise/"..name..".lua")),env)()
    end
    function s:event(event, ...)
        for _, f in ipairs(self.frames) do if f.scripts.OnEvent then f.scripts.OnEvent(f,event,...) end end
    end
    function s:tick(seconds)
        for _=1,math.ceil(seconds/0.25) do
            self.clock=self.clock+0.25
            local network=self.network; self.network={}
            for _, event in ipairs(network) do self:event(event) end
            for _, f in ipairs(self.frames) do if f.scripts.OnUpdate and f.shown then f.scripts.OnUpdate(f,0.25) end end
        end
    end
    function s:clickPostAll() env.Copperwise.batchButton.scripts.OnClick(env.Copperwise.batchButton) end
    s.env, s.cw=env,env.Copperwise
    s:event("PLAYER_LOGIN"); s:tick(2); s:event("AUCTION_HOUSE_SHOW")
    env.AuctionHouseFrame:SetDisplayMode(env.AuctionHouseFrameDisplayMode.CopperwiseMarket)
    s:tick(3)
    return s
end

local function summary(id, price, units) return {itemKey={itemID=id}, minPrice=price, totalQuantity=units} end
local function item(id, sell, destination, quantity) return {id=id, sell=sell, destination=destination or "AH", quantity=quantity or 10} end
local function test(name, fn) fn(); print("PASS: "..name) end

test("fresh summary prices override cached values, exact minimum passes, only AH intent posts", function()
    local s=session({item(1,10),item(2,0,"Vendor")},{summary(1,20,500)})
    assert(#s.posts==0 and #s.targetRequests==0)
    s:clickPostAll(); s:tick(8)
    assert(#s.targetRequests==1 and #s.targetRequests[1]==1 and s.targetRequests[1][1].itemID==1)
    assert(#s.posts==1 and s.posts[1].price==20 and s.posts[1].quantity==10 and s.posts[1].duration==2)
    assert(not s.cw.SaleIntent(1) and s.cw.SaleIntent(2).quantity==10)
    assert(not s.cw.BatchActive())
end)

test("default supply filter and fresh after-cut vendor comparison preserve skipped intent", function()
    local s=session({item(1,1),item(2,19),item(3,20),item(4,nil),item(5,0)},
        {summary(1,100,499),summary(2,20,500),summary(3,20,500),summary(4,100,500),summary(5,0,500)})
    s:clickPostAll(); s:tick(8)
    assert(#s.posts==0 and not s.cw.BatchActive())
    assert(s.cw.BatchItemReason(1):find("499 / 500",1,true))
    assert(s.cw.BatchItemReason(2):find("does not beat vendor",1,true))
    assert(s.cw.BatchItemReason(3):find("does not beat vendor",1,true))
    assert(s.cw.BatchItemReason(4)=="Vendor value unavailable")
    assert(s.cw.SaleIntent(5).quantity==10)
end)

test("a changed deposit cannot silently replace the deposit reviewed at batch start", function()
    local s=session({item(1,1)},{summary(1,100,500)})
    s:clickPostAll()
    s.deposit=200
    s:tick(8)
    assert(#s.posts==0, "Changed deposit must stop before spending")
    assert(s.cw.SaleIntent(1).quantity==10)
end)

test("several item types and source stacks advance only after confirmed outcomes", function()
    local first=item(1,1,"AH",3); first.intended=10
    local unmarked=item(3,0); unmarked.destination=nil
    local s=session({first,item(1,1,"AH",7),item(2,0),unmarked},{summary(1,20,500),summary(2,5,600)})
    s:clickPostAll(); s:tick(12)
    assert(#s.posts==2 and s.posts[1].quantity==10 and s.posts[2].id==2)
    assert(not s.cw.SaleIntent(1) and not s.cw.SaleIntent(2) and not s.cw.BatchActive())
    assert(s.items[4].quantity==10)
end)

test("configured supply threshold permits a small market without changing default behavior", function()
    local s=session({item(1,0)},{summary(1,2,20)},{minimum=20})
    s:clickPostAll(); s:tick(8)
    assert(#s.posts==1 and not s.cw.SaleIntent(1))
    assert(s.cw.MinimumListedUnits()==20)
end)

test("rounding down net proceeds prevents a fractional copper advantage from posting", function()
    local s=session({item(1,1,"AH",1)},{summary(1,2,500)})
    s:clickPostAll(); s:tick(8)
    assert(#s.posts==0 and s.cw.SaleIntent(1).quantity==1)
end)

test("unconfirmed outcomes cannot advance or be retried by repeated clicks", function()
    local s=session({item(1,1),item(2,1)},{summary(1,20,500),summary(2,20,500)})
    s.confirmPosts=false
    s:clickPostAll(); s:tick(5); s:clickPostAll(); s:tick(32); s:clickPostAll(); s:tick(3)
    assert(#s.posts==1 and s.cw.SaleIntent(1).quantity==10 and s.cw.SaleIntent(2).quantity==10)
    local _, pending=s.cw.PostingNotice(); assert(pending and not s.cw.BatchActive())
end)

test("Stop prevents new dispatches while a confirmed in-flight result can still reduce intent", function()
    local s=session({item(1,1),item(2,1)},{summary(1,20,500),summary(2,20,500)})
    s.confirmPosts=false
    s:clickPostAll(); s:tick(4)
    assert(#s.posts==1)
    s.cw.fullScanButton.scripts.OnClick()
    s.owned={{auctionID=100,itemKey={itemID=1},quantity=10,buyoutAmount=20}}
    s.items[1].quantity=0; s:event("BAG_UPDATE"); s:event("AUCTION_MULTISELL_UPDATE")
    s:tick(8)
    assert(#s.posts==1 and not s.cw.BatchActive() and not s.cw.SaleIntent(1) and s.cw.SaleIntent(2).quantity==10)
end)

test("changed intent is outside the captured batch", function()
    local s=session({item(1,1),item(2,1)},{summary(1,20,500),summary(2,20,500)})
    s:clickPostAll(); s:tick(1)
    assert(s.cw.ChangeIntent(2,"edit",5))
    s:tick(10)
    assert(#s.posts==1 and s.posts[1].id==1 and s.cw.SaleIntent(2).quantity==5 and not s.cw.BatchActive())
end)

test("partial targeted pages never post or replace the retained full-market scan", function()
    local s=session({item(1,1)},{summary(1,20,500)})
    s:tick(3); s.cw.Scan(); s:tick(2)
    local retained=s.cw.ObservationFor(1)
    assert(retained.minimum==20)
    s.full=false; s.summaries={summary(1,30,501)}
    s:clickPostAll(); s:tick(2)
    assert(#s.posts==0 and s.cw.ObservationFor(1).minimum==20)
    s.full=true; s:event("AUCTION_HOUSE_BROWSE_RESULTS_ADDED"); s:tick(8)
    assert(#s.posts==1 and s.posts[1].price==30 and s.cw.ObservationFor(1).minimum==20)
end)

test("competing AH activity stops the batch and late summaries cannot post", function()
    local s=session({item(1,1)},{summary(1,20,500)})
    s:clickPostAll(); s:tick(0.25)
    s.env.C_AuctionHouse.SearchForItemKeys({{itemID=2}}, {})
    s:tick(8)
    assert(#s.posts==0 and not s.cw.BatchActive() and s.cw.SaleIntent(1).quantity==10)
end)

test("a blocked automatic post requires reconciliation and subsequent hardware clicks", function()
    local s=session({item(1,1),item(2,1)},{summary(1,20,500),summary(2,20,500)})
    s.blockPost=true; s:clickPostAll(); s:tick(5)
    assert(#s.posts==1 and not s.cw.BatchActive())
    local _, token=s.cw.PendingPostDetails(); assert(token)
    s.cw.ResolvePost(false,token); s.blockPost=false
    s:clickPostAll(); s:tick(4)
    assert(#s.posts==1 and s.cw.batchButton.text=="Continue posting")
    s:clickPostAll(); s:tick(6)
    assert(#s.posts==2 and s.cw.SaleIntent(2).quantity==10)
    s:clickPostAll(); s:tick(6)
    assert(#s.posts==3 and not s.cw.BatchActive())
end)

test("an invalid edited quantity is not silently replaced by maximum holdings", function()
    local s=session({item(1,1)},{summary(1,20,500)})
    local quantity
    for _, w in ipairs(s.widgets) do
        if w.kind=="EditBox" and w.scripts.OnTextChanged then quantity=w; break end
    end
    assert(quantity); quantity:SetText("")
    s:clickPostAll(); s:tick(8)
    assert(#s.posts==0 and s.cw.SaleIntent(1).quantity==10)
end)

test("large selected sets use bounded targeted chunks and never fetch price levels", function()
    local items, summaries={},{}
    for id=1,101 do items[id]=item(id,1); summaries[id]=summary(id,100,499) end
    local s=session(items,summaries)
    s:clickPostAll(); s:tick(35)
    assert(#s.targetRequests==2 and #s.targetRequests[1]==100 and #s.targetRequests[2]==1)
    assert(#s.posts==0 and not s.cw.BatchActive() and s.cw.SaleIntent(101).quantity==10)
end)

test("conflicting summaries and missing buyouts withhold posting", function()
    local s=session({item(1,1)},{summary(1,20,500),summary(1,30,500)})
    s:clickPostAll(); s:tick(5)
    assert(#s.posts==0 and not s.cw.BatchActive() and s.cw.SaleIntent(1).quantity==10)
end)

test("AH closure never resumes the batch and preserves an unresolved post across login", function()
    local s=session({item(1,1),item(2,1)},{summary(1,20,500),summary(2,20,500)})
    s.confirmPosts=false; s:clickPostAll(); s:tick(4)
    assert(#s.posts==1)
    s:event("AUCTION_HOUSE_CLOSED"); s:tick(5)
    assert(not s.cw.BatchActive())
    local restored=session({item(1,1),item(2,1)},{summary(1,20,500),summary(2,20,500)}, {character=s.env.CopperwiseDB})
    restored:clickPostAll(); restored:tick(5)
    local _, pending=restored.cw.PostingNotice()
    assert(#restored.posts==0 and #restored.targetRequests==0 and pending and not restored.cw.BatchActive())
end)

test("prices expire while posting attribution is delayed", function()
    local s=session({item(1,1)},{summary(1,20,500)})
    s:clickPostAll(); s:tick(0.5)
    s.ready=false; s:tick(61); s.ready=true; s:tick(4)
    assert(#s.posts==0 and not s.cw.BatchActive() and s.cw.SaleIntent(1).quantity==10)
end)

test("shortages retain the unposted marked remainder", function()
    local first=item(1,1,"AH",3); first.intended=10
    local s=session({first},{summary(1,20,500)})
    s:clickPostAll(); s:tick(8)
    assert(#s.posts==1 and s.posts[1].quantity==3 and s.cw.SaleIntent(1).quantity==7)
end)

test("native confirmation pauses the batch immediately without bypassing the dialog", function()
    local s=session({item(1,1),item(2,1)},{summary(1,20,500),summary(2,20,500)})
    s.needsConfirmation=true; s.confirmPosts=false
    s:clickPostAll(); s:tick(5)
    local _, pending=s.cw.PostingNotice()
    assert(#s.posts==1 and pending and not s.cw.BatchActive())
end)
