RegisterNetEvent('ds_powers:client:result', function(success, message)
    lib.notify({
        title = 'DarkSide',
        description = message,
        type = success and 'success' or 'error'
    })
end)

RegisterNetEvent('ds_powers:client:execute', function(powerId, power)
    local ped = PlayerPedId()
    if not ped or ped == 0 then return end

    if powerId == 'shadow_step' then
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)
        local target = vector3(
            coords.x + (forward.x * power.range),
            coords.y + (forward.y * power.range),
            coords.z
        )

        SetEntityCoords(ped, target.x, target.y, target.z, false, false, false, false)
        lib.notify({
            title = 'DarkSide',
            description = power.label,
            type = 'success'
        })
        return
    end

    if powerId == 'fallen_sense' then
        lib.notify({
            title = 'DarkSide',
            description = ('%s ativado por %ss'):format(power.label, math.floor(power.durationMs / 1000)),
            type = 'success'
        })
        return
    end
end)

RegisterCommand('dspower', function(_, args)
    local powerId = args[1]
    if not powerId then
        lib.notify({
            title = 'DarkSide',
            description = 'Use /dspower <power_id>',
            type = 'inform'
        })
        return
    end

    TriggerServerEvent('ds_powers:server:use', powerId)
end, false)
