AdminStore = AdminStore or {}

-- In-memory permission matrix: [group_name] = { [perm] = true }
AdminStore.perms = {}
AdminStore.ready = false

local function jdecode(s)
    if type(s) ~= 'string' then return false end
    local ok, v = pcall(json.decode, s)
    if not ok then return false end
    return true, v
end
AdminStore.Decode = jdecode

local function isEnabled(v)
    return tonumber(v) ~= 0
end

----------------------------------------------------------------
-- Load DB rows into Config.* (the runtime source of truth).
----------------------------------------------------------------
function AdminStore.LoadSettings()
    local rows = MySQL.query.await('SELECT `skey`, `svalue` FROM `msk_givevehicle_settings`') or {}
    for _, row in ipairs(rows) do
        if row.skey ~= '__seeded__' then
            local ok, v = jdecode(row.svalue)
            if ok then Config[row.skey] = v end
        end
    end
end

function AdminStore.LoadPermissions()
    AdminStore.perms = {}
    local rows = MySQL.query.await('SELECT `group_name`, `perms` FROM `msk_givevehicle_permissions`') or {}
    for _, row in ipairs(rows) do
        local ok, p = jdecode(row.perms)
        AdminStore.perms[row.group_name] = (ok and type(p) == 'table') and p or {}
    end
end

-- Item vehicles -> Config.Vehicles (the same table server/items.lua reads).
function AdminStore.LoadItems()
    Config.Vehicles = {}
    local rows = MySQL.query.await('SELECT `id`, `label`, `data`, `enabled` FROM `msk_givevehicle_items`') or {}
    for _, row in ipairs(rows) do
        if isEnabled(row.enabled) then
            local ok, def = jdecode(row.data)
            if ok and type(def) == 'table' then
                Config.Vehicles[row.id] = {
                    label = row.label or def.label or row.id,
                    model = def.model or row.id,
                    categorie = def.categorie or 'car',
                }
            end
        end
    end
end

function AdminStore.LoadAll()
    AdminStore.LoadSettings()
    AdminStore.LoadPermissions()
    AdminStore.LoadItems()
    AdminStore.ready = true
end
