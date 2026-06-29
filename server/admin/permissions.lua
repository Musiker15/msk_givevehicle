-- Server-side permission resolution. Extends the shared AdminPerms table.
AdminPerms = AdminPerms or {}

local cache = {}          -- [src] = { perms = {...}, at = ms }
local CACHE_TTL = 5000    -- ms

-- ESX groups aren't always mirrored into FiveM's ACE system, so resolve the
-- framework group too: membership = "ACE principal OR framework group".
function AdminPerms.GetFrameworkGroup(src)
    if not MSK.GetPlayer then return nil end
    local ok, xPlayer = pcall(MSK.GetPlayer, { source = src })
    if not ok or not xPlayer then return nil end
    if type(xPlayer.getGroup) == 'function' then
        local g = xPlayer.getGroup()
        if g then return tostring(g):lower() end
    end
    if xPlayer.group then return tostring(xPlayer.group):lower() end
    return nil
end

function AdminPerms.PlayerInGroup(src, group)
    group = tostring(group):lower()
    if IsPlayerAceAllowed(src, ('group.%s'):format(group)) then return true end
    return AdminPerms.GetFrameworkGroup(src) == group
end

function AdminPerms.IsFullAdmin(src)
    return AdminPerms.PlayerInGroup(src, 'admin')
end

function AdminPerms.GetPlayerPerms(src)
    local c = cache[src]
    if c and (GetGameTimer() - c.at) < CACHE_TTL then return c.perms end

    local perms
    if AdminPerms.IsFullAdmin(src) then
        perms = AdminPerms.AllPerms()
    else
        perms = {}
        for group, matrix in pairs(AdminStore.perms) do
            if not AdminPerms.IsBlacklisted(group) and AdminPerms.PlayerInGroup(src, group) then
                for perm, allowed in pairs(matrix) do
                    if allowed then perms[perm] = true end
                end
            end
        end
    end

    cache[src] = { perms = perms, at = GetGameTimer() }
    return perms
end

function AdminPerms.Has(src, perm)
    return AdminPerms.GetPlayerPerms(src)[perm] == true
end

-- May the player open the dashboard? admin always; otherwise must be in an
-- allowed dashboard group (never 'user') AND have >= 1 right.
function AdminPerms.CanOpen(src)
    if AdminPerms.IsFullAdmin(src) then return true end

    local inAllowed = false
    for _, group in ipairs(Config.dashboardGroups or {}) do
        if not AdminPerms.IsBlacklisted(group) and AdminPerms.PlayerInGroup(src, group) then
            inAllowed = true
            break
        end
    end
    if not inAllowed then return false end

    return next(AdminPerms.GetPlayerPerms(src)) ~= nil
end

function AdminPerms.Invalidate(src)
    if src then cache[src] = nil else cache = {} end
end

AddEventHandler('playerDropped', function()
    if source then cache[source] = nil end
end)
