ESX = nil
searching = false
cachedTrees = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.makeJuice) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 58)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.Locales["blip"])
        EndTextCommandSetBlipName(blip)
    end
end)

function pickManyTimes(cachedTrees, entity)
    if Config.CanPickManyTimes then
        local amount = math.random(1, 3)
        if amount == 1 then
            cachedTrees[entity] = true
        else
            cachedTrees[entity] = false
        end
    else
        cachedTrees[entity] = true
    end
end

RegisterNetEvent('smd_applepicking:animation')
AddEventHandler('smd_applepicking:animation', function(which, amount)
    local ped = PlayerPedId()
	if not isAnimPlaying then
        if which == "juice" then

            SetEntityHeading(ped, 180.0)
            RequestAnimDict("mp_common")
            while not HasAnimDictLoaded("mp_common") do
                Citizen.Wait(1)
            end

            isAnimPlaying = true
            TaskPlayAnim(ped, "mp_common", "givetake1_a", 8.0, 3.0, -1, 1, 1, false, false, false)
            
            Citizen.Wait(2200)
            ClearPedTasks(ped)
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, false)
            Citizen.Wait(10000)
            ClearPedTasks(ped)
            TriggerServerEvent('smd_applepicking:sell')
            isAnimPlaying = false
            isSelling = false
        else
            SetEntityHeading(ped, 180.0)
            isAnimPlaying = true
            TriggerServerEvent('smd_applepicking:applejuice', amount)
            
            RequestAnimDict("anim@amb@business@coc@coc_packing@")
            while not HasAnimDictLoaded("anim@amb@business@coc@coc_packing@") do
                Citizen.Wait(1)
            end
            
            TaskPlayAnim(ped, "anim@amb@business@coc@coc_packing@", "load_press_basicmould_v1_pressoperator", 8.0, 3.0, -1, 1, 1, false, false, false)
            
            Citizen.Wait(5000)
            
            TaskPlayAnim(ped, "anim@amb@business@coc@coc_packing@", "operate_press_basicmould_v1_pressoperator", 8.0, 3.0, -1, 1, 1, false, false, false)
   
            local time = math.random(1, 3)
            
            Citizen.Wait(8000 * time)

            TriggerServerEvent('smd_applepicking:makeJuice', amount)
            ClearPedTasks(ped)
            isAnimPlaying = false
            bottleGiven = false
            tried = false
            alreadyPressing = false
        end
	end
end)

Citizen.CreateThread(function()
	while true do
		sleep = 1000
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		for k, v in pairs(Config.bottleBox) do
			local distance = #(playerCoords - v)
			if distance < 1.5 then
				sleep = 4
                if not bottleGiven and tried then
                    DrawText3D(v, Config.Locales["emptybottle"])
                    if distance < 1 then
                        if IsControlPressed(0, 38) then
                            RequestAnimDict("weapons@first_person@aim_rng@generic@projectile@sticky_bomb@")
                            while not HasAnimDictLoaded("weapons@first_person@aim_rng@generic@projectile@sticky_bomb@") do
                                Citizen.Wait(1)
                            end

                            SetEntityHeading(ped, 180.0)
                            TaskPlayAnim(playerPed, "weapons@first_person@aim_rng@generic@projectile@sticky_bomb@", "plant_floor", 8.0, -8.0, 1200, 2, 0, false, false, false)
                            Citizen.Wait(1200)

                            TriggerServerEvent("smd_applepicking:giveBottle")
                            bottleGiven = true
                        end
                    end
                end
			end
		end
		for k, v in pairs(Config.sellPoint) do
			local distance = #(playerCoords - v)
			if distance < 3 then
                if not isSelling then
                    sleep = 4
                    DrawText3D(v, Config.Locales["sellJuice"])
                    if distance < 2 then
                        if IsControlPressed(0, 38) then
                            ESX.TriggerServerCallback('smd_applepicking:doesHave', function(doesHaveJuice)
                                if doesHaveJuice then
                                    isSelling = true
                                    TriggerEvent("smd_applepicking:animation", "juice", nil)
                                else
                                    notification(Config.Locales["outOfJuice"])
                                end
                            end, "applejuice")
                        end
                    end
                end
			end
		end
		for k, v in pairs(Config.makeJuice) do
			local distance = #(playerCoords - v)
			if distance < 1.5 then
				sleep = 4
                if not alreadyPressing then
                    DrawText3D(v, Config.Locales["makeJuice"])
                    if distance < 1.0 then
                        if IsControlPressed(0, 38) then

                            ESX.TriggerServerCallback('smd_applepicking:doesHave', function(doesHaveApples, amount)
                                ESX.TriggerServerCallback('smd_applepicking:doesHave', function(doesHaveBottle)
                                    Citizen.Wait(50)
                                    if doesHaveBottle then
                                        if doesHaveApples then
                                            alreadyPressing = true
                                            TriggerEvent("smd_applepicking:animation", "apple", amount)
                                        else
                                            notification(Config.Locales["outOfApples"])
                                        end
                                    else
                                        tried = true
                                        notification(Config.Locales["noBottles"])
                                        notification(Config.Locales["bottlesBox"])
                                    end
                                end, "emptybottle")
                            end, "apple")
                        end
                    end
                end
			end
		end
		Citizen.Wait(sleep)
	end
end)

