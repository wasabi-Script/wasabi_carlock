ESX = nil
local showHelp = true
local searchedVehicles, hotwiredVehicles, nowUnlocked, deadPed, failedHot  = {}, {}, {}, {}, {}
local savedKeys = {}
local playerIdent = 0
local playerPed


CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(0)
    end
    while ESX.GetPlayerData().job == nil do
        Wait(1000)
    end
    TriggerServerEvent('wasabi_carlock:getOwnedKeys')
end)


--Searching Vehicle Thread
CreateThread(function()
    while true do
        Wait(0)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local plate = GetVehicleNumberPlateText(vehicle)
            while hasCarKey(plate) do
                Wait(1000)
                break
            end
            if IsDisabledControlJustPressed(0, 311) then
                if not searchedVehicles[plate] and not hasCarKey(plate) and not hotwiredVehicles[plate] and GetPedInVehicleSeat(vehicle, -1) == playerPed then
                    inCarAnimation(true)
                    showHelp = false
                    if Config.MythicProgbar then
                        exports['mythic_progbar']:Progress({
                            name = "searching_vehicle",
                            duration = 6000,
                            label = 'Searching Vehicle',
                            useWhileDead = false,
                            canCancel = false,
                            controlDisables = {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                        }, function(cancelled)
                            if not cancelled then
                                if not hasCarKey(plate) then
                                    TriggerServerEvent('wasabi_carlock:searchVehicle', plate)
                                    showHelp = true
                                    searchedVehicles[plate] = true
                                    inCarAnimation(false)
                                end
                            else
                                showHelp = true
                                searchedVehicles[plate] = true   
                                inCarAnimation(false)                
                            end
                        end)
                    else
                        Wait(6000)
                        if not hasCarKey(plate) then
                            TriggerServerEvent('wasabi_carlock:searchVehicle', plate)
                            showHelp = true
                            inCarAnimation(false) 
                        end
                    end
                elseif searchedVehicles[plate] then
                    TriggerEvent('wasabi_carlock:notify', Language['already_searched'])
                end
            end
        end
    end
end)

--Robbing keys from NPC thread
CreateThread(function()
    while true do
        Wait(0)
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            showHelp = true
            while not IsPlayerFreeAiming(PlayerId()) do
                Wait(100)
            end
            local aim, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
            if aim then
                local playerPed = PlayerPedId()
                if DoesEntityExist(target) and not IsPedAPlayer(target) and IsPedArmed(playerPed, 7) then
                    local targetVeh = GetVehiclePedIsIn(target, false)
                    local targetPlate = GetVehicleNumberPlateText(targetVeh)
                    local dist = #(GetEntityCoords(playerPed, true) - GetEntityCoords(targetVeh, true))
                    if dist < 12 and IsPedFacingPed(target, playerPed, 60.0) then
                        SetVehicleForwardSpeed(targetVeh, 0)
                        nowUnlocked[targetPlate] = false
                        SetVehicleForwardSpeed(targetVeh, 0)
                        TaskLeaveVehicle(target, targetVeh, 256)
                        while IsPedInAnyVehicle(target, false) do
                            Wait(0)
                        end
                        RequestAnimDict('missfbi5ig_22')
                        RequestAnimDict('mp_common')
                        SetPedDropsWeaponsWhenDead(target,false)
                        ClearPedTasks(target)
                        TaskTurnPedToFaceEntity(target, playerPed, 3.0)
                        TaskSetBlockingOfNonTemporaryEvents(target, true)
                        SetPedFleeAttributes(target, 0, 0)
                        SetPedCombatAttributes(target, 17, 1)
                        SetPedAlertness(target, 0)
                        SetPedHearingRange(target, 0.0)
                        SetPedSeeingRange(target, 0.0)
                        SetPedKeepTask(target, true)
                        TaskPlayAnim(target, "missfbi5ig_22", "hands_up_anxious_scientist", 8.0, -8, -1, 12, 1, 0, 0, 0)
                        Wait(2000)
                        TaskPlayAnim(target, "missfbi5ig_22", "hands_up_anxious_scientist", 8.0, -8, -1, 12, 1, 0, 0, 0)
                        Wait(2000)
                        local dist = #(GetEntityCoords(playerPed, true) - GetEntityCoords(targetVeh, true))
                        if dist <= 10 and not IsEntityDead(target) then
                            TaskPlayAnim(target, "mp_common", "givetake1_a", 8.0, -8, -1, 12, 1, 0, 0, 0)
                            if Config.MythicProgbar then
                                TriggerEvent("mythic_progbar:client:progress", {
                                    name = "stealing_keys",
                                    duration = 4000,
                                    label = "Taking Keys ...",
                                    useWhileDead = false,
                                    canCancel = true,
                                    controlDisables = {
                                        disableMovement = false,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }
                                }, function(cancelled)
                                    if not cancelled then
                                        nowUnlocked[targetPlate] = true
                                        TriggerEvent('wasabi_carlock:notify', Language['handed_keys'])
                                        TriggerServerEvent('wasabi_carlock:addKey', targetPlate)
                                    else
                                        nowUnlocked[targetPlate] = false
                                        TriggerEvent('wasabi_carlock:notify', Language['action_cancelled'])
                                    end
                                end)
                            else
                                Wait(5000)
                                nowUnlocked[targetPlate] = true
                                TriggerEvent('wasabi_carlock:notify', Language['handed_keys'])
                                TriggerServerEvent('wasabi_carlock:addKey', targetPlate)
                            end
                            Wait(6000)
                            ResetPedLastVehicle(target)
                            TaskReactAndFleePed(target, playerPed)
                            SetPedKeepTask(target, true)
                            Wait(2500)
                            TaskReactAndFleePed(target, playerPed)
                            SetPedKeepTask(target, true)
                            Wait(2500)
                            TaskReactAndFleePed(target, playerPed)
                            SetPedKeepTask(target, true)
                        end
                    end
                end
            end
        end
    end
end)

--Hotwire/3D Text/Etc Thread
CreateThread(function()
    while true do
        Wait(0)
        if IsPedShooting(PlayerPedId()) then
            deadPed = true
        end
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local plate = GetVehicleNumberPlateText(vehicle)
            while hasCarKey(plate) do
                Wait(1000)
                break
            end
            if DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == playerPed and not hotwiredVehicles[plate] and not Config.noKeysNeeded[GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))] and not hasCarKey(plate) then
                while not IsPedInAnyVehicle(playerPed, false) do
                    Wait(1000)
                end               
                SetVehicleEngineOn(vehicle, false, false)
                if showHelp and searchedVehicles[plate] and failedHot[plate] == Config.MaxHotwireAttempts then
                    local txtPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 0.5, 1.0)
                    DrawText3D(txtPos, Language['three_d_txt_4'])
                        if IsPedInAnyVehicle(playerPed, -1) then
                            DisableControlAction(0, 74, true)
                            DisableControlAction(0, 311, true)
                        end
                elseif showHelp and failedHot[plate] == Config.MaxHotwireAttempts then
                    local txtPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 0.5, 1.0)
                    DrawText3D(txtPos, Language['three_d_txt_3'])
                    if IsPedInAnyVehicle(playerPed, -1) then
                        DisableControlAction(0, 74, true)
                        DisableControlAction(0, 311, true)
                    end
                elseif showHelp and searchedVehicles[plate] then
                    local txtPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 0.5, 1.0)
                    DrawText3D(txtPos, Language['three_d_txt_2'])
                    if IsPedInAnyVehicle(playerPed, -1) then
                        DisableControlAction(0, 74, true)
                        DisableControlAction(0, 311, true)
                    end
                elseif showHelp then
                    local txtPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 0.5, 1.0)
                    DrawText3D(txtPos, Language['three_d_txt'])
                    if IsPedInAnyVehicle(playerPed, -1) then
                        DisableControlAction(0, 74, true)
                        DisableControlAction(0, 311, true)
                    end
                end
                if not hotwiredVehicles[plate] and failedHot[plate] ~= Config.MaxHotwireAttempts then
                    if IsDisabledControlJustPressed(0, 74) and showHelp then
                        inCarAnimation(true)
                        showHelp = false
                        local skill = CreateSkillbar(5, 'medium')
                        if skill then
                            hotwiredVehicles[plate] = true
                            SetVehicleEngineOn(vehicle, true, true)
                            TriggerServerEvent('wasabi_carlock:addKey', plate)
                            TriggerEvent('wasabi_carlock:notify', Language['hotwire_success'])
                            showHelp = true
                            inCarAnimation(false)
                        else
                            showHelp = true
                            if failedHot[plate] == nil then
                                failedHot[plate] = 1
                            else
                                failedHot[plate] = failedHot[plate] + 1
                                TriggerEvent('wasabi_carlock:notify', Language['hotwire_failed'])
                                inCarAnimation(false)
                            end
                        end
                    end
                elseif hotwiredVehicles[plate] then
                    if IsDisabledControlJustPressed(0, 74) then
                        TriggerEvent('wasabi_carlock:notify', Language['already_hotwired'])
                    end
                elseif failedHot[plate] then
                    if IsDisabledControlJustPressed(0, 74) then
                        TriggerEvent('wasabi_carlock:notify', Language['bad_wires'])
                    end
                end
            end
        end
    end
