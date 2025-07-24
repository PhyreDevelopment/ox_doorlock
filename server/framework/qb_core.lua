local QBCore = exports['qb-core']:GetCoreObject()
local ox_inventory = exports.ox_inventory

-- GetPlayer: returns QBCore player object
function GetPlayer(playerId)
    return QBCore.Functions.GetPlayer(playerId)
end

-- RemoveItem: removes 1 of the given item from the player's inventory (uses ox_inventory if available)
function RemoveItem(playerId, item, slot)
    if ox_inventory then
        ox_inventory:RemoveItem(playerId, item, 1, nil, slot)
    else
        local player = GetPlayer(playerId)
        if player then
            player.Functions.RemoveItem(item, 1, slot)
        end
    end
end

--- DoesPlayerHaveItem: checks if player has any of the items, optionally removes it
---@param player table QBCore player object
---@param items string[] | { name: string, remove?: boolean, metadata?: table }[]
---@param removeItem? boolean
---@return string? itemName
function DoesPlayerHaveItem(player, items, removeItem)
    local playerId = player.PlayerData and player.PlayerData.source or player.source
    for i = 1, #items do
        local item = items[i]
        local itemName = item.name or item
        local data
        if ox_inventory then
            data = ox_inventory:Search(playerId, 'slots', itemName, item.metadata)[1]
            if data and data.count > 0 then
                if removeItem or item.remove then
                    ox_inventory:RemoveItem(playerId, itemName, 1, nil, data.slot)
                end
                return itemName
            end
        else
            data = player.Functions.GetItemByName(itemName)
            if data and data.amount > 0 then
                if removeItem or item.remove then
                    player.Functions.RemoveItem(itemName, 1, data.slot)
                end
                return itemName
            end
        end
    end
end

-- GetCharacterId: returns the player's citizenid
function GetCharacterId(player)
    return player.PlayerData and player.PlayerData.citizenid or player.citizenid
end

-- IsPlayerInGroup: checks if player is in a job/group (supports string, array, or hash)
function IsPlayerInGroup(player, filter)
    local job = player.PlayerData and player.PlayerData.job or player.job
    if not job then return end
    local typef = type(filter)
    if typef == 'string' then
        if job.name == filter then
            return job.name, job.grade.level or job.grade
        end
    else
        local tabletype = table.type(filter)
        if tabletype == 'hash' then
            local grade = filter[job.name]
            if grade and grade <= (job.grade.level or job.grade) then
                return job.name, job.grade.level or job.grade
            end
        elseif tabletype == 'array' then
            for i = 1, #filter do
                if job.name == filter[i] then
                    return job.name, job.grade.level or job.grade
                end
            end
        end
    end
end
