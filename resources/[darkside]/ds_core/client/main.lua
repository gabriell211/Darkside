local RSGCore = exports['rsg-core']:GetCoreObject()

local state = {
    loaded = false,
    character = nil
}

local function refreshCharacterState()
    local data = lib.callback.await('ds_core:server:getCharacterState', false)
    state.character = data
    state.loaded = data ~= nil

    if DarkSideConfig.Debug and data then
        DarkSide.Debug(('character loaded: clan=%s level=%s'):format(data.clan_id or 'none', data.level or 1))
    end

    TriggerEvent('ds:client:characterStateUpdated', data)
end

RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    Wait(1000)
    refreshCharacterState()
end)

RegisterNetEvent('RSGCore:Client:OnPlayerUnload', function()
    state.loaded = false
    state.character = nil
    TriggerEvent('ds:client:characterStateUpdated', nil)
end)

RegisterNetEvent('ds:client:refreshCharacterState', function()
    refreshCharacterState()
end)

exports('GetDarkSideState', function()
    return state
end)
