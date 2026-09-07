local RSGCore = exports['rsg-core']:GetCoreObject()

local function getCharacter(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return nil, nil end

    local citizenId = Player.PlayerData.citizenid
    if not citizenId then return nil, nil end

    local character = MySQL.single.await('SELECT * FROM ds_characters WHERE citizenid = ? LIMIT 1', { citizenId })
    return character, citizenId
end

lib.callback.register('ds_clans:server:list', function()
    return DarkSideClans
end)

lib.callback.register('ds_clans:server:getCurrent', function(source)
    local character = getCharacter(source)
    if not character or not character.clan_id then return nil end
    return DarkSideClans[character.clan_id]
end)

RegisterNetEvent('ds_clans:server:chooseClan', function(clanId)
    local src = source
    local clan = DarkSideClans[clanId]
    if not clan then return end

    local character, citizenId = getCharacter(src)
    if not character or not citizenId then return end

    -- Escolha inicial apenas. Troca de clã terá um sistema próprio posteriormente.
    if character.clan_id then
        TriggerClientEvent('ds_clans:client:chooseResult', src, false, 'Seu personagem já pertence a um clã.')
        return
    end

    MySQL.update.await([[
        UPDATE ds_characters
        SET clan_id = ?, clan_rank = 0
        WHERE citizenid = ? AND clan_id IS NULL
    ]], { clanId, citizenId })

    if clan.starterPower then
        MySQL.insert.await([[
            INSERT IGNORE INTO ds_player_powers (citizenid, power_id, level)
            VALUES (?, ?, 1)
        ]], { citizenId, clan.starterPower })
    end

    TriggerClientEvent('ds_clans:client:chooseResult', src, true, clan.label)
    TriggerClientEvent('ds:client:refreshCharacterState', src)
end)
