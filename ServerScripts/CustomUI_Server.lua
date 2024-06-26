local presetItem_stringVarID = 1
local preset_varID = 0

-- {statID=00, format="공격력 : %d"}
local printStats = {
    {format='이름 : {1}', 'name'},
    {format='직업 : {1}', 'JobName'},
    {format='체력 : {1} / {2}', 'hp', 'maxHP'},
    {format="마력 : {1} / {2}", 'mp', 'maxMP'},
    {format="경험치 : {1} / {2}", 'exp', 'maxEXP'},

    {format="공격력 : {1}", 'attack'},
    {format="방어력 : {1}", 'defense'},
    {format="마법공격력 : {1}", 'magicAttack'},
    {format="마법방어력 : {1}", 'magicDefense'},
    {format="민첩 : {1}",'agility'},
    {format="운 : {1}", 'lucky'},

    {format="치명타 : {1}", {type='GetStat', value=101}},
    {format="방어관통 : {1}", {type='GetStat', value=102}},
    {format="저항력 : {1}", {type='GetStat', value=103}},
    {format="회피 : {1} ~ {2}", {type='GetStat', value=104}, {type='GetStat', value=105}},
    {format="Custom5 : {1}", {type='GetStat', value=106}},
    {format="Custom6 : {1}", {type='GetStat', value=107}},
    {format="Custom7 : {1}", {type='GetStat', value=108}},
    {format="Custom8 : {1}", {type='GetStat', value=109}},
    {format="Custom9 : {1}", {type='GetStat', value=110}},
    {format="Custom10 : {1}", {type='GetStat', value=111}},
    {format="Custom11 : {1}", {type='GetStat', value=112}},
    {format="Custom12 : {1}", {type='GetStat', value=113}},

}

Server.GetTopic("ShowProfile").Add(function ()
    local list = {}

    for key,value in pairs(printStats) do
        local format = value.format
        for k,v in ipairs(value) do
            local changeValue = ''
            if type(v)=='table' then
                if v.type=='GetStat' then
                    changeValue = unit.GetStat(v.value)
                end
            elseif v=='JobName' then
                changeValue = Server.GetJob(unit.job).name
            elseif v=='maxEXP' then
                changeValue = Server.GetJob(unit.job).exps[unit.level] or 0
            else
                changeValue = unit[v]
            end
            format = string.gsub(format, '{'..k..'}', changeValue)
        end
        table.insert(list, format)
    end

    for key,value in pairs(list) do
        list[key] = string.gsub(value, '/', '{SLISH}')
    end

    unit.FireEvent("ShowProfile", Utility.JSONSerialize(list))

end)

Server.GetTopic("EquipItem").Add(function (itemID)
    local presetID = unit.GetVar(preset_varID)
    if presetID==0 then
        presetID = 1
    end

    local str = unit.GetStringVar(presetItem_stringVarID)
    if str==nil then
        str = Utility.JSONSerialize({})
        unit.SetStringVar(presetItem_stringVarID, str)
    end
    local list = Utility.JSONParse(str)
    if list[presetID]==nil then
        list[presetID] = {}
    end

    local item = unit.player.GetItem(itemID)
    local dataItem = Server.GetItem(item.dataID)

    local slotID = nil
    if dataItem.type == 5 or dataItem.type == 6 then 
        if unit.GetEquipItem(5) then
            if unit.GetEquipItem(6) then
                slotID = 5
            else
                slotID = 6
            end
        else
            slotID = 5
        end
    elseif dataItem.type == 7 or dataItem.type == 8 then 
        if unit.GetEquipItem(7) then
            if unit.GetEquipItem(8) then
                slotID = 7
            else
                slotID = 8
            end
        else
            slotID = 7
        end
    else
        slotID=dataItem.type
    end

    list[presetID][tostring(slotID)] = item.index
    unit.SetStringVar(presetItem_stringVarID, Utility.JSONSerialize(list))

    DebugPreset(unit)

    unit.EquipItem(itemID)

    unit.FireEvent("CustomUI.Refresh")
    unit.FireEvent("CustomUI.HideItemPopup")
end)

