-- Adapter for VehicleKeyChain. Best-effort: exports vary between forks, so the
-- dispatcher pcall-guards every call. If your fork uses different export names,
-- adjust them here.
Keys.RegisterAdapter('VehicleKeyChain', {
    -- owner = { source = src } OR { identifier = '...' }
    GiveKey = function(owner, plate, _model)
        local p = MSK.String.Trim(plate)
        if owner.source then
            exports['VehicleKeyChain']:GiveKey(owner.source, p)
        elseif owner.identifier then
            exports['VehicleKeyChain']:GiveKeyByIdentifier(owner.identifier, p)
        end
    end,

    RemoveKey = function(plate)
        exports['VehicleKeyChain']:RemoveKeys(MSK.String.Trim(plate))
    end,
})
