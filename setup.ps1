$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host 'DarkSide setup' -ForegroundColor Cyan
Write-Host '1/3 Instalando dependencias...' -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File '.\scripts\install-dependencies.ps1'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '2/3 Validando dependencias...' -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File '.\scripts\check-dependencies.ps1'
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '3/3 Preparando configuracao...' -ForegroundColor Cyan
if (-not (Test-Path -LiteralPath '.\server.cfg')) {
    Copy-Item -LiteralPath '.\server.cfg.example' -Destination '.\server.cfg'
    Write-Host 'server.cfg criado a partir do exemplo.' -ForegroundColor Green
}
else {
    Write-Host 'server.cfg ja existe; nao foi sobrescrito.' -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Setup concluido.' -ForegroundColor Green
Write-Host 'Agora configure mysql_connection_string e sv_licenseKey no server.cfg.' -ForegroundColor Yellow
