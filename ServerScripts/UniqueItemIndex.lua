local uniqueItemIndex_worldVarID = 1
local intMax = 2147483647

Server.onAddItem.Add(function (unit, item)
    local type = Server.GetItem(item.dataID).type
    if type == 8 or type==9 or type==10 then
        return
    end

    local curIndex = Server.GetWorldVar(uniqueItemIndex_worldVarID)
    if curIndex>(intMax-1) then
        curIndex = 0
    end
    Server.SetWorldVar(uniqueItemIndex_worldVarID, curIndex+1)

    item.index = curIndex+1
    unit.player.SendItemUpdated(item)
end)


