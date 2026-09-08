local temporaryZone = nil
local activeZone = nil
local enteredAt = 0
local nextEventAt = 0
local activePostFx = nil

local function debugLog(message)
    if DarkSideHorrorConfig.Debug then
        print(('[DarkSide][Horror][Client] %s'):format(message))
    end
end

local function randomDelay()
    return math.random(DarkSideHorrorConfig.MinEventDelay, DarkSideHorrorConfig.MaxEventDelay)
end

local function normalizeZone(zone)
    return {
        id = zone.id,
        label = zone.label or zone.id,
        enabled = zone.enabled ~= false,
        coords = zone.coords,
        radius = tonumber(zone.radius) or 100.0,
        baseIntensity = math.max(0.0, math.min(1.0, tonumber(zone.baseIntensity) or 0.15)),
        maxIntensity = math.max(0.0, math.min(1.0, tonumber(zone.maxIntensity) or DarkSideHorrorConfig.MaxIntensity)),
        expiresAt = zone.expiresAt
    }
end

local function zoneIntensity(zone)
    if not zone then return 0.0 end

    local elapsedSeconds = math.max(0, (GetGameTimer() - enteredAt) / 1000.0)
    local value = zone.baseIntensity + (elapsedSeconds * DarkSideHorrorConfig.IntensityRampPerSecond)
    return math.min(zone.maxIntensity, DarkSideHorrorConfig.MaxIntensity, value)
end

local function stopTransientEffects()
    if activePostFx then
        AnimpostfxStop(activePostFx)
        activePostFx = nil
    end
end

local function report(eventType, effectId, intensity)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    TriggerServerEvent('ds_horror:server:event',
        activeZone and activeZone.id or 'none',
        eventType,
        effectId,
        intensity or 0.0,
        { x = coords.x, y = coords.y, z = coords.z }
    )
end

local function enterZone(zone)
    stopTransientEffects()
    activeZone = normalizeZone(zone)
    enteredAt = GetGameTimer()
    nextEventAt = enteredAt + randomDelay()

    debugLog(('entered zone %s'):format(activeZone.id))
    report('ZONE_ENTER', nil, activeZone.baseIntensity)

    TriggerEvent('ds_horror:client:zoneEntered', activeZone.id, activeZone)
end

local function leaveZone()
    if not activeZone then return end

    local previous = activeZone
    report('ZONE_EXIT', nil, zoneIntensity(previous))
    stopTransientEffects()

    activeZone = nil
    enteredAt = 0
    nextEventAt = 0

    TriggerEvent('ds_horror:client:zoneExited', previous.id, previous)
    debugLog(('left zone %s'):format(previous.id))
end

