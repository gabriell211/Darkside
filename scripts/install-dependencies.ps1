param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$StandaloneDir = Join-Path $Root 'resources\[standalone]'
$VoiceDir = Join-Path $Root 'resources\[voice]'
$RsgDir = Join-Path $Root 'resources\[rsg]'
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('darkside-deps-' + [guid]::NewGuid().ToString('N'))

New-Item -ItemType Directory -Force -Path $StandaloneDir | Out-Null
New-Item -ItemType Directory -Force -Path $VoiceDir | Out-Null
New-Item -ItemType Directory -Force -Path $RsgDir | Out-Null
New-Item -ItemType Directory -Force -Path $TempRoot | Out-Null

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Comando '$Name' nao encontrado. Instale-o antes de continuar."
    }
}

function Prepare-Target {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (Test-Path -LiteralPath $Path) {
        if (-not $Force) {
            Write-Host "[SKIP] $Path ja existe. Use -Force para reinstalar." -ForegroundColor Yellow
            return $false
        }

        Write-Host "[REMOVE] $Path" -ForegroundColor DarkYellow
        Remove-Item -LiteralPath $Path -Recurse -Force
    }

    return $true
}

function Install-ReleaseZip {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Target
    )

    if (-not (Prepare-Target -Path $Target)) { return }

    $zip = Join-Path $TempRoot "$Name.zip"
    $extract = Join-Path $TempRoot "$Name-extract"

    Write-Host "[DOWNLOAD] $Name" -ForegroundColor Cyan
    Invoke-WebRequest -Uri $Url -OutFile $zip -UseBasicParsing
    Expand-Archive -LiteralPath $zip -DestinationPath $extract -Force

    $nested = Join-Path $extract $Name
    if (Test-Path -LiteralPath $nested) {
        Move-Item -LiteralPath $nested -Destination $Target
    }
    else {
        New-Item -ItemType Directory -Force -Path $Target | Out-Null
        Get-ChildItem -LiteralPath $extract -Force | ForEach-Object {
            Move-Item -LiteralPath $_.FullName -Destination $Target
        }
    }

    Write-Host "[OK] $Name -> $Target" -ForegroundColor Green
}

function Install-GitDependency {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Repository,
        [Parameter(Mandatory = $true)][string]$Target,
        [string]$Branch = 'main',
        [string]$Commit = ''
    )

    if (-not (Prepare-Target -Path $Target)) { return }

    Write-Host "[CLONE] $Name" -ForegroundColor Cyan
    git clone --depth 1 --branch $Branch $Repository $Target

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao clonar $Name."
    }

    if ($Commit) {
        Write-Host "[PIN] $Name -> $Commit" -ForegroundColor DarkCyan
        git -C $Target checkout --detach $Commit
        if ($LASTEXITCODE -ne 0) {
            throw "Falha ao fixar $Name no commit $Commit."
        }
    }

    # As dependencias ficam vendorizadas no repositorio DarkSide, sem repositorios Git aninhados.
    $nestedGit = Join-Path $Target '.git'
    if (Test-Path -LiteralPath $nestedGit) {
        Remove-Item -LiteralPath $nestedGit -Recurse -Force
    }

    Write-Host "[OK] $Name -> $Target" -ForegroundColor Green
}

try {
    Assert-Command -Name 'git'

    # Releases prontas para runtime. O source puro do ox_lib/oxmysql pode exigir build.
    Install-ReleaseZip -Name 'ox_lib' `
        -Url 'https://github.com/overextended/ox_lib/releases/download/v3.39.0/ox_lib.zip' `
        -Target (Join-Path $StandaloneDir 'ox_lib')

    Install-ReleaseZip -Name 'oxmysql' `
        -Url 'https://github.com/overextended/oxmysql/releases/download/v2.14.1/oxmysql.zip' `
        -Target (Join-Path $StandaloneDir 'oxmysql')

    # Voz. A BaseReborn inclui uma copia antiga do pma-voice com manifest gta5.
    # Para DarkSide usamos o upstream atual, da mesma familia PMA, pois este possui suporte explicito a RedM.
    Install-GitDependency -Name 'pma-voice' `
        -Repository 'https://github.com/AvarianKnight/pma-voice.git' `
        -Target (Join-Path $VoiceDir 'pma-voice') `
        -Commit '6c9d96ed7a02e30912f1a0ce92629bf9afbbca8c'

    # Base RedM/RSG.
    Install-GitDependency -Name 'rsg-core' `
        -Repository 'https://github.com/Rexshack-RedM/rsg-core.git' `
        -Target (Join-Path $RsgDir 'rsg-core')

    Install-GitDependency -Name 'rsg-menubase' `
        -Repository 'https://github.com/Rexshack-RedM/rsg-menubase.git' `
        -Target (Join-Path $RsgDir 'rsg-menubase')

    Install-GitDependency -Name 'rsg-inventory' `
        -Repository 'https://github.com/Rexshack-RedM/rsg-inventory.git' `
        -Target (Join-Path $RsgDir 'rsg-inventory')

    Install-GitDependency -Name 'rsg-appearance' `
        -Repository 'https://github.com/Rexshack-RedM/rsg-appearance.git' `
        -Target (Join-Path $RsgDir 'rsg-appearance')

    Write-Host ''
    Write-Host 'Dependencias DarkSide instaladas.' -ForegroundColor Green
    Write-Host 'Proximo passo: execute scripts\check-dependencies.ps1 e depois configure server.cfg.' -ForegroundColor Green
}
finally {
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
