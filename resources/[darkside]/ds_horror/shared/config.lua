DarkSideHorrorConfig = {
    Debug = false,
    ScanInterval = 750,
    EventCheckInterval = 500,
    MinEventDelay = 7000,
    MaxEventDelay = 16000,
    IntensityRampPerSecond = 0.006,
    MaxIntensity = 1.0,
    PersistEvents = true,
    AdminAce = 'darkside.admin',
    TestZoneRadius = 120.0,
    TestZoneDuration = 300,

    -- Efeitos iniciais usam apenas natives do RedM para o protótipo.
    -- Áudio .ogg/NUI e partículas próprias entram em ds_audio/ds_entities depois.
    Effects = {
        {
            id = 'camera_pulse',
            minIntensity = 0.15,
            weight = 30
        },
        {
            id = 'native_stinger',
            minIntensity = 0.10,
            weight = 35
        },
        {
            id = 'vision_distortion',
            minIntensity = 0.35,
            weight = 20
        },
        {
            id = 'presence',
            minIntensity = 0.55,
            weight = 15
        }
    }
}

-- O mapa final ainda não foi fechado. As zonas permanentes entram aqui quando
-- escolhermos as regiões DarkSide. O comando /dshorror test cria uma zona temporária
-- ao redor do admin para validar o sistema sem comprometer a geografia do jogo.
DarkSideHorrorZones = {
    -- Exemplo:
    -- {
    --     id = 'haunted_forest',
    --     label = 'Floresta Assombrada',
    --     enabled = true,
    --     coords = vector3(0.0, 0.0, 0.0),
    --     radius = 180.0,
    --     baseIntensity = 0.20,
    --     maxIntensity = 0.90
    -- }
}
