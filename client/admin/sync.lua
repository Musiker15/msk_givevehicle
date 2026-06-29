-- Applies DB-authoritative settings live (fuel system, plate format, vehicle
-- keys, theme...). No world objects to rebuild — this script has no blips/points.
local function applySettings(settings)
    if type(settings) ~= 'table' then return end
    for k, v in pairs(settings) do Config[k] = v end
end

RegisterNetEvent('msk_givevehicle:syncSettings', function(payload)
    if type(payload) == 'table' then applySettings(payload.settings) end
end)