Server.GetTopic("UnequipItem").Add(function (itemID)
    local presetID = unit.GetVar(preset_varID)
    if presetID == 0 then
        presetID = 1
    end

    local str = unit.GetStringVar(presetItem_stringVarID)
    if str==nil then
        str = Utility.JSONSerialize({})
        unit.SetStringVar(presetItem_stringVarID, str)
    end
    local list = Utility.JSONParse(str)
    if list[presetID]==nil then
        list[presetID] = {}
    end

    local item = unit.player.GetItem(itemID)
    local dataItem = Server.GetItem(item.dataID)

    local slotID = nil
    if dataItem.type == 5 or dataItem.type == 6 then 
        local slot5Item = unit.GetEquipItem(5)
        local slot6Item = unit.GetEquipItem(6)
        if slot5Item and slot5Item.id==itemID then
            slotID = 5
        elseif slot6Item and slot6Item.id==itemID then
            slotID = 6
        end

    elseif dataItem.type == 7 or dataItem.type == 8 then 
        local slot7Item = unit.GetEquipItem(7)
        local slot8Item = unit.GetEquipItem(8)
        if slot7Item and slot7Item.id==itemID then
            slotID = 7
        elseif slot8Item and slot8Item.id==itemID then
            slotID = 8
        end

    else
        slotID=dataItem.type
    end
    if slotID~=nil then
        list[presetID][tostring(slotID)] = nil
    else
        print('error')
    end
    unit.SetStringVar(presetItem_stringVarID, Utility.JSONSerialize(list))
    
    DebugPreset(unit)
    
    unit.UnequipItem(itemID)
    
    unit.FireEvent("CustomUI.Refresh")
    unit.FireEvent("CustomUI.HideItemPopup")
end)

Server.GetTopic("DropItem").Add(function (itemID)
    --unit.DropItem()
end)

Server.GetTopic("SetQuickSlot").Add(function (type, slotID, dataID)
    unit.SetQuickSlot(type, slotID, dataID)

    unit.FireEvent("CustomUI.CompleteQuickSlot")
end)

Server.GetTopic("SortBagItems").Add(function ()
    local player = unit.player
    
    player.SortBagItems(function(item1, item2)
        local a = Server.GetItem(item1.dataID)
        local b = Server.GetItem(item2.dataID)
        
        if player.unit.IsEquippedItem(item1.id) then
            return false
        elseif a.type==b.type then
            return item1.dataID >= item2.dataID
        else
            return a.type >= b.type
        end
    end)

    unit.FireEvent("SortBagItems")
end)

Server.GetTopic("CustomUI.Character").Add(function ()
    
    unit.FireEvent("CustomUI.Character", unit.characterID)
end)

Server.GetTopic("CustomUI.Preset").Add(function (presetID)
    if presetID==nil then
        unit.FireEvent("CustomUI.Preset", unit.GetVar(preset_varID))
        return
    end

    local str = unit.GetStringVar(presetItem_stringVarID)
    if str==nil then
        str = Utility.JSONSerialize({})
        unit.SetStringVar(presetItem_stringVarID, str)
    end

    local list = Utility.JSONParse(str)

    local preset = list[presetID]
    if preset==nil then
        preset = {}
    end

    for slotID=0,9 do
        local index = preset[tostring(slotID)]

        if index~=nil then
            local item = FindItemByIndex(unit, index)
            if item==nil then
                list[presetID][tostring(slotID)] = nil
                local equipItem = unit.GetEquipItem(slotID)
                if equipItem then
                    unit.UnequipItem(equipItem.id)
                end
            else
                unit.equipItem(item.id)
            end
        else
            local equipItem = unit.GetEquipItem(slotID)
            if equipItem then
                unit.UnequipItem(equipItem.id)
            end
        end
    end

    unit.SetVar(preset_varID, presetID)
    unit.SetStringVar(presetItem_stringVarID, Utility.JSONSerialize(list))

    DebugPreset(unit)

    unit.FireEvent("CustomUI.Preset", unit.GetVar(preset_varID))
    unit.FireEvent("CustomUI.Refresh")
end)

function FindItemByIndex(unit, index)
    for key,item in pairs(unit.player.GetItems()) do
        if index==item.index then
            return item
        end    
    end
    return nil
end


function DebugPreset(unit)
    local str = unit.GetStringVar(presetItem_stringVarID)
    local presets = Utility.JSONParse(str)

    local presetID = unit.GetVar(preset_varID)
    if presetID==0 then
        presetID = 1
    end
--[[
    print('\n\n----preset log----')
    for key,preset in pairs(presets) do
        print('preset '..key)

        for slotID, index in pairs(preset) do
            print('slotID:',slotID,', index:',index)
        end
    end
    print('\n\n')
]]
end