local function chooseEffect(intensity)
    local eligible = {}
    local totalWeight = 0

    for _, effect in ipairs(DarkSideHorrorConfig.Effects) do
        if intensity >= (effect.minIntensity or 0.0) then
            local weight = math.max(1, tonumber(effect.weight) or 1)
            totalWeight = totalWeight + weight
            eligible[#eligible + 1] = { effect = effect, ceiling = totalWeight }
        end
    end

    if totalWeight == 0 then return nil end

    local roll = math.random(1, totalWeight)
    for _, entry in ipairs(eligible) do
        if roll <= entry.ceiling then
            return entry.effect
        end
    end

    return eligible[#eligible] and eligible[#eligible].effect or nil
end

local function effectCameraPulse(intensity)
    local amplitude = 0.05 + (intensity * 0.25)
    ShakeGameplayCam('DRUNK_SHAKE', amplitude)
    Wait(650)
end

local function effectNativeStinger(intensity)
    if intensity >= 0.6 then
        PlaySoundFrontend('BACK', 'RDRO_Character_Creator_Sounds', true, 0)
        Wait(220)
        PlaySoundFrontend('SELECT', 'RDRO_Character_Creator_Sounds', true, 0)
    else
        PlaySoundFrontend('SELECT', 'RDRO_Character_Creator_Sounds', true, 0)
    end
end

local function effectVisionDistortion(intensity)
    local effect = 'l_00078a17dm'
    activePostFx = effect
    AnimpostfxPlay(effect)
    ShakeGameplayCam('DRUNK_SHAKE', 0.08 + (intensity * 0.15))
    Wait(math.floor(700 + (intensity * 1100)))
    AnimpostfxStop(effect)
    if activePostFx == effect then activePostFx = nil end
end

local function effectPresence(intensity)
    -- Placeholder para futura aparição/entidade. Usa apenas natives já comuns em RedM
    -- e não depende de ped GTA/FiveM ou asset de terceiros.
    PlaySoundFrontend('BACK', 'RDRO_Character_Creator_Sounds', true, 0)
    ShakeGameplayCam('DRUNK_SHAKE', 0.12 + (intensity * 0.2))
    DoScreenFadeOut(120)
    Wait(150)
    DoScreenFadeIn(220)
end

local effectHandlers = {
    camera_pulse = effectCameraPulse,
    native_stinger = effectNativeStinger,
    vision_distortion = effectVisionDistortion,
    presence = effectPresence
}

local function runEffect(effect, intensity)
    if not effect then return end

    local handler = effectHandlers[effect.id]
    if not handler then return end

    CreateThread(function()
        local ok, err = pcall(handler, intensity)
        if not ok then
            print(('[DarkSide][Horror] effect %s failed: %s'):format(effect.id, tostring(err)))
        end
    end)

    report('EFFECT', effect.id, intensity)
    TriggerEvent('ds_horror:client:effect', effect.id, intensity, activeZone and activeZone.id or nil)
end

local function findCurrentZone(coords)
    if temporaryZone then
        if temporaryZone.expiresAt and GetGameTimer() >= temporaryZone.expiresAt then
            temporaryZone = nil
        elseif #(coords - temporaryZone.coords) <= temporaryZone.radius then
            return temporaryZone
        end
    end

    for _, zone in ipairs(DarkSideHorrorZones) do
        if zone.enabled ~= false and zone.coords and #(coords - zone.coords) <= (zone.radius or 100.0) then
            return zone
        end
    end

    return nil
end

RegisterNetEvent('ds_horror:client:startTest', function(durationSeconds)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local duration = math.max(30, math.min(1800, tonumber(durationSeconds) or DarkSideHorrorConfig.TestZoneDuration))

    temporaryZone = normalizeZone({
        id = 'admin_test',
        label = 'DarkSide Horror Test',
        enabled = true,
        coords = coords,
        radius = DarkSideHorrorConfig.TestZoneRadius,
        baseIntensity = 0.45,
        maxIntensity = 1.0,
        expiresAt = GetGameTimer() + (duration * 1000)
    })

    lib.notify({
        title = 'DarkSide Horror',
        description = ('Zona de teste criada por %ds ao redor da sua posição.'):format(duration),
        type = 'success'
    })
end)

RegisterNetEvent('ds_horror:client:stopTest', function()
    temporaryZone = nil
    if activeZone and activeZone.id == 'admin_test' then
        leaveZone()
    end

    lib.notify({
        title = 'DarkSide Horror',
        description = 'Zona de teste encerrada.',
        type = 'inform'
    })
end)

RegisterNetEvent('ds_horror:client:message', function(message, notificationType)
    lib.notify({
        title = 'DarkSide Horror',
        description = message,
        type = notificationType or 'inform'
    })
end)

CreateThread(function()
    while true do
        Wait(DarkSideHorrorConfig.ScanInterval)

        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            local coords = GetEntityCoords(ped)
            local zone = findCurrentZone(coords)

            if zone and (not activeZone or activeZone.id ~= zone.id) then
                if activeZone then leaveZone() end
                enterZone(zone)
            elseif not zone and activeZone then
                leaveZone()
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(DarkSideHorrorConfig.EventCheckInterval)

        if activeZone and GetGameTimer() >= nextEventAt then
            local intensity = zoneIntensity(activeZone)
            local effect = chooseEffect(intensity)
            runEffect(effect, intensity)

            local intensityMultiplier = math.max(0.45, 1.15 - intensity)
            nextEventAt = GetGameTimer() + math.floor(randomDelay() * intensityMultiplier)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    stopTransientEffects()
end)