end)



RegisterNetEvent('wasabi_carlock:startVehicle')
AddEventHandler('wasabi_carlock:startVehicle', function()
    local playerPed = PlayerPedId()
    local locVeh = GetVehiclePedIsIn(playerPed, false)
    SetVehicleEngineOn(locVeh, true, true)
end)

RegisterNetEvent('wasabi_carlock:syncKeys')
AddEventHandler('wasabi_carlock:syncKeys', function (vehKey, identifier)
    savedKeys = vehKey
    playerIdent = identifier
end)


AddEventHandler('wasabi_carlock:togglelocks', function()
    local playerPed = PlayerPedId()
    local plyCoords = GetEntityCoords(playerPed)
    local vehicle = nil
    if IsPedInAnyVehicle(playerPed, false) then
        vehicle = GetVehiclePedIsIn(playerPed, false)
    else
        vehicle = GetClosestVehicle(plyCoords.x, plyCoords.y, plyCoords.z, 5.0, 0, 71)
    end
    if DoesEntityExist(vehicle) then
        CreateThread(function()
            if hasCarKey(GetVehicleNumberPlateText(vehicle)) then
                if not IsPedInAnyVehicle(playerPed, false) then
                    lockAnimation()
                    SetVehicleEngineOn(vehicle, true, true, true)
                    SetVehicleLights(vehicle, 2)
                    Wait(300)
                    SetVehicleLights(vehicle, 1)
                    Wait(300)
                    SetVehicleLights(vehicle, 2)
                    Wait(300)
                    SetVehicleLights(vehicle, 1)
                    SetVehicleEngineOn(vehicle, false, false, false)
                    SetVehicleLights(vehicle, 0)
                end
                if GetVehicleDoorLockStatus(vehicle) == 1 then
                    SetVehicleDoorsLocked(vehicle, 2)
                    if Config.CustomSounds then
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "lock", 0.3)
                    end
                    TriggerEvent('wasabi_carlock:notify', Language['vehicle_locked'])
                elseif GetVehicleDoorLockStatus(vehicle) == 2 then
                    SetVehicleDoorsLocked(vehicle, 1)
                    if Config.CustomSounds then
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "unlock", 0.3)
                    end
                    TriggerEvent('wasabi_carlock:notify', Language['vehicle_unlocked'])
                end
            end
        end)
    else
        TriggerEvent('wasabi_carlock:notify', Language['no_vehiclefound'])
    end
