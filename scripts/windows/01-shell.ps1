# Oh My Posh, modulos do PowerShell e profile.

. (Join-Path $PSScriptRoot 'common.ps1')

$repoRoot = Get-RepoRoot

# --- Oh My Posh ----------------------------------------------------------
if (Resolve-OhMyPosh) {
    Info "Oh My Posh ja instalado."
} else {
    if (-not (Test-Command winget)) { Die "winget nao encontrado. Instale o App Installer pela Microsoft Store." }
    Info "Instalando Oh My Posh via winget."
    winget install --id JanDeDobbeleer.OhMyPosh --source winget --scope user `
        --accept-package-agreements --accept-source-agreements --disable-interactivity
    if (-not (Resolve-OhMyPosh)) { Die "Oh My Posh nao foi encontrado depois da instalacao." }
}

# --- Modulos -------------------------------------------------------------
# PSReadLine ja vem com o PowerShell 7. Microsoft.PowerShell.ConsoleGuiTools
# entra sozinho como dependencia do F7History.
$modules = @('posh-git', 'F7History', 'Terminal-Icons')

foreach ($module in $modules) {
    if (Get-Module -ListAvailable -Name $module) {
        Info "Modulo ja instalado: $module"
        continue
    }

    Info "Instalando modulo: $module"
    if (Test-Command Install-PSResource) {
        Install-PSResource -Name $module -Scope CurrentUser -TrustRepository
    } else {
        Install-Module -Name $module -Scope CurrentUser -Force -AllowClobber
    }
}

# --- Profile -------------------------------------------------------------
$oneDrive = Get-OneDrivePersonal
if (-not $oneDrive) { Die "OneDrive pessoal nao encontrado. Faca login no OneDrive antes de rodar este passo." }

$sharedDir     = Join-Path $oneDrive 'Documents\PowerShell'
$sharedProfile = Join-Path $sharedDir 'Microsoft.PowerShell_profile.ps1'

# O OneDrive e a fonte da verdade do profile: ele propaga entre as maquinas.
# O repo guarda apenas um snapshot, usado para semear uma maquina nova.
if (Test-Path $sharedProfile) {
    Info "Profile compartilhado encontrado: $sharedProfile"
} else {
    Warn "Profile compartilhado nao existe ainda. Semeando com o snapshot do repo."
    New-Item -ItemType Directory -Force $sharedDir | Out-Null
    Copy-Item (Join-Path $repoRoot 'PowerShell\Microsoft.PowerShell_profile.ps1') $sharedProfile
    Info "Criado: $sharedProfile"
}

if (Test-DocumentsRedirected) {
    Info "Documentos esta redirecionado para o OneDrive. O profile compartilhado e encontrado nativamente."
    Info "Shim nao e necessario nesta maquina."
} else {
    Warn "Documentos NAO esta redirecionado para o OneDrive."
    Info "Instalando o shim para que o PowerShell ache o profile compartilhado."

    $target = $PROFILE.CurrentUserCurrentHost
    New-Item -ItemType Directory -Force (Split-Path $target) | Out-Null

    $shim = Join-Path $repoRoot 'PowerShell\profile-shim.ps1'
    if ((Test-Path $target) -and ((Get-FileHash $target).Hash -eq (Get-FileHash $shim).Hash)) {
        Info "Shim ja esta atualizado: $target"
    } else {
        Backup-Path $target
        Copy-Item $shim $target
        Info "Shim instalado: $target"
    }
}

Info "Abra um novo terminal para carregar o profile."
