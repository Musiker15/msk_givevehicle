ESX = exports["es_extended"]:getSharedObject()

local Charset = {}
for i = 48,  57 do table.insert(Charset, string.char(i)) end
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

RegisterNetEvent('msk_givevehicle:giveVehicle')
AddEventHandler('msk_givevehicle:giveVehicle', function(item, veh)
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)

	ESX.Game.SpawnVehicle(veh.model, playerCoords, 0.0, function(vehicle)
		if DoesEntityExist(vehicle) then
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)
			
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			vehicleProps.plate = genPlate()
			TriggerServerEvent('msk_givevehicle:setVehicle', item, vehicleProps, veh.categorie)
			ESX.Game.DeleteVehicle(vehicle)			
		end
	end)
end)

RegisterNetEvent('msk_givevehicle:giveVehicleCommand')
AddEventHandler('msk_givevehicle:giveVehicleCommand', function(target, categorie, model, plate, console)
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local newPlate
	local carExist  = false

	if plate then
		newPlate = plate
	else
		newPlate = genPlate()
	end

	ESX.Game.SpawnVehicle(model, playerCoords, 0.0, function(vehicle)
		if DoesEntityExist(vehicle) then
			carExist = true
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)
			
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			vehicleProps.plate = newPlate
			TriggerServerEvent('msk_givevehicle:setVehicleCommand', target, categorie, model, newPlate, vehicleProps, console)
			ESX.Game.DeleteVehicle(vehicle)
			logging('debug', 'Vehicle registered with plate ' .. newPlate)
		end
	end)

	Wait(2000)
	if not carExist then
		Config.Notification(source, 'client', nil, Translation[Config.Locale]['clientCommand'] .. model .. Translation[Config.Locale]['clientCommand2'])
	end
end)

genPlate = function()
	local plate
	if Config.Plate.format:match('XXX XXX') then
		plate = string.upper(GetRandomLetter(3)) .. ' ' .. math.random(001, 999)
	elseif Config.Plate.format:match('XX XXXX') then
		if Config.Plate.enablePrefix then
			plate = Config.Plate.prefix .. ' ' .. math.random(0001, 9999)
		else
			plate = string.upper(GetRandomLetter(2)) .. ' ' .. math.random(0001, 9999)
		end
	end

	return plate
end

GetRandomLetter = function(length)
	Wait(0)
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

logging = function(code, ...)
	if Config.Debug then
		local script = "[^2"..GetCurrentResourceName().."^0]"

        if code == 'error' then
			print(script, '[^1ERROR^0]', ...)
		elseif code == 'debug' then
			print(script, '[^3DEBUG^0]', ...)
		end
	end
end