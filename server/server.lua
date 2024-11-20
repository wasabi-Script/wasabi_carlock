ESX = nil
local savedKeys = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterUsableItem('lockpick', function(source)
    TriggerClientEvent('wasabi_carlock:lockpick', source)
end)

RegisterServerEvent('wasabi_carlock:searchVehicle')
AddEventHandler('wasabi_carlock:searchVehicle', function(plate)
    local reward = {}
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIdent = xPlayer.identifier
    reward = Config.searchRewards[math.random(#Config.searchRewards)]
    if math.random(1, 100) >= reward.chance then
        if reward.type == 'money' then
            xPlayer.addAccountMoney('money', reward.quantity)
            TriggerClientEvent('wasabi_carlock:notify', source, Language['found_cash']..''..reward.quantity)
        elseif reward.type == 'key' then
            TriggerClientEvent('wasabi_carlock:notify', source, Language['found_keys'])
            savedKeys[plate] = {}
            table.insert(savedKeys[plate], {id = xIdent})
            TriggerClientEvent('wasabi_carlock:syncKeys', source, savedKeys, xIdent)
            TriggerClientEvent('wasabi_carlock:startVehicle', source)
        else
            if xPlayer.canCarryItem(reward.name, reward.quantity) then
                xPlayer.addInventoryItem(reward.name, reward.quantity)
                local itemLabel = ESX.GetItemLabel(reward.name)
                TriggerClientEvent('wasabi_carlock:notify', source, Language['found_item']..' '..reward.quantity..'x '..itemLabel)
            else
                TriggerClientEvent('wasabi_carlock:notify', source, Language['no_inv_space'])
            end
        end
    end
end)

--Older trigger event I see in a lot of car lock scripts. Just in-case
RegisterServerEvent('garage:addKeys')
AddEventHandler('garage:addKeys', function(plate)
    local source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIdent = xPlayer.identifier
    if savedKeys[plate] ~= nil then
        table.insert(savedKeys[plate], {id = xIdent})
        TriggerClientEvent('wasabi_carlock:syncKeys', source, savedKeys, xIdent)
    else
        savedKeys[plate] = {}
        table.insert(savedKeys[plate], {id = xIdent})
        TriggerClientEvent('wasabi_carlock:syncKeys', source, savedKeys, xIdent)
    end
end)

RegisterServerEvent('wasabi_carlock:addKey')
AddEventHandler('wasabi_carlock:addKey', function(plate)
    local source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIdent = xPlayer.identifier
    if savedKeys[plate] ~= nil then
        table.insert(savedKeys[plate], {id = xIdent})
        TriggerClientEvent('wasabi_carlock:syncKeys', source, savedKeys, xIdent)
    else
        savedKeys[plate] = {}
        table.insert(savedKeys[plate], {id = xIdent})
        TriggerClientEvent('wasabi_carlock:syncKeys', source, savedKeys, xIdent)
    end
end)

RegisterServerEvent('wasabi_carlock:addKeysOwned')
AddEventHandler('wasabi_carlock:addKeysOwned', function(data)
    local source = tonumber(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIdent = xPlayer.identifier
    for i=1, #data, 1 do
        if savedKeys[data[i]] ~= nil then
            table.insert(savedKeys[data[i]],{id = xIdent})
        else
            savedKeys[data[i]] = {}
            table.insert(savedKeys[data[i]],{id = xIdent})
        end
    end
    TriggerClientEvent('wasabi_carlock:syncKeys', source, savedKeys, xIdent)
end)

RegisterServerEvent('wasabi_carlock:giveKey')
AddEventHandler('wasabi_carlock:giveKey', function(target, plate)
    local zSource = tonumber(target)
    local zPlayer = ESX.GetPlayerFromId(zSource)
    local zIdent = zPlayer.identifier
    local zName = zPlayer.getName()
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIdent = xPlayer.identifier
    local xName = xPlayer.getName()
    local plate = tostring(plate)
    savedKeys[plate] = {}
    table.insert(savedKeys[plate], {id = zIdent})
    TriggerClientEvent('wasabi_carlock:syncKeys', zSource, savedKeys, zIdent)
    TriggerClientEvent('wasabi_carlock:syncKeys', source, savedKeys, xIdent)
    TriggerClientEvent('wasabi_carlock:notify', source, Language['keys_given']..' '..zName)
    TriggerClientEvent('wasabi_carlock:notify', zSource, Language['keys_received'].. ' '..xName)
end)

RegisterServerEvent('wasabi_carlock:removepick')
AddEventHandler('wasabi_carlock:removepick', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if math.random(1, 100) <= Config.LockPickLost then
        xPlayer.removeInventoryItem('lockpick', 1)
        TriggerClientEvent('wasabi_carlock:notify', source, Language['lockpick_broke'])
    end
end)

RegisterServerEvent('wasabi_carlock:getOwnedKeys')
AddEventHandler('wasabi_carlock:getOwnedKeys', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local xIdent = xPlayer.identifier
    if xPlayer and xIdent then
        local plates = {}
        MySQL.Async.fetchAll("SELECT `plate` FROM `owned_vehicles` WHERE `owner` = @identifier", {
            ["@identifier"] = xIdent,
        }, function(results)
            if results and #results > 0 then
                for k,v in pairs(results) do
                    table.insert(plates, v.plate)
                end
                xPlayer.triggerEvent('wasabi_carlock:addKeys', plates)
            end
        end)
    end
end)
