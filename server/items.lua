-- Registers the item-vehicles (Config.Vehicles, DB-managed) as usable items.
-- Using an item delivers the configured vehicle to a garage (stored = 1), reusing
-- the same Core.Give capture flow as the dashboard (plate dup-check + keys).
Items = Items or {}

local registered = {}

local function register(itemName)
    if registered[itemName] then return end
    registered[itemName] = true

    -- MSK.RegisterItem covers ESX, QBCore and Qbox in a single call.
    MSK.RegisterItem(itemName, function(source)
        -- Read the current definition lazily so dashboard edits take effect
        -- without re-registering.
        local def = Config.Vehicles and Config.Vehicles[itemName]
        if not def then return end

        Core.Give({
            captureClient = source,
            targetId = source,
            type = def.categorie or 'car',
            model = def.model,
            plate = nil,
            notifySrc = source,
            isItem = true,
            itemName = itemName,
        })
    end)
end

function Items.Register(itemName)
    register(itemName)
end

function Items.RegisterAll()
    for itemName in pairs(Config.Vehicles or {}) do
        register(itemName)
    end
end
