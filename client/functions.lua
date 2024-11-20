local toggle = false

loadAnimDict = function(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

inLockpickAnim = function(toggle)
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    ClearPedSecondaryTask(playerPed)
    if toggle ~= nil then
        if not toggle then
            ClearPedTasks(playerPed)
            ClearPedSecondaryTask(playerPed)
        else
            loadAnimDict('veh@break_in@0h@p_m_one@')
            if not IsEntityPlayingAnim(playerPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3) then
                TaskPlayAnim(playerPed, "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 1, 0.0, 0, 0, 0)
            end
        end
    end
end

inCarAnimation = function(toggle)
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
    ClearPedSecondaryTask(playerPed)
    if toggle ~= nil then
        if not toggle then
            ClearPedTasks(playerPed)
            ClearPedSecondaryTask(playerPed)
        else
            loadAnimDict('mini@repair')
            if not IsEntityPlayingAnim(playerPed, 'mini@repair', 'fixing_a_player', 3) then
                ClearPedSecondaryTask(playerPed)
                TaskPlayAnim(playerPed, 'mini@repair', 'fixing_a_player', 8.0, -8, -1, 16, 0, 0, 0, 0)
            end
        end
    end
end

DrawText3D = function(coords, text)
    local str = text

    local start, stop = string.find(text, "~([^~]+)~")
    if start then
        start = start - 1
        stop = stop + 1
        str = ""
        str = str .. string.sub(text, 0, start) .. "   " .. string.sub(text, start+1, stop-1) .. string.sub(text, stop, #text)
    end

    AddTextEntry(GetCurrentResourceName(), str)
    BeginTextCommandDisplayHelp(GetCurrentResourceName())
    EndTextCommandDisplayHelp(2, false, false, -1)

	SetFloatingHelpTextWorldPosition(1, coords)
	SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
end

lockAnimation = function()
    local playerPed = PlayerPedId()
    if not IsPedInAnyVehicle(playerPed, false) then
        RequestAnimDict('anim@heists@keycard@')
        while not HasAnimDictLoaded('anim@heists@keycard@') do
            Wait(100)
        end
        TaskPlayAnim(playerPed, "anim@heists@keycard@", "exit", 24.0, 16.0, 1000, 50, 0, false, false, false)
    end
end