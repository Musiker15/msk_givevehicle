for item, vehData in pairs(Config.Vehicles) do
    ESX.RegisterUsableItem(item, function(source)
        TriggerClientEvent('msk_givevehicle:giveVehicle', source, item, vehData)
    end)
end

RegisterServerEvent('msk_givevehicle:setVehicle', function(item, props, vehicleType)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local alreadyExists = MySQL.scalar.await('SELECT COUNT(plate) FROM owned_vehicles WHERE plate = ?', {MSK.Trim(plate, true)}) > 0

	if alreadyExists then
		Config.Notification(src, Translation[Config.Locale]['item_already_exist'], 'error') -- Plate already exist
		return
	end

	MySQL.query('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = props.plate,
		['@vehicle'] = json.encode(props),
		['@stored'] = 1,
		['type'] = vehicleType
	})

	xPlayer.removeInventoryItem(item, 1)
	Config.Notification(src, Translation[Config.Locale]['item_success'], 'success')
end)

----------------------------------------------------------------
-- Ingame Commands
----------------------------------------------------------------
ESX.RegisterCommand(Config.Commands.giveveh, Config.AdminGroups, function(xPlayer, args, showError) -- /giveveh <playerID> <categorie> <carModel> <plate>
	TriggerClientEvent('msk_givevehicle:giveVehicleCommand', xPlayer.source, args.player, args.type, args.vehicle, args.plate)
  end, false, {help = 'Give someone a Vehicle', arguments = {
	{name = 'player', help = 'PlayerID', type = 'player'},
	{name = 'type', help = 'Categorie', type = 'string'},
	{name = 'vehicle', help = 'Vehiclename', type = 'string'},
	{name = 'plate', help = '"Plate" (optional)', type = 'string'}
}})

ESX.RegisterCommand(Config.Commands.delveh, Config.AdminGroups, function(xPlayer, args, showError) -- /delveh <plate>
	if args.plate then
		MySQL.query('DELETE FROM owned_vehicles WHERE plate = @plate', {
			['@plate'] = args.plate
		}, function(result)
			if result.affectedRows == 1 then
				logging('debug', 'Deleted: ' .. args.plate)
				Config.Notification(src, Translation[Config.Locale]['deleted']:format(args.plate))
			else
				logging('debug', 'Error while deleting: ' .. args.plate)
				Config.Notification(src, Translation[Config.Locale]['delete_failed']:format(args.plate))
			end
		end)
	end
  end, false, {help = 'Delete a Vehicle from Database', arguments = {
	{name = 'plate', help = '"Plate"', type = 'string'}
}})

ESX.RegisterCommand(Config.Commands.givejobveh, Config.AdminGroups, function(xPlayer, args, showError) -- /givejobveh <playerID> <categorie> <carModel> <job> <bool> <plate>
	TriggerClientEvent('msk_givevehicle:giveVehicleCommand', xPlayer.source, args.player, args.type, args.vehicle, args.plate, nil, args.job, args.identifier)
  end, false, {help = 'Give someone a Vehicle', arguments = {
	{name = 'player', help = 'PlayerID', type = 'player'},
	{name = 'type', help = 'Categorie', type = 'string'},
	{name = 'vehicle', help = 'Vehiclename', type = 'string'},
	{name = 'job', help = 'Job', type = 'string'},
	{name = 'identifier', help = 'Identifier', type = 'number'},
	{name = 'plate', help = '"Plate" (optional)', type = 'string'}
}})

-- You can use this command at the console too
ESX.RegisterCommand(Config.Commands.spawnveh, Config.AdminGroups, function(xPlayer, args, showError) -- /spawnveh <playerID> <plate>
	MySQL.query("SELECT * FROM owned_vehicles WHERE plate = @plate", {
		['@plate'] = args.plate
	}, function(result)
		if result and result[1] then
			TriggerClientEvent('msk_givevehicle:spawnVehicle', args.player.source, json.decode(result[1].vehicle))
			MySQL.query("UPDATE owned_vehicles SET stored = 0 WHERE plate = @plate", {['@plate'] = args.plate})
		end
	end)
end, true, {help = 'Spawn Owned Vehicle by Plate', arguments = {
	{name = 'player', help = 'PlayerID', type = 'player'},
	{name = 'plate', help = '"Plate"', type = 'string'}
}})

