ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		local items = MySQL.query.await("SELECT name FROM items")

		if items then
			for k, v in pairs(Config.Vehicles) do
				local contains = table.contains(items, k)

				if not contains then 
					print('^1 Item ^3 ' .. k .. ' ^1 not exists, inserting item... ^0')
					local insertItem = MySQL.query.await("INSERT INTO items (name, label, weight, rare, can_remove) VALUES ('" .. k .. "', '" .. string.upper(k) .. "', 1, 0, 1);")
					if insertItem then
						print('^2 Successfully ^3 inserted ^2 Item ^3 ' .. k .. ' ^2 in ^3 items ^0')
					end
				end
			end
		end
	end
end)

for k, veh in pairs(Config.Vehicles) do
    ESX.RegisterUsableItem(k, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)

        xPlayer.triggerEvent('msk_givevehicle:giveVehicle', k, veh)
    end)
end

RegisterServerEvent('msk_givevehicle:setVehicle')
AddEventHandler('msk_givevehicle:setVehicle', function(item, props, vehicleType)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local data = MySQL.query('SELECT * FROM owned_vehicles WHERE plate = @plate', { 
		["@plate"] = props.plate
	})

	if data[1] then
		Config.Notification(src, 'server', xPlayer, Translation[Config.Locale]['item_already_exist']) -- Plate already exist
	else
		MySQL.query('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)', {
			['@owner']   = xPlayer.identifier,
			['@plate']   = props.plate,
			['@vehicle'] = json.encode(props),
			['@stored']  = 1,
			['type'] = vehicleType
		})

		xPlayer.removeInventoryItem(item, 1)
		Config.Notification(src, 'server', xPlayer, Translation[Config.Locale]['item_success'])
	end
end)

-- Ingame Commands
ESX.RegisterCommand(Config.Command, Config.AdminGroups, function(xPlayer, args, showError)
	xPlayer.triggerEvent('msk_givevehicle:giveVehicleCommand', args.player, args.type, args.vehicle, args.plate)
  end, false, {help = 'Give someone a Vehicle', arguments = {
	{name = 'player', help = 'PlayerID', type = 'player'},
	{name = 'type', help = 'Categorie', type = 'string'},
	{name = 'vehicle', help = 'Vehiclename', type = 'string'},
	{name = 'plate', help = '"Plate" (optional)', type = 'string'}
}})

ESX.RegisterCommand(Config.Command2, Config.AdminGroups, function(xPlayer, args, showError)
	if args.plate then
		MySQL.query('DELETE FROM owned_vehicles WHERE plate = @plate', {
			['@plate'] = args.plate
		}, function(result)
			if result == 1 then
				debug('Deleted', args.plate)
				Config.Notification(src, 'server', xPlayer, Translation[Config.Locale]['deleted'] .. args.plate .. Translation[Config.Locale]['deleted2'])
			else
				debug('Error while deleting', args.plate)
				Config.Notification(src, 'server', xPlayer, Translation[Config.Locale]['delete_failed'] .. args.plate .. Translation[Config.Locale]['delete_failed2'])
			end
		end)
	end
  end, false, {help = 'Delete a Vehicle from Database', arguments = {
	{name = 'plate', help = '"Plate"', type = 'string'}
}})

-- Console Commands
RegisterCommand(Config.ConsoleCommand, function(source, args, rawCommand)
    if (source == 0) then
		local playerID = args[1]

		if args[1] and args[2] and args[3] and args[4] then
			local plate = args[4]

			if #args > 4 then
				for i=5, #args do
					plate = plate.." "..args[i]
				end
			end
			plate = string.upper(plate)

			TriggerClientEvent('msk_givevehicle:giveVehicleCommand', playerID, playerID, args[2], args[3], plate, true)
		elseif args[1] and args[2] and args[3] then
			TriggerClientEvent('msk_givevehicle:giveVehicleCommand', playerID, playerID, args[2], args[3], nil, true)
		else
			print('^1SYNTAX ERROR: ^5_giveveh <playerID> <categorie> <carModel> <plate> ^0| Plate is optional')
		end
    end
end)

