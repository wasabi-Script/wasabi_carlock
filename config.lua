Config = {}

Config.ToggleKey = 'L' --All players can configure in-game via settings as well
Config.GiveCommand = 'givekey' -- Command for giving key to another player
Config.MythicProgbar = true -- Recommended so players know their progress when searching vehicle/robbing peds

Config.CustomSounds = true -- Refer to README.md for more information

Config.MaxHotwireAttempts = 2 -- How many chances they get to fail hotwire.
Config.LockPickLost = 20 --Chance of losing picklock when lockpicking vehicles
Config.HotwireItemLost = 50 --Chance of loosing hotwiring item when hotwiring vehicles

Config.searchRewards = { --Random rewards upon successful vehicle search(Chance is in percent)
    [1] = {chance = 50, type = 'money', name = 'money', quantity = math.random(30, 75)},
    [2] = {chance = 30, type = 'key', name = 'keys'},
    [3] = {chance = 50, type = 'item', name = 'water', quantity = 1},
}

Config.noKeysNeeded = { --For vehicles that do not require keys(i.e. bmx bike)
    ['BMX'] = true,
    ['BMXST'] = true,
    ['CRUISER'] = true,
    ['FIXTER'] = true,
    ['SCORCHER'] = true,
    ['TRIBIKE'] = true,
    ['TRIBIKE2'] = true,
    ['TRIBIKE3'] = true
}

Language = {
    ['already_searched'] = 'You have already searched this vehicle.',
    ['found_cash'] = 'You found $',
    ['found_keys'] = 'You have found keys in the vehicle!',
    ['found_item'] = 'You have found',
    ['no_inv_space'] = 'You have no room in your inventory!',
    ['handed_keys'] = 'You have been handed the keys.',
    ['action_cancelled'] = 'Action was cancelled!',
    ['three_d_txt'] = '~INPUT_VEH_HEADLIGHT~ Hotwire\n   ~INPUT_REPLAY_SHOWHOTKEY~ Search',
    ['three_d_txt_2'] = '~INPUT_VEH_HEADLIGHT~ Hotwire',
    ['three_d_txt_3'] = '~INPUT_REPLAY_SHOWHOTKEY~ Search',
    ['three_d_txt_4'] = 'This vehicle has already been screwed up!',
    ['hotwire_success'] = 'You have successfully hotwired the vehicle.',
    ['hotwire_failed'] = 'You have failed to hotwired the vehicle.',
    ['bad_wires'] = 'It appears as though the wires are already mangled!',
    ['already_hotwired'] = 'You can not figure out how to hotwire.',
    ['vehicle_locked'] = 'You have ~r~locked~w~ your vehicle.',
    ['vehicle_unlocked'] = 'You have ~g~unlocked~w~ your vehicle.',
    ['no_vehiclefound'] = 'No vehicle found.',
    ['no_keys'] = 'No keys for this vehicle!',
    ['too_far'] = 'You are too far from the vehicle!',
    ['keys_given'] = 'You have given your keys to',
    ['keys_received'] = 'You have received keys from',
    ['no_player_nearby'] = 'There are no players nearby!',
    ['lockpick_success'] = 'You have successfully lockpicked the vehicle.',
    ['lockpick_unsuccessful'] = 'You have failed to lockpick the vehicle.',
    ['lockpick_broke'] = 'Your lockpick bent and busted!',
}

RegisterNetEvent('wasabi_carlock:notify')
AddEventHandler('wasabi_carlock:notify', function(message)	
	
-- Place notification system info here, ex: exports['mythic_notify']:SendAlert('error', message)
    ESX.ShowNotification(message)


end)