Citizen.CreateThread(function()
    while true do
        sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        for i = 1, #Config.TreePositions do
            local distance = #(coords - Config.TreePositions[i].Pos)
            if not searching then
                if distance < 2.5 then
                    sleep = 4
                    DrawText3D(Config.TreePositions[i].Pos + vector3(0.0, 0.0, 1.5), Config.Locales["pickApple"])
                    if distance < 2.0 then
                        if IsControlJustReleased(1, 38) then
                            if Config.TreePositions[i].tooHigh then
                                if not alerted then
                                    alerted = true
                                    notification(Config.Locales["treeTooHigh"])
                                    Citizen.Wait(3000)
                                    alerted = false
                                end
                            else
                                local direction = GetHeadingFromVector_2d(Config.TreePositions[i].Pos.x - coords.x, Config.TreePositions[i].Pos.y - coords.y)
                                if not cachedTrees[i] then
                                    SetEntityHeading(ped, direction)
                                    Search(i)
                                else
                                    notification(Config.Locales["noApplesInTree"])
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

function Search(tree)
    local ped = PlayerPedId()

    RequestAnimDict("amb@prop_human_movie_bulb@idle_a")
    while not HasAnimDictLoaded("amb@prop_human_movie_bulb@idle_a") do
        Citizen.Wait(1)
    end

	ESX.TriggerServerCallback('smd_applepicking:doesHaveRoom', function(room)
        if room then
            searching = true
            local time = math.random(10000, 25000)
            TaskPlayAnim(ped, "amb@prop_human_movie_bulb@idle_a", "idle_a", 8.0, 3.0, -1, 1, 1, false, false, false)
            Citizen.Wait(time)

            ESX.TriggerServerCallback('smd_applepicking:giveApple', function(found)
                if found then
                    searching = false
                    ClearPedTasks(ped)
                    pickManyTimes(cachedTrees, tree)
                    notification(Config.Locales["giveApple"])
                else
                    searching = false
                    ClearPedTasks(ped)
                end
            end)
        else
            searching = false
            ClearPedTasks(ped)
        end
    end)
end

Citizen.CreateThread(function()
	while true do
        sleep = 1000
		if searching or isAnimPlaying then
            sleep = 4
            DisableAllControlActions(0)
            EnableControlAction(0, 245, true)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            
		end
		Citizen.Wait(sleep)
	end
end)

function notification(text)
	if not CurrentlyText then
		CurrentlyText = true
		if Config.UseMythic then
			exports['mythic_notify']:SendAlert('inform', text)
		else
			ESX.ShowNotification(text)
		end
		Citizen.Wait(1000)
		CurrentlyText = false
	end
end

function DrawText3D(coords, text)
    if Config.UseDarkArrow then
        AddTextEntry(GetCurrentResourceName(), text)
        BeginTextCommandDisplayHelp(GetCurrentResourceName())
        EndTextCommandDisplayHelp(2, false, false, -1)

        SetFloatingHelpTextWorldPosition(1, coords)
        SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    else
        local onScreen,_x,_y=World3dToScreen2d(coords.x, coords.y, coords.z)
        local px,py,pz=table.unpack(GetGameplayCamCoords())
    
        if onScreen then
            SetTextScale(0.37, 0.37)
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 255)
            SetTextOutline()
            SetTextEntry("STRING")
            SetTextCentre(1)
            AddTextComponentString(text)
            DrawText(_x,_y)
            local factor = (string.len(text)) / 370
            DrawRect(_x, _y + 0.0150, 0.005 + factor , 0.040, 20, 20, 20, 170)
        end
    end
end