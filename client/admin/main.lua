-- Opens the admin dashboard NUI when the server grants access.
AdminState = AdminState or { isNuiOpen = false }

RegisterNetEvent('msk_givevehicle:admin:open', function(payload)
    if AdminState.isNuiOpen then return end
    AdminState.isNuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openAdmin', data = payload })
end)

-- Safety: free a stuck NUI focus on (re)start/stop.
AddEventHandler('onClientResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    AdminState.isNuiOpen = false
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
end)
