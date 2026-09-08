local RSGCore = exports['rsg-core']:GetCoreObject()
local instances = {}
local sequence = 0

local function makeInstanceId(source)
    sequence = sequence + 1
    return ('killer:%d:%d:%d'):format(os.time(), source or 0, sequence)
end

local function getCitizenId(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    return Player and Player.PlayerData and Player.PlayerData.citizenid or nil
end

local function isAdmin(source)
    return source == 0 or IsPlayerAceAllowed(source, DarkSideKillersConfig.AdminAce)
end

local function sendMessage(source, message, notificationType)
    if source == 0 then
        print(('[DarkSide][Killers] %s'):format(message))
        return
    end

    TriggerClientEvent('ds_killers:client:message', source, message, notificationType or 'inform')
end

local function persistInstance(instance)
    MySQL.insert.await([[
        INSERT INTO ds_killer_instances
            (instance_id, killer_id, owner_citizenid, net_id, state, target_citizenid, spawn_coords)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            net_id = VALUES(net_id),
            state = VALUES(state),
            target_citizenid = VALUES(target_citizenid),
            spawn_coords = VALUES(spawn_coords),
            updated_at = CURRENT_TIMESTAMP
    ]], {
        instance.id,
        instance.killerId,
        instance.ownerCitizenId,
        instance.netId,
        instance.state,
        instance.targetCitizenId,
        instance.coords and json.encode(instance.coords) or nil
    })
end

local function logEncounter(instance, targetCitizenId, eventType, payload)
    if not DarkSideKillersConfig.PersistEncounters then return end

    MySQL.insert.await([[
        INSERT INTO ds_killer_encounters
            (instance_id, killer_id, citizenid, event_type, payload)
        VALUES (?, ?, ?, ?, ?)
    ]], {
        instance.id,
        instance.killerId,
        targetCitizenId,
        eventType,
        payload and json.encode(payload) or nil
    })
end

local function requestSpawn(targetSource, killerId, requestedBy)
    local definition = DarkSideKillers[killerId]
    if not definition then
        return false, 'Killer inválido.'
    end

    if not GetPlayerName(targetSource) then
        return false, 'Player alvo não está conectado.'
    end

    local ownerCitizenId = getCitizenId(targetSource)
    if not ownerCitizenId then
        return false, 'Personagem RSG do player ainda não foi carregado.'
    end

    local instanceId = makeInstanceId(targetSource)
    local instance = {
        id = instanceId,
        killerId = killerId,
        owner = targetSource,
        ownerCitizenId = ownerCitizenId,
        requestedBy = requestedBy,
        netId = nil,
        state = 'REQUESTED',
        targetCitizenId = nil,
        coords = nil
    }

    instances[instanceId] = instance
    persistInstance(instance)
    TriggerClientEvent('ds_killers:client:spawn', targetSource, instanceId, killerId)

    return true, instanceId
end

local function despawnInstance(instanceId, reason)
    local instance = instances[instanceId]
    if not instance then return false end

    TriggerClientEvent('ds_killers:client:delete', instance.owner, instanceId)
    instance.state = 'DESPAWNED'
    instance.targetCitizenId = nil

    MySQL.update.await([[
        UPDATE ds_killer_instances
        SET state = 'DESPAWNED', despawn_reason = ?, despawned_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
        WHERE instance_id = ?
    ]], { reason or 'manual', instanceId })

    instances[instanceId] = nil
    return true
end

RegisterNetEvent('ds_killers:server:spawned', function(instanceId, netId, coords)
    local source = source
    local instance = instances[instanceId]
    if not instance or instance.owner ~= source then return end
    if type(netId) ~= 'number' or netId <= 0 then return end

    instance.netId = netId
    instance.coords = coords
    instance.state = 'IDLE'
    persistInstance(instance)
    logEncounter(instance, instance.ownerCitizenId, 'SPAWNED', coords)
end)

RegisterNetEvent('ds_killers:server:spawnFailed', function(instanceId, reason)
    local source = source
    local instance = instances[instanceId]
    if not instance or instance.owner ~= source then return end

    instance.state = 'FAILED'

    MySQL.update.await([[
        UPDATE ds_killer_instances
        SET state = 'FAILED', failure_reason = ?, updated_at = CURRENT_TIMESTAMP
        WHERE instance_id = ?
    ]], { tostring(reason or 'unknown'), instanceId })

    logEncounter(instance, instance.ownerCitizenId, 'SPAWN_FAILED', { reason = reason })
    instances[instanceId] = nil
end)

RegisterNetEvent('ds_killers:server:aiStateChanged', function(instanceId, state, targetSource)
    local source = source
    local instance = instances[instanceId]
    if not instance or instance.owner ~= source then return end

    local allowedStates = {
        IDLE = true,
        CHASE = true,
        ATTACK = true,
        SEARCH = true
    }

    if not allowedStates[state] then return end

    local targetCitizenId = nil
    if targetSource and GetPlayerName(targetSource) then
        targetCitizenId = getCitizenId(targetSource)
    end

    instance.state = state
    instance.targetCitizenId = targetCitizenId

    MySQL.update.await([[
        UPDATE ds_killer_instances
        SET state = ?, target_citizenid = ?, updated_at = CURRENT_TIMESTAMP
        WHERE instance_id = ?
    ]], { state, targetCitizenId, instanceId })

    logEncounter(instance, targetCitizenId or instance.ownerCitizenId, state, nil)
end)

RegisterNetEvent('ds_killers:server:killerDied', function(instanceId)
    local source = source
    local instance = instances[instanceId]
    if not instance or instance.owner ~= source then return end

    instance.state = 'DEAD'

    MySQL.update.await([[
        UPDATE ds_killer_instances
        SET state = 'DEAD', died_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
        WHERE instance_id = ?
    ]], { instanceId })

    logEncounter(instance, instance.targetCitizenId or instance.ownerCitizenId, 'KILLER_DIED', nil)
end)

RegisterCommand('dskiller', function(source, args)
    if not isAdmin(source) then
        sendMessage(source, 'Você não tem permissão darkside.admin.', 'error')
        return
    end

    local action = (args[1] or 'help'):lower()

    if action == 'spawn' then
        local killerId = (args[2] or 'hunter'):lower()
        local targetSource = source

        if source == 0 then
            targetSource = tonumber(args[3])
            if not targetSource then
                sendMessage(source, 'Console: dskiller spawn <killer> <playerId>')
                return
            end
        elseif args[3] then
            targetSource = tonumber(args[3]) or source
        end

        local ok, result = requestSpawn(targetSource, killerId, source)
        if ok then
            sendMessage(source, ('Spawn solicitado: %s (%s).'):format(killerId, result), 'success')
        else
            sendMessage(source, result, 'error')
        end
        return
    end

    if action == 'delete' then
        local instanceId = args[2]
        if not instanceId or not despawnInstance(instanceId, 'admin') then
            sendMessage(source, 'Instância não encontrada.', 'error')
            return
        end

        sendMessage(source, ('Instância %s removida.'):format(instanceId), 'success')
        return
    end

    if action == 'clear' then
        local toDelete = {}
        for instanceId, instance in pairs(instances) do
            if source == 0 or instance.owner == source or isAdmin(source) then
                toDelete[#toDelete + 1] = instanceId
            end
        end

        for _, instanceId in ipairs(toDelete) do
            despawnInstance(instanceId, 'clear')
        end

        sendMessage(source, ('%d killer(s) removido(s).'):format(#toDelete), 'success')
        return
    end

    if action == 'list' then
        local count = 0
        for instanceId, instance in pairs(instances) do
            count = count + 1
            sendMessage(source, ('%s | %s | owner=%s | state=%s | net=%s'):format(
                instanceId,
                instance.killerId,
                instance.owner,
                instance.state,
                tostring(instance.netId)
            ))
        end
        if count == 0 then sendMessage(source, 'Nenhum killer ativo.') end
        return
    end

    sendMessage(source, 'Uso: /dskiller spawn [killer] | /dskiller list | /dskiller delete <instance> | /dskiller clear')
end, false)

AddEventHandler('playerDropped', function()
    local source = source
    local toRemove = {}

    for instanceId, instance in pairs(instances) do
        if instance.owner == source then
            toRemove[#toRemove + 1] = instanceId
        end
    end

    for _, instanceId in ipairs(toRemove) do
        local instance = instances[instanceId]
        MySQL.update.await([[
            UPDATE ds_killer_instances
            SET state = 'ORPHANED', despawn_reason = 'owner_disconnected', despawned_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP
            WHERE instance_id = ?
        ]], { instanceId })
        instances[instanceId] = nil
    end
end)
