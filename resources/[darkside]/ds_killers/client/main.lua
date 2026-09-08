local spawnedKillers = {}

local function notify(description, notificationType)
    lib.notify({
        title = 'DarkSide',
        description = description,
        type = notificationType or 'inform'
    })
end

RegisterNetEvent('ds_killers:client:message', function(message, notificationType)
    notify(message, notificationType)
end)

local function spawnKiller(instanceId, killerId)
    local definition = DarkSideKillers[killerId]
    if not definition then
        TriggerServerEvent('ds_killers:server:spawnFailed', instanceId, 'unknown_killer')
        return
    end

    local model = joaat(definition.model)

    local ok = pcall(function()
        lib.requestModel(model, DarkSideKillersConfig.ModelLoadTimeout)
    end)

    if not ok or not HasModelLoaded(model) then
        TriggerServerEvent('ds_killers:server:spawnFailed', instanceId, 'model_load_failed')
        notify(('Não foi possível carregar o modelo do killer %s.'):format(definition.label), 'error')
        return
    end

    local playerPed = PlayerPedId()
    local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, definition.spawnOffset, 0.0)
    local heading = GetEntityHeading(playerPed) + 180.0

    local ped = CreatePed(model, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, true, 0, 0)

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(model)
        TriggerServerEvent('ds_killers:server:spawnFailed', instanceId, 'create_ped_failed')
        notify('Falha ao criar o killer de teste.', 'error')
        return
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetEntityCanBeDamaged(ped, true)
    SetEntityMaxHealth(ped, definition.maxHealth)
    SetEntityHealth(ped, definition.maxHealth, 0)
    SetRandomOutfitVariation(ped, true)

    local netId = NetworkGetNetworkIdFromEntity(ped)
    SetNetworkIdCanMigrate(netId, true)
    SetNetworkIdExistsOnAllMachines(netId, true)

    local registered, reason = exports['ds_ai']:RegisterPed(netId, definition.ai, instanceId)
    if not registered then
        DeleteEntity(ped)
        SetModelAsNoLongerNeeded(model)
        TriggerServerEvent('ds_killers:server:spawnFailed', instanceId, reason or 'ai_registration_failed')
        return
    end

    spawnedKillers[instanceId] = {
        killerId = killerId,
        ped = ped,
        netId = netId
    }

    SetModelAsNoLongerNeeded(model)
    TriggerServerEvent('ds_killers:server:spawned', instanceId, netId, {
        x = spawnCoords.x,
        y = spawnCoords.y,
        z = spawnCoords.z,
        heading = heading
    })

    notify(('%s foi criado. Ele começará a caçar quando detectar um jogador.'):format(definition.label), 'success')
end

local function deleteInstance(instanceId)
    local entry = spawnedKillers[instanceId]
    if not entry then return end

    exports['ds_ai']:UnregisterPed(entry.netId)

    if DoesEntityExist(entry.ped) then
        NetworkRequestControlOfEntity(entry.ped)
        local startedAt = GetGameTimer()

        while not NetworkHasControlOfEntity(entry.ped) and GetGameTimer() - startedAt < 1500 do
            Wait(0)
            NetworkRequestControlOfEntity(entry.ped)
        end

        if DoesEntityExist(entry.ped) then
            DeleteEntity(entry.ped)
        end
    end

    spawnedKillers[instanceId] = nil
end

RegisterNetEvent('ds_killers:client:spawn', function(instanceId, killerId)
    spawnKiller(instanceId, killerId)
end)

RegisterNetEvent('ds_killers:client:delete', function(instanceId)
    deleteInstance(instanceId)
end)

RegisterNetEvent('ds_killers:client:deleteAll', function()
    local ids = {}
    for instanceId in pairs(spawnedKillers) do
        ids[#ids + 1] = instanceId
    end

    for _, instanceId in ipairs(ids) do
        deleteInstance(instanceId)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() or not DarkSideKillersConfig.CleanupOnResourceStop then return end

    for _, entry in pairs(spawnedKillers) do
        exports['ds_ai']:UnregisterPed(entry.netId)
        if DoesEntityExist(entry.ped) then
            DeleteEntity(entry.ped)
        end
    end
end)
