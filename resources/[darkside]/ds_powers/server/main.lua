local RSGCore = exports['rsg-core']:GetCoreObject()
local cooldowns = {}

local function nowMs()
    return os.time() * 1000
end

local function getCharacter(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return nil, nil end

    local citizenId = Player.PlayerData.citizenid
    if not citizenId then return nil, nil end

    local character = MySQL.single.await([[
        SELECT citizenid, clan_id, energy, max_energy
        FROM ds_characters
        WHERE citizenid = ?
        LIMIT 1
    ]], { citizenId })

    return character, citizenId
end

RegisterNetEvent('ds_powers:server:use', function(powerId)
    local src = source
    local power = DarkSidePowers[powerId]
    if not power then return end

    local character, citizenId = getCharacter(src)
    if not character or not citizenId then return end
    if character.clan_id ~= power.clan then return end

    local unlocked = MySQL.scalar.await([[
        SELECT 1
        FROM ds_player_powers
        WHERE citizenid = ? AND power_id = ?
        LIMIT 1
    ]], { citizenId, powerId })

    if not unlocked then return end

    cooldowns[citizenId] = cooldowns[citizenId] or {}
    local expiresAt = cooldowns[citizenId][powerId] or 0
    local current = nowMs()
    if expiresAt > current then
        TriggerClientEvent('ds_powers:client:result', src, false, 'Poder em recarga.')
        return
    end

    if character.energy < power.energyCost then
        TriggerClientEvent('ds_powers:client:result', src, false, 'Energia insuficiente.')
        return
    end

    local changed = MySQL.update.await([[
        UPDATE ds_characters
        SET energy = energy - ?
        WHERE citizenid = ? AND energy >= ?
    ]], { power.energyCost, citizenId, power.energyCost })

    if not changed or changed < 1 then return end

    cooldowns[citizenId][powerId] = current + power.cooldownMs

    TriggerClientEvent('ds_powers:client:execute', src, powerId, power)
    TriggerClientEvent('ds:client:refreshCharacterState', src)
end)

AddEventHandler('playerDropped', function()
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player and Player.PlayerData.citizenid then
        cooldowns[Player.PlayerData.citizenid] = nil
    end
end)
