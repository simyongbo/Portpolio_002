StringDataInit = require('Data/StringData')    
GameDataInit = require('Data/GameData')

local scrollbarColor = {bg=Color(128,128,128), handle=Color(255,255,255)}

local inven_category = {
    {name="전체", type={0,1,2,3,4,5,6,7,8,9,10}},
    {name="장비", type={0,1,2,3,4,5,6,7}},
    {name="소비", type={8,10}},
    {name="재료",type={9}},
}

local setting = {
    rect = {
        base = Rect(0,0,800,480),
        profile = Rect(20,80,200,380),
        equipment = Rect(230,40,285,420),
        inventory = Rect(525,40,275,420),
        popup = Rect(0,0,240,300),
    },
    inven = {
        col = 6,
        row = 7,
    },
    --slotID =  0:모자, 1:갑옷 2:무기 3:방패 4:신발 5,6:반지 7,8:악세 9:날개
    equip = {
        presets={
            {image="Pictures/btn1.png", select="Pictures/btn1_select.png", rect=Rect(-50, 30, 40, 40)},
            {image="Pictures/btn2.png", select="Pictures/btn2_select.png", rect=Rect(0, 30, 40, 40)},
            {image="Pictures/btn3.png", select="Pictures/btn3_select.png", rect=Rect(50, 30, 40, 40)},
        },

        characterImage={
            [0]={width=100,height=140,col=8,row=8, index=1},
            [1]={width=100,height=140,col=4,row=4, index=1},
        },

        slotSize=60,
        slots = {
            {slotID=7, position=Point(10,60), anchor=0},
            {slotID=8, position=Point(10,130), anchor=0},
            {slotID=5, position=Point(10,200), anchor=0},
            {slotID=6, position=Point(10,270), anchor=0},
            {slotID=0, position=Point(-70,60), anchor=2},
            {slotID=3, position=Point(-70,130), anchor=2},
            {slotID=4, position=Point(-70,200), anchor=2},
            {slotID=9, position=Point(-70,270), anchor=2},
            {slotID=2, position=Point(-70,-70), anchor=7},
            {slotID=1, position=Point(10,-70), anchor=7},
        },
    },
}

------------------------------------------------------------------------------------------------------------

local ui = {}

ui.base = {}

ui.profile = {}
ui.equipment = {}
ui.inventory = {}
ui.popup = {}
ui.registSlot = {}

local page = 1

function ShowCustomUI()
    HideCustomUI()

    local basepanel = Image("Pictures/new_titlepanel.png", setting.rect.base){anchor=4,pivotX=0.5,pivotY=0.5,showOnTop=true}
    ui.base.panel = basepanel

    local exit_img = Image("Pictures/close.png", Rect(-10,10,20,20)){anchor=2,pivotX=1,parent=basepanel}
    local exit = Button("", Rect(0,0,40,40)){anchor=4, pivotX=0.5, pivotY=0.5, color=Color(0,0,0,0), parent=exit_img}
    exit.onClick.Add(function ()
        HideCustomUI()
    end)

    Client.FireEvent("ShowProfile")
    ShowEquipment()
    ShowInventory()

end

function HideCustomUI()
    if ui.base.panel~=nil then
        ui.base.panel.Destroy()
        ui.base.panel=nil
    end
end

------------------------------------------------------------------------------------------------------------------------

