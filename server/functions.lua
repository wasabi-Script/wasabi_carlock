getOwnedVehicles = function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and xPlayer.identifier then
        MySQL.Async.fetchAll("SELECT `plate` FROM `owned_vehicles` WHERE `owner` = @identifier", {
            ["@identifier"] = xPlayer.identifier,
        }, function(plates)
            if plates and #plates > 0 then
                local ownedPlates = {}
                for k,v in pairs(plates) do
                    table.insert(ownedPlates, json.decode(v.plate))
                end
                cb(ownedPlates)
            else
                cb(false)
            end
        end)
    else
        cb(false)
    end
end