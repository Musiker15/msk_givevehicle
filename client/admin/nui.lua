-- NUI callbacks for the admin dashboard. CRUD/action callbacks forward to the
-- gated server callbacks and return the server response verbatim.

local function forward(event)
    return function(data, cb)
        local res = MSK.Trigger(event, data)
        cb(res or { ok = false, err = 'no_response' })
    end
end

RegisterNUICallback('admin:close', function(_data, cb)
    SetNuiFocus(false, false)
    AdminState.isNuiOpen = false
    cb('ok')
end)

RegisterNUICallback('admin:bootstrap', forward('msk_givevehicle:admin:bootstrap'))

-- Vehicle actions
RegisterNUICallback('admin:vehicle:give', forward('msk_givevehicle:admin:vehicle:give'))
RegisterNUICallback('admin:vehicle:givejob', forward('msk_givevehicle:admin:vehicle:givejob'))
RegisterNUICallback('admin:vehicle:spawn', forward('msk_givevehicle:admin:vehicle:spawn'))
RegisterNUICallback('admin:vehicle:delete', forward('msk_givevehicle:admin:vehicle:delete'))
RegisterNUICallback('admin:vehicle:move', forward('msk_givevehicle:admin:vehicle:move'))
RegisterNUICallback('admin:vehicle:browse', forward('msk_givevehicle:admin:vehicle:browse'))

-- Item vehicles
RegisterNUICallback('admin:items:save', forward('msk_givevehicle:admin:items:save'))
RegisterNUICallback('admin:items:delete', forward('msk_givevehicle:admin:items:delete'))

-- Settings & permissions
RegisterNUICallback('admin:settings:save', forward('msk_givevehicle:admin:settings:save'))
RegisterNUICallback('admin:perms:saveGroup', forward('msk_givevehicle:admin:perms:saveGroup'))
RegisterNUICallback('admin:perms:deleteGroup', forward('msk_givevehicle:admin:perms:deleteGroup'))
RegisterNUICallback('admin:perms:dashboardGroups', forward('msk_givevehicle:admin:perms:dashboardGroups'))
RegisterNUICallback('admin:perms:validateGroup', forward('msk_givevehicle:admin:perms:validateGroup'))
