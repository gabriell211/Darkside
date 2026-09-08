$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$Required = @(
    @{ Name = 'ox_lib'; Path = 'resources\[standalone]\ox_lib\fxmanifest.lua' },
    @{ Name = 'oxmysql'; Path = 'resources\[standalone]\oxmysql\fxmanifest.lua' },
    @{ Name = 'pma-voice'; Path = 'resources\[voice]\pma-voice\fxmanifest.lua' },
    @{ Name = 'rsg-core'; Path = 'resources\[rsg]\rsg-core\fxmanifest.lua' },
    @{ Name = 'rsg-menubase'; Path = 'resources\[rsg]\rsg-menubase\fxmanifest.lua' },
    @{ Name = 'rsg-inventory'; Path = 'resources\[rsg]\rsg-inventory\fxmanifest.lua' },
    @{ Name = 'rsg-appearance'; Path = 'resources\[rsg]\rsg-appearance\fxmanifest.lua' },
    @{ Name = 'ds_core'; Path = 'resources\[darkside]\ds_core\fxmanifest.lua' },
    @{ Name = 'ds_clans'; Path = 'resources\[darkside]\ds_clans\fxmanifest.lua' },
    @{ Name = 'ds_powers'; Path = 'resources\[darkside]\ds_powers\fxmanifest.lua' },
    @{ Name = 'ds_ai'; Path = 'resources\[darkside]\ds_ai\fxmanifest.lua' },
    @{ Name = 'ds_killers'; Path = 'resources\[darkside]\ds_killers\fxmanifest.lua' },
    @{ Name = 'ds_horror'; Path = 'resources\[darkside]\ds_horror\fxmanifest.lua' }
)

$Failed = $false

Write-Host 'DarkSide - verificacao de dependencias' -ForegroundColor Cyan
Write-Host ''

foreach ($Dependency in $Required) {
    $FullPath = Join-Path $Root $Dependency.Path

    if (Test-Path -LiteralPath $FullPath) {
        Write-Host ("[OK]   {0}" -f $Dependency.Name) -ForegroundColor Green
    }
    else {
        Write-Host ("[FAIL] {0} - faltando {1}" -f $Dependency.Name, $Dependency.Path) -ForegroundColor Red
        $Failed = $true
    }
}

Write-Host ''

if ($Failed) {
    Write-Host 'Existem dependencias faltando. Rode:' -ForegroundColor Yellow
    Write-Host 'powershell -ExecutionPolicy Bypass -File .\scripts\install-dependencies.ps1' -ForegroundColor Yellow
    exit 1
}

Write-Host 'Base minima pronta para inicializacao.' -ForegroundColor Green
exit 0
