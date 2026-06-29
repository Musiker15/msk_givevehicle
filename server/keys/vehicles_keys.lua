-- Adapter for vehicles_keys. Best-effort: exports vary between forks, so the
-- dispatcher pcall-guards every call. If your fork uses different export names,
-- adjust them here.
Keys.RegisterAdapter('vehicles_keys', {
    -- owner = { source = src } OR { identifier = '...' }
    GiveKey = function(owner, plate, _model)
        local p = MSK.String.Trim(plate)
        if owner.source then
            exports['vehicles_keys']:GiveKeys(owner.source, p)
        end
    end,

    RemoveKey = function(plate)
        exports['vehicles_keys']:RemoveKeys(MSK.String.Trim(plate))
    end,
})