end)

RegisterCommand('toggleLocks', function()
    TriggerEvent('wasabi_carlock:togglelocks')
end)

RegisterKeyMapping('toggleLocks', 'Lock/Unlock Vehicle', 'keyboard', Config.ToggleKey)

RegisterCommand(Config.GiveCommand, function()
    local playerPed = PlayerPedId()
    local closeVeh = ESX.Game.GetVehicleInDirection()
    if closeVeh == nil or not DoesEntityExist(closeVeh) then
        TriggerEvent('wasabi_carlock:notify', Language['no_vehiclefound'])
        return
    end
    if not hasCarKey(GetVehicleNumberPlateText(closeVeh)) then
        TriggerEvent('wasabi_carlock:notify', Language['no_keys'])
        return
    end
    if #(GetEntityCoords(closeVeh) - GetEntityCoords(playerPed)) > 5 then
        TriggerEvent('wasabi_carlock:notify', Language['too_far'])
        return
    end
    local target, dist = ESX.Game.GetClosestPlayer()
    if dist ~= -1 and dist < 10 then
        TriggerServerEvent('wasabi_carlock:giveKey', GetPlayerServerId(target), GetVehicleNumberPlateText(closeVeh))
    else
        TriggerEvent('wasabi_carlock:notify', Language['no_player_nearby'])
    end
end)

