local controllers = {}

local function mergedProfile(profile)
    local result = {}

    for key, value in pairs(DarkSideAIConfig.DefaultProfile) do
        result[key] = value
    end

    if profile then
        for key, value in pairs(profile) do
            result[key] = value
        end
    end

    return result
end

local function getPedFromController(controller)
    if controller.ped and DoesEntityExist(controller.ped) then
        return controller.ped
    end

    local ped = NetworkGetEntityFromNetworkId(controller.netId)
    if ped and ped ~= 0 and DoesEntityExist(ped) then
        controller.ped = ped
        return ped
    end

    return nil
end

local function requestControl(entity)
    if NetworkHasControlOfEntity(entity) then return true end

    NetworkRequestControlOfEntity(entity)
    return NetworkHasControlOfEntity(entity)
end

local function notifyState(controller, state, targetPlayer)
    if not controller.instanceId then return end

    local targetServerId = nil
    if targetPlayer then
        targetServerId = GetPlayerServerId(targetPlayer)
    end

    TriggerServerEvent('ds_killers:server:aiStateChanged', controller.instanceId, state, targetServerId)
end

local function setState(controller, state, targetPlayer)
    if controller.state == state then return end

    controller.state = state
    controller.stateSince = GetGameTimer()
    notifyState(controller, state, targetPlayer)
end

local function findNearestVisiblePlayer(ped, detectionRange)
    local pedCoords = GetEntityCoords(ped)
    local nearestPlayer = nil
    local nearestPed = nil
    local nearestDistance = detectionRange + 0.01

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)

        if targetPed ~= ped and DoesEntityExist(targetPed) and not IsEntityDead(targetPed) then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - pedCoords)

            if distance <= detectionRange and distance < nearestDistance then
                local hasLos = HasEntityClearLosToEntity(ped, targetPed, 17)
                if hasLos then
                    nearestPlayer = player
                    nearestPed = targetPed
                    nearestDistance = distance
                end
            end
        end
    end

    return nearestPlayer, nearestPed, nearestDistance
end

local function findNearestAudiblePlayer(ped, profile)
    local pedCoords = GetEntityCoords(ped)
    local nearestPlayer = nil
    local nearestPed = nil
    local nearestDistance = math.huge
    local stimulus = nil

    for _, player in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(player)

        if targetPed ~= ped and DoesEntityExist(targetPed) and not IsEntityDead(targetPed) then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - pedCoords)
            local currentStimulus = nil
            local range = profile.hearingRange

            if IsPedShooting(targetPed) then
                currentStimulus = 'GUNSHOT'
                range = profile.gunshotRange
            elseif IsPedSprinting(targetPed) or IsPedRunning(targetPed) then
                currentStimulus = 'RUNNING'
                range = profile.runningRange
            elseif distance <= profile.hearingRange then
                currentStimulus = 'PRESENCE'
            end

            if currentStimulus and distance <= range and distance < nearestDistance then
                nearestPlayer = player
                nearestPed = targetPed
                nearestDistance = distance
                stimulus = currentStimulus
            end
        end
    end

    return nearestPlayer, nearestPed, nearestDistance, stimulus
end

local function beginCombat(controller, ped, targetPlayer, targetPed, distance)
    controller.targetPlayer = targetPlayer
    controller.targetPed = targetPed
    controller.lastKnownCoords = GetEntityCoords(targetPed)
    controller.lastSeenAt = GetGameTimer()
    controller.lastStimulusAt = GetGameTimer()

    requestControl(ped)
    TaskCombatPed(ped, targetPed, 0, 16)

    if distance <= controller.profile.attackRange then
        setState(controller, 'ATTACK', targetPlayer)
    else
        setState(controller, 'CHASE', targetPlayer)
    end
end

local function beginInvestigate(controller, ped, targetPlayer, targetPed, stimulus)
    controller.targetPlayer = nil
    controller.targetPed = nil
    controller.lastKnownCoords = GetEntityCoords(targetPed)
    controller.lastStimulusAt = GetGameTimer()
    controller.lastStimulus = stimulus

    requestControl(ped)
    ClearPedTasks(ped)

    local coords = controller.lastKnownCoords
    TaskGoStraightToCoord(
        ped,
        coords.x,
        coords.y,
        coords.z,
        controller.profile.investigateSpeed,
        -1,
        0.0,
        0.0
    )

    setState(controller, 'INVESTIGATE', targetPlayer)
end

local function beginSearch(controller, ped)
    controller.targetPlayer = nil
    controller.targetPed = nil

    requestControl(ped)
    ClearPedTasks(ped)

    if controller.lastKnownCoords then
        local coords = controller.lastKnownCoords
        TaskGoStraightToCoord(ped, coords.x, coords.y, coords.z, controller.profile.moveSpeed, -1, 0.0, 0.0)
    end

    setState(controller, 'SEARCH')
end

