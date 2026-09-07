local RSGCore = exports['rsg-core']:GetCoreObject()

DarkSide.Info(('ds_core server started v%s'):format(DarkSide.Version))

local function ensureDarkSideCharacter(src)
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenId = Player.PlayerData.citizenid
    if not citizenId then return end

    MySQL.insert.await([[
        INSERT INTO ds_characters (citizenid, energy, max_energy)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE citizenid = VALUES(citizenid)
    ]], {
        citizenId,
        DarkSideConfig.StartingEnergy,
        DarkSideConfig.MaxEnergy
    })
end

RegisterNetEvent('RSGCore:Server:OnPlayerLoaded', function()
    ensureDarkSideCharacter(source)
end)

lib.callback.register('ds_core:server:getCharacterState', function(source)
    local Player = RSGCore.Functions.GetPlayer(source)
    if not Player then return nil end

    local citizenId = Player.PlayerData.citizenid
    if not citizenId then return nil end

    return MySQL.single.await([[
        SELECT citizenid, clan_id, clan_rank, level, xp, energy, max_energy
        FROM ds_characters
        WHERE citizenid = ?
        LIMIT 1
    ]], { citizenId })
end)

exports('GetRSGCore', function()
    return RSGCore
end)
