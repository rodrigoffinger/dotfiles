# Funcoes compartilhadas dos scripts de setup do Windows.
# Espelha scripts/wsl-debian/common.sh.

$ErrorActionPreference = 'Stop'

function Info { param([string]$Message) Write-Host "[info] $Message" -ForegroundColor Cyan }
function Warn { param([string]$Message) Write-Host "[warn] $Message" -ForegroundColor Yellow }
function Die  { param([string]$Message) Write-Host "[error] $Message" -ForegroundColor Red; exit 1 }

function Test-Command {
    param([Parameter(Mandatory)][string]$Name)
    [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-RepoRoot {
    (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
}

# $env:OneDrive pode ser o corporativo. Os dotfiles vivem no pessoal.
function Get-OneDrivePersonal {
    if ($env:OneDriveConsumer) { return $env:OneDriveConsumer }
    $fallback = Join-Path $env:USERPROFILE 'OneDrive'
    if (Test-Path $fallback) { return $fallback }
    return $null
}

# True quando a pasta Documentos aponta para dentro do OneDrive.
# Quando e false, o profile compartilhado precisa do shim.
function Test-DocumentsRedirected {
    $docs = [Environment]::GetFolderPath('MyDocuments')
    $oneDrive = Get-OneDrivePersonal
    if (-not $oneDrive) { return $false }
    return $docs.StartsWith($oneDrive, [StringComparison]::OrdinalIgnoreCase)
}

function Backup-Path {
    param([Parameter(Mandatory)][string]$Path)
    if (Test-Path $Path) {
        $stamp  = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = "$Path.bak-$stamp"
        Move-Item -LiteralPath $Path -Destination $backup -Force
        Info "Backup criado: $backup"
    }
}

# O winget instala o Oh My Posh como pacote MSIX, entao o PATH da sessao atual
# nao enxerga o executavel logo apos a instalacao.
function Resolve-OhMyPosh {
    $cmd = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\oh-my-posh.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\bin\oh-my-posh.exe')
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }
    return $null
}

function Test-WslInstalled {
    if (-not (Test-Command wsl)) { return $false }

    # wsl -l -q devolve UTF-16 e sai com erro quando nao ha distro instalada.
    # Restaura $LASTEXITCODE para nao contaminar quem chamou.
    $previous = $global:LASTEXITCODE
    $null = & wsl.exe -l -q 2>&1
    $ok = ($LASTEXITCODE -eq 0)
    $global:LASTEXITCODE = $previous
    return $ok
}
