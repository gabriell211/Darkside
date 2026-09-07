DarkSide = DarkSide or {}
DarkSide.Version = '0.1.0'

local function log(level, message)
    print(('[DarkSide][%s] %s'):format(level, message))
end

function DarkSide.Info(message)
    log('INFO', message)
end

function DarkSide.Warn(message)
    log('WARN', message)
end

function DarkSide.Debug(message)
    if DarkSideConfig.Debug then
        log('DEBUG', message)
    end
end