RegisterNetEvent('wasabi_carlock:lockpick')
AddEventHandler('wasabi_carlock:lockpick', function()
    local playerPed = PlayerPedId()
    local closeVeh = ESX.Game.GetClosestVehicle()
    if DoesEntityExist(closeVeh) then
        if not IsPedInAnyVehicle(playerPed, false) then
            if GetVehicleDoorLockStatus(closeVeh) ~= 1 then
                inLockpickAnim(true)
                if Config.CustomSounds then
                    TriggerEvent('InteractSound_CL:PlayOnOne', 'lockpick', 0.7)
                end
                local skill = CreateSkillbar(2, 'medium')
                if skill then
                    inLockpickAnim(false)
                    SetVehicleDoorsLocked(closeVeh, 1)
                    SetVehicleDoorsLockedForAllPlayers(closeVeh, false)
                    nowUnlocked[GetVehicleNumberPlateText(closeVeh)] = true
                    if Config.CustomSounds then
                        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 8, "lock", 0.3)
                    end
                    TriggerEvent('wasabi_carlock:notify', Language['lockpick_success'])
                    SetVehicleEngineOn(closeVeh, true, true, true)
                    SetVehicleLights(closeVeh, 2)
                    Wait(200)
                    SetVehicleLights(closeVeh, 1)
                    Wait(200)
                    SetVehicleLights(closeVeh, 2)
                    Wait(200)
                    SetVehicleLights(closeVeh, 1)
                    Wait(200)
                    ClearPedTasksImmediately(playerPed)
                    TriggerServerEvent('wasabi_carlock:removepick')
                else
                    inLockpickAnim(false)
                    TriggerEvent('wasabi_carlock:notify', Language['lockpick_unsuccessful'])
                    TriggerServerEvent('wasabi_carlock:removepick')
                end
            end
        end
    end
end)


RegisterNetEvent('wasabi_carlock:addKeys')
AddEventHandler('wasabi_carlock:addKeys', function(plates)
    TriggerServerEvent('wasabi_carlock:addKeysOwned', plates)
end)

--Required function to be within this
hasCarKey = function(plate)
    local plate = ESX.Math.Trim(plate)
    if savedKeys[plate] ~= nil then
        for id, v in pairs(savedKeys[plate]) do
            if v.id == playerIdent then
                return true
            end
        end
        return false
    else
        return false
    end
end

exports('hasCarKey', hasCarKey)

