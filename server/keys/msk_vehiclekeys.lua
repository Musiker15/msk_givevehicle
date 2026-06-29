-- Adapter for msk_vehiclekeys (the primary / fully-supported key script).
Keys.RegisterAdapter('msk_vehiclekeys', {
    -- owner = { source = src } OR { identifier = '...' }
    GiveKey = function(owner, plate, model)
        exports.msk_vehiclekeys:AddPrimaryKey(owner, { plate = MSK.String.Trim(plate), model = model })
    end,

    RemoveKey = function(plate)
        exports.msk_vehiclekeys:RemoveAllExistingKeys(MSK.String.Trim(plate))
    end,

    -- Client-spawned vehicle entity check (used for temp keys on spawn).
    HasKey = function(vehicle)
        return exports.msk_vehiclekeys:HasPlayerKey(vehicle)
    end,
})
