# settings.json do Windows Terminal.

. (Join-Path $PSScriptRoot 'common.ps1')

$repoRoot = Get-RepoRoot
$source   = Join-Path $repoRoot 'WindowsTerminal\settings.json'

if (-not (Test-Path $source)) { Die "Nao encontrei $source" }

$targets = @(
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'),
    (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'),
    (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
)

$target = $targets | Where-Object { Test-Path (Split-Path $_) } | Select-Object -First 1
if (-not $target) { Die "Windows Terminal nao parece instalado. Instale-o e rode este passo de novo." }

if (Get-Process WindowsTerminal -ErrorAction SilentlyContinue) {
    Warn "O Windows Terminal esta aberto. Feche-o antes de aplicar, senao ele pode sobrescrever o arquivo."
}

Info "Aplicando em: $target"
Backup-Path $target

$settings = Get-Content $source -Raw | ConvertFrom-Json

# Perfis que dependem do WSL so fazem sentido onde o WSL existe. Sem isso eles
# aparecem no menu e falham ao abrir.
if (-not (Test-WslInstalled)) {
    Warn "WSL nao instalado. Ocultando os perfis que dependem dele."
    foreach ($wtProfile in $settings.profiles.list) {
        $usesWsl = ($wtProfile.commandline -match '(?i)\bwsl(\.exe)?\b') -or
                   ($wtProfile.source           -match '(?i)wsl')
        if ($usesWsl) {
            if ($wtProfile.PSObject.Properties.Name -contains 'hidden') { $wtProfile.hidden = $true }
            else { $wtProfile | Add-Member -NotePropertyName hidden -NotePropertyValue $true }
            Info "  oculto: $($wtProfile.name)"
        }
    }
}

New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null
$settings | ConvertTo-Json -Depth 32 | Set-Content $target -Encoding utf8

# Falha cedo se o JSON saiu quebrado, em vez de deixar o terminal reclamar.
$null = Get-Content $target -Raw | ConvertFrom-Json
Info "settings.json aplicado e validado."

$family = 'CaskaydiaCove NF'
Add-Type -AssemblyName System.Drawing
if ((New-Object System.Drawing.Text.InstalledFontCollection).Families.Name -notcontains $family) {
    Warn "A fonte $family nao esta instalada. Rode 02-fonts.ps1, senao os glifos do prompt viram quadrados."
}
