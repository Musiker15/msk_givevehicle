RegisterNetEvent('msk_givevehicle:spawnVehicle', function(props)
	local playerPed = PlayerPedId()

	ESX.Game.SpawnVehicle(props.model, GetEntityCoords(playerPed), GetEntityHeading(playerPed), function(vehicle)
		ESX.Game.SetVehicleProperties(vehicle, props)
		Config.FuelSystem(vehicle, props.fuelLevel)

		if (GetResourceState("msk_vehiclekeys") == "started") then
			local hasKey = exports.msk_vehiclekeys:HasPlayerKey(vehicle)

			if not hasKey then
				exports.msk_vehiclekeys:AddTempKey(vehicle)
			end
		end
	end)
end)

RegisterNetEvent('msk_givevehicle:giveVehicle', function(item, veh)
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)

	ESX.Game.SpawnVehicle(veh.model, playerCoords, 0.0, function(vehicle)
		SetEntityVisible(vehicle, false, false)
		SetEntityCollision(vehicle, false)
		
		local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
		vehicleProps.plate = GeneratePlate()
		vehicleProps.fuelLevel = 100.0
		TriggerServerEvent('msk_givevehicle:setVehicle', item, vehicleProps, veh.categorie)
		ESX.Game.DeleteVehicle(vehicle)
	end)
end)

RegisterNetEvent('msk_givevehicle:giveVehicleCommand', function(target, categorie, model, plate, console, job, bool)
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local newPlate
	local carExist = false

	if plate then
		newPlate = plate
	else
		newPlate = GeneratePlate()
	end

	ESX.Game.SpawnVehicle(model, playerCoords, 0.0, function(vehicle)
		if DoesEntityExist(vehicle) then
			carExist = true
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)
			
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			vehicleProps.plate = newPlate
			vehicleProps.fuelLevel = 100.0

			TriggerServerEvent('msk_givevehicle:setVehicleCommand', target, categorie, model, newPlate, vehicleProps, console, job, bool)
			ESX.Game.DeleteVehicle(vehicle)
		end
	end)

	Wait(2000)
	if not carExist then
		Config.Notification(nil, Translation[Config.Locale]['clientCommand']:format(model))
	end
end)

GeneratePlate = function()
	local plate

	if Config.Plate.format == 'XXX XXX' then
		plate = string.upper(MSK.GetRandomString(3)) .. ' ' .. math.random(100, 999)
	elseif Config.Plate.format == 'XX XXXX' then
		if Config.Plate.enablePrefix then
			plate = Config.Plate.prefix .. ' ' .. math.random(1000, 9999)
		else
			plate = string.upper(MSK.GetRandomString(2)) .. ' ' .. math.random(1000, 9999)
		end
	end

	return plate
end

logging = function(code, ...)
	if not Config.Debug then return end
	MSK.Logging(code, ...)
end