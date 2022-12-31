ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('smd_applepicking:giveApple', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        if xPlayer.canCarryItem(Config.AppleItem, 1) then
            xPlayer.addInventoryItem(Config.AppleItem, 1)
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('smd_applepicking:doesHaveRoom', function(source, cb)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        if xPlayer.canCarryItem(Config.AppleItem, 1) then
            cb(true)
        else
            cb(false)
            if not alerted then
                alerted = true
                notification(Config.Locales["backpackFull"], _source)
                Citizen.Wait(5000)
                alerted = false
            end
        end
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('smd_applepicking:doesHave', function(source, cb, item)
    local done = false
	local xPlayer = ESX.GetPlayerFromId(source)
	local amount = xPlayer.getInventoryItem(item).count
    local randomAmount = math.random(3, 6)
    if item == Config.AppleItem then
        if amount > randomAmount then
            cb(true, randomAmount)
        else
            cb(false)
        end
    else
        if amount > 0 then
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterServerEvent('smd_applepicking:giveBottle')
AddEventHandler('smd_applepicking:giveBottle', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local bottleAmount = xPlayer.getInventoryItem(Config.bottleItem).count
	
	if bottleAmount < 1 then
        if xPlayer.canCarryItem(Config.bottleItem, 1) then
            xPlayer.addInventoryItem(Config.bottleItem, 1)
            notification(Config.Locales["giveBottle"], _source)
        else
            notification(Config.Locales["backpackFull"], _source)
            return
        end
    else
        notification(Config.Locales["alreadyHaveBottle"], _source)
	end
end)

RegisterServerEvent('smd_applepicking:sell')
AddEventHandler('smd_applepicking:sell', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local juiceAmount = xPlayer.getInventoryItem(Config.JuiceItem).count
	
	if juiceAmount > 0 then
		xPlayer.removeInventoryItem(Config.JuiceItem, juiceAmount)
		local price = juiceAmount * math.random(Config.minMoney, Config.maxMoney)
		xPlayer.addMoney(price)
        notification('-' .. juiceAmount .. Config.Locales["removeApplejuice"], _source)
        notification('+' .. price .. Config.Locales["currency"], _source)

	else
        notification(Config.Locales["noJuice"], _source)
	end
end)

RegisterServerEvent('smd_applepicking:makeJuice')
AddEventHandler('smd_applepicking:makeJuice', function(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer.canCarryItem(Config.JuiceItem, 1) then
        xPlayer.addInventoryItem(Config.JuiceItem, 1)
        notification(Config.Locales["giveJuice"], _source)
    else
        notification(Config.Locales["backpackFull"], _source)
        return
    end
end)

RegisterServerEvent('smd_applepicking:applejuice')
AddEventHandler('smd_applepicking:applejuice', function(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local appleAmount = xPlayer.getInventoryItem(Config.AppleItem).count
	
    if appleAmount >= amount then
        xPlayer.removeInventoryItem(Config.AppleItem, amount)
        xPlayer.removeInventoryItem(Config.bottleItem, 1)
        notification("-" .. amount .. Config.Locales["removeApple"], _source)
        notification(Config.Locales["removeEmptyBottle"], _source)
    else
        notification(Config.Locales["outOfApples"], _source)
        return
    end
end)

function notification(text, _source)
	if not CurrentlyText then
		CurrentlyText = true
        if Config.UseMythic then
            TriggerClientEvent('mythic_notify:client:SendAlert', _source, { type = 'inform', text = text, length = 5000})
        else
            TriggerClientEvent('esx:showNotification', _source, text)
        end
		Citizen.Wait(1000)
		CurrentlyText = false
	end
end
