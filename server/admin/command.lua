AdminCommand = AdminCommand or {}
AdminCommand.registered = {}

-- The command itself is NOT ACE-restricted; access control lives in the callback
-- (AdminPerms.CanOpen) so it respects dashboardGroups + the group.user blacklist.
function AdminCommand.Register(name)
    name = name or Config.adminCommand or 'givevehadmin'
    if AdminCommand.registered[name] then return end
    AdminCommand.registered[name] = true

    MSK.RegisterCommand(name, function(source)
        local src = source
        if src == 0 then
            print('^3[msk_givevehicle]^0 The admin dashboard can only be opened in-game.')
            return
        end
        if not AdminPerms.CanOpen(src) then
            Config.Notification(src, 'Keine Berechtigung für das Admin Dashboard.', 'error')
            return
        end
        TriggerClientEvent('msk_givevehicle:admin:open', src, AdminApi.BuildBootstrap(src))
    end, {
        help = 'Open the MSK GiveVehicle admin dashboard',
        restricted = false,
    })
end