local function refreshInvestigation(controller, ped, targetPed, stimulus)
    controller.lastKnownCoords = GetEntityCoords(targetPed)
    controller.lastStimulusAt = GetGameTimer()
    controller.lastStimulus = stimulus

    requestControl(ped)
    ClearPedTasks(ped)

    local coords = controller.lastKnownCoords
    TaskGoStraightToCoord(
        ped,
        coords.x,
        coords.y,
        coords.z,
        controller.profile.investigateSpeed,
        -1,
        0.0,
        0.0
    )
end

local function updateController(controller)
    local ped = getPedFromController(controller)
    if not ped then return false end

    if IsEntityDead(ped) then
        if not controller.deathReported and controller.instanceId then
            controller.deathReported = true
            TriggerServerEvent('ds_killers:server:killerDied', controller.instanceId)
        end
        return true
    end

    if controller.state == 'IDLE' then
        local targetPlayer, targetPed, distance = findNearestVisiblePlayer(ped, controller.profile.detectionRange)
        if targetPed then
            beginCombat(controller, ped, targetPlayer, targetPed, distance)
            return true
        end

        local heardPlayer, heardPed, _, stimulus = findNearestAudiblePlayer(ped, controller.profile)
        if heardPed then
            beginInvestigate(controller, ped, heardPlayer, heardPed, stimulus)
        end
        return true
    end

    if controller.state == 'INVESTIGATE' then
        local targetPlayer, targetPed, distance = findNearestVisiblePlayer(ped, controller.profile.detectionRange)
        if targetPed then
            beginCombat(controller, ped, targetPlayer, targetPed, distance)
            return true
        end

        local heardPlayer, heardPed, _, stimulus = findNearestAudiblePlayer(ped, controller.profile)
        if heardPed then
            refreshInvestigation(controller, ped, heardPed, stimulus)
            notifyState(controller, 'INVESTIGATE', heardPlayer)
            return true
        end

        if GetGameTimer() - controller.lastStimulusAt >= controller.profile.investigateDuration then
            beginSearch(controller, ped)
        end

        return true
    end

    if controller.state == 'CHASE' or controller.state == 'ATTACK' then
        local targetPlayer = controller.targetPlayer
        local targetPed = controller.targetPed

        if not targetPlayer or not targetPed or not DoesEntityExist(targetPed) or IsEntityDead(targetPed) then
            beginSearch(controller, ped)
            return true
        end

        local pedCoords = GetEntityCoords(ped)
        local targetCoords = GetEntityCoords(targetPed)
        local distance = #(targetCoords - pedCoords)
        local hasLos = HasEntityClearLosToEntity(ped, targetPed, 17)

        if hasLos then
            controller.lastKnownCoords = targetCoords
            controller.lastSeenAt = GetGameTimer()
        end

        if distance > controller.profile.loseRange or (not hasLos and GetGameTimer() - controller.lastSeenAt > 2500) then
            beginSearch(controller, ped)
            return true
        end

        if controller.state == 'CHASE' and distance <= controller.profile.attackRange then
            setState(controller, 'ATTACK', targetPlayer)
        elseif controller.state == 'ATTACK' and distance > controller.profile.attackRange * 1.8 then
            setState(controller, 'CHASE', targetPlayer)
        end

        return true
    end

    if controller.state == 'SEARCH' then
        local targetPlayer, targetPed, distance = findNearestVisiblePlayer(ped, controller.profile.detectionRange)
        if targetPed then
            beginCombat(controller, ped, targetPlayer, targetPed, distance)
            return true
        end

        local heardPlayer, heardPed, _, stimulus = findNearestAudiblePlayer(ped, controller.profile)
        if heardPed then
            beginInvestigate(controller, ped, heardPlayer, heardPed, stimulus)
            return true
        end

        if GetGameTimer() - controller.stateSince >= controller.profile.searchDuration then
            requestControl(ped)
            ClearPedTasks(ped)
            controller.lastKnownCoords = nil
            setState(controller, 'IDLE')
        end

        return true
    end

    setState(controller, 'IDLE')
    return true
end

exports('RegisterPed', function(netId, profile, instanceId)
    if type(netId) ~= 'number' or netId <= 0 then
        return false, 'invalid_net_id'
    end

    controllers[netId] = {
        netId = netId,
        instanceId = instanceId,
        profile = mergedProfile(profile),
        state = 'IDLE',
        stateSince = GetGameTimer(),
        lastSeenAt = 0,
        lastStimulusAt = 0,
        lastStimulus = nil,
        deathReported = false
    }

    return true
end)

exports('UnregisterPed', function(netId)
    controllers[netId] = nil
    return true
end)

exports('GetState', function(netId)
    local controller = controllers[netId]
    return controller and controller.state or nil
end)

CreateThread(function()
    while true do
        Wait(DarkSideAIConfig.ThinkInterval)

        for netId, controller in pairs(controllers) do
            local exists = updateController(controller)
            if not exists then
                controllers[netId] = nil
            end
        end
    end
end)
