# ---------------------------------------------------------------------------
# Shim de profile do PowerShell.
#
# Instalado em Documents\PowerShell\Microsoft.PowerShell_profile.ps1 APENAS nas
# maquinas onde a pasta Documentos NAO esta redirecionada para o OneDrive.
#
# Nessas maquinas o PowerShell procura o profile em C:\Users\<user>\Documents e
# nunca enxerga o arquivo compartilhado, que mora no OneDrive. Este shim faz a
# ponte: ele so le o profile compartilhado, nunca escreve nele.
#
# Onde Documentos JA esta redirecionado para o OneDrive, este arquivo nao e
# necessario -- o profile compartilhado e encontrado nativamente.
# ---------------------------------------------------------------------------

# $env:OneDrive pode apontar para um OneDrive corporativo. O pessoal, que e
# onde os dotfiles vivem, e sempre $env:OneDriveConsumer.
$OneDrivePersonal = $env:OneDriveConsumer
if (-not $OneDrivePersonal) { $OneDrivePersonal = Join-Path $env:USERPROFILE 'OneDrive' }

$SharedProfile = Join-Path $OneDrivePersonal 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'

# O Oh My Posh instalado via winget vira pacote MSIX e nao exporta
# POSH_THEMES_PATH. O profile compartilhado depende dessa variavel.
if (-not $env:POSH_THEMES_PATH) {
    $themes = Get-Item 'C:\Program Files\WindowsApps\ohmyposh.cli_*_x64__*\themes' -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime | Select-Object -Last 1
    if ($themes) { $env:POSH_THEMES_PATH = $themes.FullName }
}

if (Test-Path $SharedProfile) {
    . $SharedProfile
} else {
    Write-Warning "Profile compartilhado nao encontrado em: $SharedProfile"
}

# Extras locais que nao estao no profile compartilhado.
# Vem depois do dot-source para nao serem sobrescritos.
Import-Module Terminal-Icons -ErrorAction SilentlyContinue
