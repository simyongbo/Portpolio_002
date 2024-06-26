StringDataInit = true

ItemTypeName = {
    [0]='투구',
    [1]='갑옷',
    [2]='무기',
    [3]='신발',
    [4]='방패',
    [5]='반지',
    [6]='악세서리',
    [7]='날개',
    [8]='포션',
    [9]='재료',
    [10]='소모품',
}

StatName = {
    [0]=Client.GetStrings().attack,
    [1]=Client.GetStrings().defense,
    [2]=Client.GetStrings().magicAttack,
    [3]=Client.GetStrings().magicDefense,
    [4]=Client.GetStrings().agility,
    [5]=Client.GetStrings().lucky,
    [6]=Client.GetStrings().maxHP,
    [7]=Client.GetStrings().maxMP,
}
















function GetItemTypeName(type)
    local name = ItemTypeName[type] or 'Default'
    return name
end

function GetStatOption(statID, type, value)
    if type==1 then
        return StatName[statID]..' +'..value
    elseif type==2 then
        return StatName[statID]..' +'..value..'%'
    elseif type==3 then
        return '[아이템] '..StatName[statID]..' +'..value
    elseif type==4 then
        return '[아이템]'..StatName[statID]..' +'..value..'%'
    end

    return 'Default'
end