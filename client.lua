ESX = exports["es_extended"]:getSharedObject()

local Charset = {}
for i = 65,  90 do table.insert(Charset, string.char(i)) end
for i = 97, 122 do table.insert(Charset, string.char(i)) end

RegisterNetEvent('msk_vehicleItems:giveVehicle')
AddEventHandler('msk_vehicleItems:giveVehicle', function(item, veh)
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)

	ESX.Game.SpawnVehicle(veh.model, playerCoords, 0.0, function(vehicle)
		if DoesEntityExist(vehicle) then
			SetEntityVisible(vehicle, false, false)
			SetEntityCollision(vehicle, false)
			
			local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
			vehicleProps.plate = genPlate()
			TriggerServerEvent('msk_vehicleItems:setVehicle', item, vehicleProps, veh.categorie)
			ESX.Game.DeleteVehicle(vehicle)			
		end
	end)
end)

RegisterNetEvent('msk_vehicleItems:giveVehicleCommand')
AddEventHandler('msk_vehicleItems:giveVehicleCommand', function(target, categorie, model, plate, console)
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
			TriggerServerEvent('msk_vehicleItems:setVehicleCommand', target, categorie, model, newPlate, vehicleProps, console)
			ESX.Game.DeleteVehicle(vehicle)
			debug('Vehicle registered')		
		end
	end)

	Wait(2000)
	if not carExist then
		Config.Notification(source, 'client', nil, Translation[Config.Locale]['clientCommand'] .. model .. Translation[Config.Locale]['clientCommand2'])
	end
end)

function genPlate()
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

function GetRandomLetter(length)
	Wait(0)
	if length > 0 then
		return GetRandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
	else
		return ''
	end
end

function debug(msg, msg2, msg3)
	if Config.Debug then
        if msg3 then
            print(msg, msg2, msg3)
        elseif not msg3 and msg2 then
            print(msg, msg2)
        else
		    print(msg)
        end
	end
end