function ShowProfile(list)
    HideProfile()

    local height = 30
    local padding = 1

    local basepanel = ScrollPanel(setting.rect.profile){color=Color(50,50,50,200), vertical=true, horizontal=false, parent=ui.base.panel}
    ui.profile.panel = basepanel

    local inpanel = Panel(Rect(0,0,basepanel.width, padding+#list*(height+padding))){color=Color(0,0,0,0), parent=basepanel}
    basepanel.content = inpanel

    for key,value in pairs(list) do
        local panel = Panel(Rect(0, padding+(key-1)*(height+padding), basepanel.width, height)){color=Color(0,0,0,0), parent=inpanel}
        local text = Text(value, Rect(0,0,panel.width, panel.height)){textAlign=4, parent=panel}

    end

end

function HideProfile()
    if ui.profile.panel~=nil then
        ui.profile.panel.Destroy()
        ui.profile.panel=nil
    end
end

------------------------------------------------------------------------------------------------------------------------

function ShowEquipment()
    HideEquipment()

    local basepanel = Panel(setting.rect.equipment){color=Color(0,0,0), parent=ui.base.panel}
    ui.equipment.panel = basepanel

    local characterPanel = Image("Pictures/Illust_20240428213945.jpg", Rect(0,0,ui.equipment.panel.width,ui.equipment.panel.height)){parent=ui.equipment.panel}
    ui.equipment.characterBG = characterPanel
    Client.FireEvent("CustomUI.Character")

    -------------------------------------------------------------------------------------------

    Client.FireEvent("CustomUI.Preset")
    
    -------------------------------------------------------------------------------------------

    for key,value in pairs(setting.equip.slots) do
        local rect = Rect(value.position.x, value.position.y, setting.equip.slotSize, setting.equip.slotSize)
        local slot = Image("Pictures/slot_new.png", rect){anchor=value.anchor, parent=basepanel}

        local item = Client.myPlayerUnit.GetEquipItem(value.slotID)
        if item~=nil then
            local iconSize = setting.equip.slotSize * 0.8
            local icon = Image("", Rect(0,0,iconSize, iconSize)){anchor=4, pivotX=0.5, pivotY=0.5, parent=slot}
            icon.SetImageID(Client.GetItem(item.dataID).imageID)

            local btn = Button("", Rect(0,0,slot.width,slot.height)){color=Color(0,0,0,0), parent=slot}
            btn.onClick.Add(function ()
                ShowItemPopup(item, false)
            end)
        end
    end

end

function HideEquipment()
     if ui.equipment.panel~=nil then
        ui.equipment.panel.Destroy()
        ui.equipment.panel=nil
    end
end

Client.GetTopic("CustomUI.Character").Add(function (characterID)
    local basepanel = ui.equipment.characterBG

    local info = nil
    if setting.equip.characterImage[characterID]==nil then
        info = {}
        info.width = 100
        info.height = 140
        info.col = 4
        info.row = 4
    else
        info = setting.equip.characterImage[characterID]
    end

    local mask = Panel(Rect(0,0,info.width, info.height)){masked=true, anchor=4, pivotX=0.5, pivotY=0.5, parent=basepanel}

    local posX = -math.floor(info.index % info.col) * info.width
    local posY = -math.floor(info.index / info.col) * info.height

    local character = Image("", Rect(posX, posY, mask.width*info.col, mask.height*info.row)){parent=mask}
    character.SetImageID(Client.GetCharacter(characterID).imageID)
    
end)

Client.GetTopic("CustomUI.Preset").Add(function (presetID)
    local basepanel = ui.equipment.panel

    for key,value in pairs(setting.equip.presets) do
        local slot = Image(key==presetID and value.select or value.image, value.rect){anchor=1, pivotX=0.5, pivotY=0.5, parent=basepanel}
        local btn = Button("", Rect(0,0,slot.width,slot.height)){color=Color(0,0,0,0), parent=slot}
        btn.onClick.Add(function ()
            Client.FireEvent("CustomUI.Preset", key)
        end)
    end
end)

------------------------------------------------------------------------------------------------------------------------

local category = 1

function ShowInventory()
    HideInventory()

    local basepanel = Panel(setting.rect.inventory){parent=ui.base.panel}
    ui.inventory.panel = basepanel

    ----------------------------------------------

    local upbar = Panel(Rect(0,0,basepanel.width,40)){color=Color(0,0,0,0), parent=basepanel}

    local categoryNames = {}
    for key,value in pairs(inven_category) do
        local panel = Panel(Rect((key-1)*62, 0,60,40)){color=Color(0,0,0,0), parent=upbar}
        categoryNames[key] = Text(value.name, Rect(0,0,panel.width,panel.height)){textAlign=4, textSize=12, parent=panel}
        if category==key then
            local selectBar = Panel(Rect(0,0,panel.width,2)){anchor=6, pivotY=1, color=Color(255,255,0), parent=panel}
        end

        local btn = Button("", Rect(0,0,panel.width,panel.height)){color=Color(0,0,0,0), parent=panel}
        btn.onClick.Add(function ()
            category = key
            page = 1
            ShowInventory()
        end)

    end

    ----------------------------------------------

    local items = GetItemsWhereCategory(Client.myPlayerUnit.GetItems())
    categoryNames[category].text = inven_category[category].name..'\n('..#items..')'
    local size = 40

    local spanel = ScrollPanel(Rect(0,45,basepanel.width, basepanel.height-85)){color=Color(70,70,70,70), vertical=false, horizontal=false, parent=basepanel}
    local inpanel = Panel(Rect(0,0,spanel.width, 5+setting.inven.row*(size+5))){color=Color(0,0,0,0), parent=spanel}
    spanel.content = inpanel

    ui.inventory.slots = {}
    for y=0,setting.inven.row-1 do
        for x=0,setting.inven.col-1 do
            local slot = Image("Pictures/slot_new.png", Rect(5+x*(size+5),5+y*(size+5),size,size)){parent=inpanel}
            ui.inventory.slots[y*setting.inven.col+x+1] = slot
        end
    end

    local maxCount = setting.inven.col * setting.inven.row
    local startIdx = (page-1) * maxCount

    for i=1,maxCount do
        local item = items[startIdx + i]

        if item then
            local slot = ui.inventory.slots[i]

            local icon = Image("", Rect(4,4,32,32)){parent=slot}
            icon.SetImageID(Client.GetItem(item.dataID).imageID)

            local count = Text(item.count, Rect(2,2,36,36)){textAlign=8, color=Color(255,255,255), borderEnabled=true, borderColor=Color(0,0,0), parent=slot}

            local equip = Text(Client.myPlayerUnit.IsEquippedItem(item.id) and 'E' or '', Rect(2,2,36,36)){textAlign=2, color=Color(255,255,0), borderEnabled=true, borderColor=Color(0,0,0), parent=slot}

            if item.level>0 then
                local level = Text('+'..item.level, Rect(2,2,36,36)){textAlign=0, color=Color(0,255,0), borderEnabled=true, borderColor=Color(0,0,0), parent=slot}
            end

            local button = Button("", Rect(0,0,size,size)){color=Color(0,0,0,0), parent=slot}
            button.onClick.Add(function ()
                ShowItemPopup(item)
            end)
        end
    end

    ----------------------------------------------

    local sortImg = Image("Pictures/sort.png", Rect(0,0,60,40)){anchor=6,pivotY=1, parent=basepanel}
    local sort = Button("", Rect(0,0,sortImg.width,sortImg.height)){color=Color(0,0,0,0), parent=sortImg}
    sort.onClick.Add(function ()
        Client.FireEvent("SortBagItems")
    end)

    ----------------------------------------------

    local pagePanel = Panel(Rect(70, 0, basepanel.width-70,40)){anchor=6,pivotY=1, parent=basepanel}

    local maxPage = math.ceil(#items/maxCount)
    local pageText = Text(page..'/'..maxPage, Rect(0,0,120,40)){anchor=7, pivotX=0.5, pivotY=1, textAlign=4, parent=pagePanel}

    local lbtn_img = Image("Pictures/left_arrow.png", Rect(25,0,40,40)){anchor=6, pivotX=0.5, pivotY=1, parent=pagePanel}
    local lbtn = Button("", Rect(0,0,lbtn_img.width,lbtn_img.height)){color=Color(0,0,0,0), parent=lbtn_img}
    lbtn.onClick.Add(function ()
        page = math.max(1, page-1)
        ShowInventory()
    end)

    local rbtn_img = Image("Pictures/right_arrow.png", Rect(-25,0,40,40)){anchor=8, pivotX=0.5, pivotY=1, parent=pagePanel}
    local rbtn = Button("", Rect(0,0,rbtn_img.width,rbtn_img.height)){color=Color(0,0,0,0), parent=rbtn_img}
    rbtn.onClick.Add(function ()
        page = math.min(maxPage, page+1)
        ShowInventory()
    end)
end

function HideInventory()
    if ui.inventory.panel~=nil then
        ui.inventory.panel.Destroy()
        ui.inventory.panel=nil
    end
end

------------------------------------------------------------------------------------------------------------------------

function ShowItemPopup(item, isButton)
    HideItemPopup()

    if isButton==nil then
        isButton = true
    end

    local basepanel = Image("Pictures/panel.png", setting.rect.popup){anchor=4, pivotX=0.5, pivotY=0.5, showOnTop=true}
    ui.popup.panel = basepanel

    local dataItem = Client.GetItem(item.dataID)
    
    -- icon
    local icon = Image("", Rect(20,15,40,40)){parent=basepanel}
    icon.SetImageID(dataItem.imageID)
    
    -- name
    local name = Text((item.level>0 and ('+'..item.level) or '').. dataItem.name, Rect(50,0,basepanel.width-50, 40)){textAlign=4, textSize=16, parent=basepanel}
    
    -- 거래 드랍 창고 판매
    local canTrade = dataItem.canTrade and '<color=#00FFFF>거래</color>' or '거래'
    local canDrop = dataItem.canDrop and '<color=#00FFFF>드랍</color>' or '드랍'
    local canStorage = dataItem.canStorage and '<color=#00FFFF>창고</color>' or '창고'
    local canSell = dataItem.canSell and '<color=#00FFFF>판매</color>' or '판매'

    local permit = Text(canTrade..' '..canDrop..' '..canStorage..' '..canSell, Rect(50, 35, basepanel.width-50, 20)){textAlign=4, textSize=14, parent=basepanel}

    -- desc
    local descStr = '종류:'..GetItemTypeName(dataItem.type)..'\n'..dataItem.desc

    if #item.options>0 then
        descStr = descStr..'\n\n<color=#FF00FF>옵션</color>'
        for key,opt in pairs(item.options) do
            descStr = descStr..'\n<color=#00FFFF>'..GetStatOption(opt.statID, opt.type, opt.value)..'</color>'
        end
    end

    local desc = Text(descStr, Rect(10,65,basepanel.width-20, 180)){textAlign=0, parent=basepanel}

    ui.popup.exit = Button("", Rect(0,0,Client.width,Client.height)){color=Color(0,0,0,0), anchor=4, pivotX=0.5,pivotY=0.5, parent=basepanel}
    ui.popup.exit.onClick.Add(function ()
        HideItemPopup()
    end)

    if isButton==false then
        return
    end

    -- button
    local buttonCount = 0
    if (ItemTypeGroup[dataItem.type]==1 or ItemTypeGroup[dataItem.type]==2) then
        -- 1번 버튼 활성화
        buttonCount = buttonCount+1
    end

    -- 2번 버튼 활성화
    buttonCount = buttonCount+1
    
    if dataItem.canDrop then
        -- 3번 버튼 활성화
        buttonCount = buttonCount+1
    end

    local widthAll = basepanel.width-20
    widthAll = widthAll - (buttonCount-1)*5
    local btnWidth = widthAll / buttonCount

    local btns={}
    for i=1,buttonCount do
        local btnImg = Image("Pictures/button.png", Rect(10+(i-1)*(btnWidth+5), -10,btnWidth, 35)){anchor=6, pivotY=1, parent=basepanel}
        local btn = Button("", Rect(0,0,btnImg.width,btnImg.height)){color=Color(0,0,0,0), parent=btnImg}
        btns[i] = btn
    end

    -- btn 1
    local btnIdx = 1

    if ItemTypeGroup[dataItem.type]==1 then
        -- 장착/해제 기능 작성
        btns[btnIdx].text = Client.myPlayerUnit.IsEquippedItem(item.id) and '장착해제' or '장착'
        btns[btnIdx].onClick.Add(function ()
            if Client.myPlayerUnit.IsEquippedItem(item.id) then
                Client.FireEvent("UnequipItem", item.id)
            else
                Client.FireEvent("EquipItem", item.id)
            end
        end)
        btnIdx = btnIdx+1

    elseif ItemTypeGroup[dataItem.type]==2 then
        -- 사용 기능 작성
        btns[btnIdx].text = "사용"
        btns[btnIdx].onClick.Add(function ()
            Client.myPlayerUnit.UseItem(item.dataID)
            Client.RunLater(function ()
                CustomUIRefresh()
            end, 0.3) 
            HideItemPopup()
        end)
        btnIdx = btnIdx+1
    end

    -- 슬롯 등록 기능 작성
    btns[btnIdx].text = "슬롯 등록"
    btns[btnIdx].onClick.Add(function ()
        ShowRegistSlot(item)
    end)
    btnIdx = btnIdx+1

    -- 드롭 기능 작성
    if dataItem.canDrop then
        btns[btnIdx].text = "드롭"
        btns[btnIdx].onClick.Add(function ()
            Client.ShowYesNoAlert("진짜 버릴꺼야?", function (a)
                Client.FireEvent("DropItem", item.id)
            end)
        end)
    end

end

function HideItemPopup()
    if ui.popup.panel~=nil then
        ui.popup.panel.Destroy()
        ui.popup.panel=nil
    end
end

------------------------------------------------------------------------------------------------------------------------

local quickSlotPage = 0

function ShowRegistSlot(item)
    HideRegistSlot()

    local basepanel = Panel(Rect(0,0,Client.width,Client.height)){anchor=7, pivotX=0.5, pivotY=1, color=Color(50,50,50,170), showOnTop=true}
    ui.registSlot.panel = basepanel

    local text = Text("장착할 슬롯을 선택해 주세요.", Rect(0,-100,600,80)){
        textSize=32, textAlign=4, borderEnabled=true, borderColor=Color(0,0,0),
        anchor=4, pivotX=0.5,pivotY=0.5, parent=basepanel}

    local cancelImg = Image("Pictures/button.png", Rect(0,-35,120,40)){anchor=4, pivotX=0.5, pivotY=0.5, parent=basepanel}
    local cancel = Button("취소", Rect(0,0,cancelImg.width,cancelImg.height)){color=Color(0,0,0,0), parent=cancelImg}
    cancel.onClick.Add(function ()
        HideRegistSlot()
    end)

    local changeImg = Image("Pictures/changeSlot.png", Client.changeSlot.rect){ anchor= Client.changeSlot.anchor, pivotX=Client.changeSlot.pivotX, pivotY=Client.changeSlot.pivotY,parent=basepanel }
    local change = Button("", Rect(0,0,changeImg.width,changeImg.height)){color=Color(0,0,0,0), parent=changeImg}
    change.onClick.Add(function ()
        quickSlotPage = (quickSlotPage==1) and 0 or 1
        ShowRegistSlot(item)
    end)

    for key,quickSlot in pairs(Client.quickSlots) do
        local quickSlotID = #Client.quickSlots*quickSlotPage + key

        local slot = Image("Pictures/quickSlot.png", quickSlot.rect){ anchor=quickSlot.anchor, pivotX=quickSlot.pivotX, pivotY=quickSlot.pivotY, parent=basepanel}

        local itemDataID = Client.myPlayerUnit.quickSlots[quickSlotID].itemID
        local skillDataID = Client.myPlayerUnit.quickSlots[quickSlotID].skillDataID
        if itemDataID~=-1 then
            local icon = Image("", Rect(0,0,32,32)){anchor=4, pivotX=0.5, pivotY=0.5, parent=slot}
            icon.SetImageID(Client.GetItem(itemDataID).imageID)
        elseif skillDataID~=-1 then
            local icon = Image("", Rect(0,0,32,32)){anchor=4, pivotX=0.5, pivotY=0.5, parent=slot}
            icon.SetImageID(Client.GetSkill(skillDataID).iconID)
        end

        local btn = Button("", Rect(0,0,slot.width,slot.height)){color=Color(0,0,0,0), parent=slot}
        btn.onClick.Add(function ()
            Client.FireEvent("SetQuickSlot", 1, quickSlotID-1, item.dataID)
        end)

    end
    
    --basepanel.DOScale(Point(Client.width, Client.height), 0.2)
end

function HideRegistSlot()
    if ui.registSlot.panel~=nil then
        ui.registSlot.panel.Destroy()
        ui.registSlot.panel=nil
    end
end


------------------------------------------------------------------------------------------------------------------------

Client.GetTopic("ShowProfile").Add(function (list)
    list = Utility.JSONParse(list)
    for key,value in pairs(list) do
        list[key] = string.gsub(value, '{SLISH}', '/')
    end
    ShowProfile(list)
end)

function CustomUIRefresh()
    Client.FireEvent("ShowProfile")
    ShowEquipment()
    ShowInventory()
end

Client.GetTopic("CustomUI.Refresh").Add(function ()
    CustomUIRefresh()
end)

Client.GetTopic("CustomUI.HideItemPopup").Add(function ()
    HideItemPopup()
end)

Client.GetTopic("CustomUI.CompleteQuickSlot").Add(function ()
    HideItemPopup()
    HideRegistSlot()
end)

Client.GetTopic("SortBagItems").Add(function ()
    ShowInventory()
end)

------------------------------------------------------------------------------------------------------------------------

function GetItemsWhereCategory(items)
    local list={}
    for key,item in pairs(items) do
        for key2,type in pairs(inven_category[category].type) do
            if Client.GetItem(item.dataID).type==type then
                table.insert(list, item)
                break
            end
        end
    end
    return list
end


Client.onResize.Add(function (width, height)
    if ui.registSlot.panel~=nil then
        ui.registSlot.panel.width = width        
        ui.registSlot.panel.height = height
    end
end)