----------------------------------------------------------------
-- Console Commands
----------------------------------------------------------------
RegisterCommand(Config.ConsoleCommands.giveveh, function(source, args, rawCommand) -- _giveveh <playerID> <categorie> <carModel> <plate>
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

RegisterCommand(Config.ConsoleCommands.delveh, function(source, args, rawCommand) -- _delveh <plate>
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
					logging('debug', 'Deleted', plate)
				else
					logging('debug', 'Error while deleting', plate)
				end
			end)
		else
			print('^1SYNTAX ERROR: ^5_delveh <plate>')
		end
    end
end)

RegisterCommand(Config.ConsoleCommands.givejobveh, function(source, args, rawCommand) -- _givejobveh <playerID> <categorie> <carModel> <job> <bool> <plate>
    if (source == 0) then
		local playerID = args[1]

		if args[1] and args[2] and args[3] and args[4] and args[5] and args[6] then
			local plate = args[6]

			if #args > 6 then
				for i=7, #args do
					plate = plate.." "..args[i]
				end
			end
			plate = string.upper(plate)

			TriggerClientEvent('msk_givevehicle:giveVehicleCommand', playerID, playerID, args[2], args[3], plate, true, args[4], args[5])
		elseif args[1] and args[2] and args[3] and args[4] and args[5] and not args[6] then
			TriggerClientEvent('msk_givevehicle:giveVehicleCommand', playerID, playerID, args[2], args[3], nil, true, args[4], args[5])
		else
			print('^1SYNTAX ERROR: ^5_givejobveh <playerID> <categorie> <carModel> <job> <bool> <plate> ^0| Plate is optional')
		end
    end
end)

RegisterServerEvent('msk_givevehicle:setVehicleCommand', function(xTarget, categorie, model, plate, props, console, job, bool)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	local data = MySQL.query.await('SELECT * FROM owned_vehicles WHERE plate = @plate', { 
		["@plate"] = plate
	})

	if console then
		xTarget = ESX.GetPlayerFromId(xTarget)
	end

	if data[1] then
		logging('debug', Translation[Config.Locale]['vehicle_already_exist']:format(plate))
		if xPlayer and not console then
			Config.Notification(src, Translation[Config.Locale]['vehicle_already_exist']:format(plate))
		end
	else
		if job then
			local identifier

			if tostring(bool) == '1' then
				identifier = job
			elseif tostring(bool) == '0' then
				identifier = xTarget.identifier
			end

			MySQL.query('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type, job) VALUES (@owner, @plate, @vehicle, @stored, @type, @job)', {
				['@owner']   = identifier,
				['@plate']   = plate,
				['@vehicle'] = json.encode(props),
				['@stored']  = 1,
				['type'] = categorie,
				['job'] = job
			})
		else
			MySQL.query('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type)', {
				['@owner']   = xTarget.identifier,
				['@plate']   = plate,
				['@vehicle'] = json.encode(props),
				['@stored']  = 1,
				['type'] = categorie
			})
		end

		logging('debug', Translation[Config.Locale]['vehicle_successfully_added']:format(model, plate, xTarget.source))
		if xPlayer and not console then
			Config.Notification(src, Translation[Config.Locale]['vehicle_successfully_added']:format(model, plate, xTarget.source))

			if xPlayer.source == xTarget.source then
				Config.Notification(src, Translation[Config.Locale]['got_vehicle']:format(model, plate))
			end
		end

		if xPlayer and console then
			Config.Notification(src, Translation[Config.Locale]['got_vehicle']:format(model, plate))
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

logging = function(code, ...)
	if not Config.Debug then return end
	MSK.Logging(code, ...)
end