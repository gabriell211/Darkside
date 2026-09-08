local voiceState = {
    mode = 2,
    distance = 0.0,
    name = 'Normal',
    talking = false
}

local function copyState()
    return {
        mode = voiceState.mode,
        distance = voiceState.distance,
        name = voiceState.name,
        talking = voiceState.talking
    }
end

local function refreshProximity()
    local proximity = LocalPlayer and LocalPlayer.state and LocalPlayer.state.proximity or nil
    if type(proximity) ~= 'table' then return false end

    local changed = false

    local mode = tonumber(proximity.index)
    if mode and mode ~= voiceState.mode then
        voiceState.mode = mode
        changed = true
    end

    local distance = tonumber(proximity.distance)
    if distance and distance ~= voiceState.distance then
        voiceState.distance = distance
        changed = true
    end

    local name = proximity.name or proximity.modeName
    if not name and type(proximity.mode) == 'string' then
        name = proximity.mode
    end

    if name and name ~= voiceState.name then
        voiceState.name = name
        changed = true
    end

    return changed
end

local function emitStateChanged(reason)
    TriggerEvent('ds_voice:client:stateChanged', copyState(), reason or 'update')
end

RegisterNetEvent('pma-voice:setTalkingMode', function(mode)
    local parsed = tonumber(mode)
    if parsed then
        voiceState.mode = parsed
    end

    refreshProximity()
    emitStateChanged('mode')
end)

CreateThread(function()
    Wait(1500)
    refreshProximity()
    emitStateChanged('ready')

    while true do
        Wait(200)

        local changed = refreshProximity()
        local talking = MumbleIsPlayerTalking(PlayerId()) == 1

        if talking ~= voiceState.talking then
            voiceState.talking = talking
            changed = true
            TriggerEvent('ds_voice:client:talkingChanged', talking, copyState())
        end

        if changed then
            emitStateChanged('poll')
        end
    end
end)

exports('GetState', function()
    refreshProximity()
    return copyState()
end)

exports('GetMode', function()
    refreshProximity()
    return voiceState.mode, voiceState.distance, voiceState.name
end)

exports('IsTalking', function()
    return MumbleIsPlayerTalking(PlayerId()) == 1
end)