RegisterCommand(Config.ConsoleCommand2, function(source, args, rawCommand)
    if (source == 0) then
		if args[1] then
			local plate = args[1]

			if #args > 1 then
				for i=2, #args do
					plate = plate.." "..args[i]
				end
			end
			plate = string.upper(plate)

			MySQL.query('DELETE FROM owned_vehicles WHERE plate = @plate', {
				['@plate'] = plate
			}, function(result)
				if result == 1 then
					debug('Deleted', plate)
				else
					debug('Error while deleting', plate)
				end
			end)
		else
			print('^1SYNTAX ERROR: ^5_delveh <plate>')
		end
    end
end)

RegisterServerEvent('msk_givevehicle:setVehicleCommand')
AddEventHandler('msk_givevehicle:setVehicleCommand', function(xTarget, categorie, model, plate, props, console)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local data = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = @plate', { 
		["@plate"] = plate
	})
	if console then
		xTarget = ESX.GetPlayerFromId(xTarget)
	end

	if data[1] then
		debug(Translation[Config.Locale]['vehicle_already_exist'] .. plate .. Translation[Config.Locale]['vehicle_already_exist2'])
		if xPlayer and not console then
			Config.Notification(src, 'server', xPlayer, Translation[Config.Locale]['vehicle_already_exist'] .. plate .. Translation[Config.Locale]['vehicle_already_exist2'])
		end
	else
		MySQL.query('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)', {
			['@owner']   = xTarget.identifier,
			['@plate']   = plate,
			['@vehicle'] = json.encode(props),
			['@stored']  = 1,
			['type'] = categorie
		})

		debug(Translation[Config.Locale]['vehicle_successfully_added'] .. model .. Translation[Config.Locale]['vehicle_successfully_added2'] .. plate .. Translation[Config.Locale]['vehicle_successfully_added2'] .. xTarget.source .. Translation[Config.Locale]['vehicle_successfully_added2'])
		if xPlayer and not console then
			Config.Notification(src, 'server', xPlayer, Translation[Config.Locale]['vehicle_successfully_added'] .. model .. Translation[Config.Locale]['vehicle_successfully_added2'] .. plate .. Translation[Config.Locale]['vehicle_successfully_added2'] .. xTarget.source .. Translation[Config.Locale]['vehicle_successfully_added2'])

			if xPlayer.source == xTarget.source then
				Config.Notification(src, 'server', xPlayer, Translation[Config.Locale]['got_vehicle'] .. model .. Translation[Config.Locale]['got_vehicle2'] .. plate .. Translation[Config.Locale]['got_vehicle3'])
			end
		end

		if xPlayer and console then
			Config.Notification(src, 'server', xPlayer, Translation[Config.Locale]['got_vehicle'] .. model .. Translation[Config.Locale]['got_vehicle2'] .. plate .. Translation[Config.Locale]['got_vehicle3'])
		end
	end
end)

function table.contains(items, item)
	for k, v in pairs(items) do
		if v.name == item then
			return true
		end
	end
	return false
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

---- GitHub Updater ----
function GetCurrentVersion()
	return GetResourceMetadata(GetCurrentResourceName(), "version")
end

local CurrentVersion = GetCurrentVersion()
local resourceName = "^4["..GetCurrentResourceName().."]^0"

if Config.VersionChecker then
	PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/msk_givevehicle/main/VERSION', function(Error, NewestVersion, Header)
		print("###############################")
    	if CurrentVersion == NewestVersion then
	    	print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
    	elseif CurrentVersion ~= NewestVersion then
        	print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
	    	print('^5Newest Version: ^2' .. NewestVersion .. '^0 - ^6Download here: ^9https://github.com/Musiker15/msk_givevehicle/releases/tag/v'.. NewestVersion .. '^0')
    	end
		print("###############################")
	end)
else
	print("###############################")
	print(resourceName .. '^2 ✓ Resource loaded^0')
	print("###############################")
end