local RSGCore = exports['rsg-core']:GetCoreObject()
local lastEventAt = {}

local allowedEvents = {
    ZONE_ENTER = true,
    ZONE_EXIT = true,
    EFFECT = true,
    TEST_STARTED = true,
    TEST_STOPPED = true
}

local allowedEffects = {
    camera_pulse = true,
    native_stinger = true,
    vision_distortion = true,
    presence = true
}

local function getCitizenId(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    return Player and Player.PlayerData and Player.PlayerData.citizenid or nil
end

local function isAdmin(source)
    return source == 0 or IsPlayerAceAllowed(source, DarkSideHorrorConfig.AdminAce)
end

local function notify(source, message, notificationType)
    if source == 0 then
        print(('[DarkSide][Horror] %s'):format(message))
        return
    end

    TriggerClientEvent('ds_horror:client:message', source, message, notificationType or 'inform')
end

local function safeString(value, maxLength)
    if type(value) ~= 'string' then return nil end
    value = value:gsub('[^%w_%-:]', '')
    if #value == 0 then return nil end
    return value:sub(1, maxLength)
end

local function safeCoords(coords)
    if type(coords) ~= 'table' then return nil end
    local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    if not x or not y or not z then return nil end

    return {
        x = math.floor(x * 1000 + 0.5) / 1000,
        y = math.floor(y * 1000 + 0.5) / 1000,
        z = math.floor(z * 1000 + 0.5) / 1000
    }
end

local function persistEvent(source, zoneId, eventType, effectId, intensity, coords)
    if not DarkSideHorrorConfig.PersistEvents then return end

    local citizenId = getCitizenId(source)
    local normalizedIntensity = math.max(0.0, math.min(1.0, tonumber(intensity) or 0.0))

    MySQL.insert.await([[
        INSERT INTO ds_horror_events
            (citizenid, zone_id, event_type, effect_id, intensity, coords)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], {
        citizenId,
        zoneId,
        eventType,
        effectId,
        normalizedIntensity,
        coords and json.encode(coords) or nil
    })
end

RegisterNetEvent('ds_horror:server:event', function(zoneId, eventType, effectId, intensity, coords)
    local source = source
    local now = GetGameTimer()

    -- Event logging is client-triggered, so keep it bounded and validate every field.
    if lastEventAt[source] and now - lastEventAt[source] < 400 then return end
    lastEventAt[source] = now

    zoneId = safeString(zoneId, 64)
    eventType = safeString(eventType, 32)
    effectId = effectId and safeString(effectId, 64) or nil

    if not zoneId or not eventType or not allowedEvents[eventType] then return end
    if effectId and not allowedEffects[effectId] then return end

    local normalizedCoords = safeCoords(coords)
    persistEvent(source, zoneId, eventType, effectId, intensity, normalizedCoords)
end)

RegisterCommand('dshorror', function(source, args)
    if not isAdmin(source) then
        notify(source, 'Você não tem permissão darkside.admin.', 'error')
        return
    end

    local action = (args[1] or 'help'):lower()

    if action == 'test' then
        if source == 0 then
            notify(source, 'Use este comando dentro do RedM: /dshorror test [segundos]')
            return
        end

        local duration = math.max(30, math.min(1800, tonumber(args[2]) or DarkSideHorrorConfig.TestZoneDuration))
        TriggerClientEvent('ds_horror:client:startTest', source, duration)
        persistEvent(source, 'admin_test', 'TEST_STARTED', nil, 0.45, nil)
        return
    end

    if action == 'stop' then
        if source == 0 then
            notify(source, 'O teste é local ao player e precisa ser encerrado dentro do RedM.')
            return
        end

        TriggerClientEvent('ds_horror:client:stopTest', source)
        persistEvent(source, 'admin_test', 'TEST_STOPPED', nil, 0.0, nil)
        return
    end

    notify(source, 'Uso: /dshorror test [segundos] | /dshorror stop')
end, false)

AddEventHandler('playerDropped', function()
    lastEventAt[source] = nil
end)

print('[DarkSide][Horror] ds_horror server started')
