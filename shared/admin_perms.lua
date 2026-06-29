AdminPerms = AdminPerms or {}

----------------------------------------------------------------
-- Permission keys. Order matters: the NUI renders the matrix in this order and
-- decides which tabs are visible from these.
--   vehicle.move is only meaningful when msk_garage is running.
----------------------------------------------------------------
AdminPerms.PERMS = {
    'vehicle.give', 'vehicle.givejob', 'vehicle.spawn', 'vehicle.delete',
    'vehicle.move', 'vehicle.browse',
    'items.manage', 'settings.manage', 'permissions.manage',
}

-- Settings that may be edited from the dashboard (requires `settings.manage`).
-- These are the DB-managed keys (seeded from config.lua). Code hooks
-- (Config.Notification, Config.CustomFuelSystem) are intentionally NOT here.
AdminPerms.SETTINGS_KEYS = {
    'Locale', 'Debug', 'VersionChecker', 'FuelSystem', 'Plate',
    'VehicleKeys', 'adminCommand', 'Theme', 'BrandTag',
}

-- Selectable fuel adapters exposed to the Settings dropdown. Keep in sync with
-- ApplyFuel() in client/main.lua.
AdminPerms.FUEL_SCRIPTS = { 'statebag', 'LegacyFuel', 'ox_fuel', 'qs-fuelstations', 'native', 'custom' }

-- Selectable vehicle-key adapters. Keep in sync with server/keys/.
AdminPerms.VEHICLEKEY_SCRIPTS = { 'msk_vehiclekeys', 'VehicleKeyChain', 'vehicles_keys' }

-- Vehicle categories accepted by the give/job-give forms.
AdminPerms.VEHICLE_TYPES = {
    'car', 'truck', 'bike', 'boat', 'submarine', 'helicopter', 'aircraft', 'trailer', 'train',
}

-- Editable UI colour keys (hex strings). Keep in sync with web/src/lib/theme.ts.
AdminPerms.THEME_KEYS = { 'accent', 'bg', 'panel', 'textPrimary', 'textSecondary' }
AdminPerms.DEFAULT_THEME = {
    accent = '#00E676',
    bg = '#0a0b0d',
    panel = '#131317',
    textPrimary = '#f0ede8',
    textSecondary = '#b0adb8',
}

-- Suggested group names shown in the UI when adding a new group.
AdminPerms.SUGGESTED_GROUPS = { 'admin', 'mod', 'dev' }

-- group.admin always has every right and can never be edited.
AdminPerms.PROTECTED_GROUPS = { admin = true }

-- group.user may NEVER open the dashboard and can never be granted rights.
AdminPerms.BLACKLIST_GROUPS = { user = true }

----------------------------------------------------------------
-- Helpers
----------------------------------------------------------------
function AdminPerms.AllPerms()
    local t = {}
    for _, p in ipairs(AdminPerms.PERMS) do t[p] = true end
    return t
end

function AdminPerms.IsProtected(group)
    return AdminPerms.PROTECTED_GROUPS[tostring(group):lower()] == true
end

function AdminPerms.IsBlacklisted(group)
    return AdminPerms.BLACKLIST_GROUPS[tostring(group):lower()] == true
end

-- Maps an owned_vehicles.type (or a garage's first configured type) to a coarse
-- category, used to validate "move to garage" target compatibility.
local TYPE_CATEGORY = {
    car = 'land', automobile = 'land', truck = 'land', trailer = 'land',
    train = 'land', bike = 'land', motorcycle = 'land', motorbike = 'land',
    bicycle = 'land',
    boat = 'sea', submarine = 'sea', submarinecar = 'sea',
    helicopter = 'air', heli = 'air', aircraft = 'air', plane = 'air',
    airplane = 'air',
}

function AdminPerms.CategoryForType(vehicleType)
    return TYPE_CATEGORY[tostring(vehicleType):lower()] or 'land'
end
