RegisterNetEvent('ds_clans:client:chooseResult', function(success, message)
    if success then
        lib.notify({
            title = 'DarkSide',
            description = ('Clã escolhido: %s'):format(message),
            type = 'success'
        })
    else
        lib.notify({
            title = 'DarkSide',
            description = message or 'Não foi possível escolher o clã.',
            type = 'error'
        })
    end
end)

RegisterCommand('dsclans', function()
    local clans = lib.callback.await('ds_clans:server:list', false)
    if not clans then return end

    print('^5[DarkSide]^7 Clãs disponíveis:')
    for id, clan in pairs(clans) do
        print(('  %s -> %s'):format(id, clan.label))
    end
end, false)

RegisterCommand('dschoose', function(_, args)
    local clanId = args[1]
    if not clanId then
        lib.notify({
            title = 'DarkSide',
            description = 'Use /dschoose darkside ou /dschoose fallen_angels',
            type = 'inform'
        })
        return
    end

    TriggerServerEvent('ds_clans:server:chooseClan', clanId)
end, false)
