-- Server-console commands. The in-game slash commands were replaced by the
-- dashboard; these console equivalents stay and call the same Core.* functions.
-- All are console-only (source == 0).

local NAME = '^2[msk_givevehicle]^0'

-- Joins arg[from..#args] into a single (upper-cased) plate string.
local function joinPlate(args, from)
    local plate = args[from]
    if not plate then return nil end
    for i = from + 1, #args do plate = plate .. ' ' .. args[i] end
    return string.upper(plate)
end

-- _giveveh <playerID> <categorie> <carModel> <plate?>
RegisterCommand(Config.ConsoleCommands.giveveh, function(source, args)
    if source ~= 0 then return end
    if not (args[1] and args[2] and args[3]) then
        print('^1SYNTAX ERROR: ^5' .. Config.ConsoleCommands.giveveh .. ' <playerID> <categorie> <carModel> <plate> ^0| Plate is optional')
        return
    end
    local res = Core.Give({
        captureClient = tonumber(args[1]),
        targetId = tonumber(args[1]),
        type = args[2],
        model = args[3],
        plate = args[4] and joinPlate(args, 4) or nil,
        console = true,
    })
    if res.ok then print(('%s Vehicle ^5%s^0 is being delivered to ID ^5%s^0.'):format(NAME, args[3], args[1]))
    else print(('%s ^1Give failed:^0 %s'):format(NAME, res.err)) end
end)

-- _delveh <plate>
RegisterCommand(Config.ConsoleCommands.delveh, function(source, args)
    if source ~= 0 then return end
    local plate = joinPlate(args, 1)
    if not plate then
        print('^1SYNTAX ERROR: ^5' .. Config.ConsoleCommands.delveh .. ' <plate>')
        return
    end
    local res = Core.Delete({ plate = plate })
    if res.ok then print(('%s Deleted ^5%s^0.'):format(NAME, plate))
    else print(('%s ^1Delete failed:^0 %s'):format(NAME, res.err)) end
end)

-- _givejobveh <playerID> <categorie> <carModel> <job> <bool> <plate?>
RegisterCommand(Config.ConsoleCommands.givejobveh, function(source, args)
    if source ~= 0 then return end
    if not (args[1] and args[2] and args[3] and args[4] and args[5]) then
        print('^1SYNTAX ERROR: ^5' .. Config.ConsoleCommands.givejobveh .. ' <playerID> <categorie> <carModel> <job> <bool> <plate> ^0| Plate is optional')
        return
    end
    local res = Core.Give({
        captureClient = tonumber(args[1]),
        targetId = tonumber(args[1]),
        type = args[2],
        model = args[3],
        job = args[4],
        bool = args[5],
        plate = args[6] and joinPlate(args, 6) or nil,
        console = true,
    })
    if res.ok then print(('%s Job vehicle ^5%s^0 is being delivered to ID ^5%s^0.'):format(NAME, args[3], args[1]))
    else print(('%s ^1Give failed:^0 %s'):format(NAME, res.err)) end
end)

-- spawnveh <playerID> <plate>
RegisterCommand(Config.ConsoleCommands.spawnveh, function(source, args)
    if source ~= 0 then return end
    if not (args[1] and args[2]) then
        print('^1SYNTAX ERROR: ^5' .. Config.ConsoleCommands.spawnveh .. ' <playerID> <plate>')
        return
    end
    local res = Core.Spawn({ targetId = tonumber(args[1]), plate = joinPlate(args, 2) })
    if res.ok then print(('%s Spawned ^5%s^0 at ID ^5%s^0.'):format(NAME, joinPlate(args, 2), args[1]))
    else print(('%s ^1Spawn failed:^0 %s'):format(NAME, res.err)) end
end)
