# Fonte Nerd usada pelo Windows Terminal e pelo Oh My Posh.

. (Join-Path $PSScriptRoot 'common.ps1')

# Nerd Fonts v3 registra a familia como "CaskaydiaCove NF", nao
# "CaskaydiaCove Nerd Font" -- o nome antigo cai em fallback e perde os glifos.
$family = 'CaskaydiaCove NF'

Add-Type -AssemblyName System.Drawing
$installed = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name

if ($installed -contains $family) {
    Info "Fonte ja instalada: $family"
    return
}

# CaskaydiaCove nao existe no winget. O proprio Oh My Posh instala Nerd Fonts
# na pasta de fontes do usuario, sem precisar de admin.
$omp = Resolve-OhMyPosh
if (-not $omp) { Die "Oh My Posh nao encontrado. Rode 01-shell.ps1 antes deste passo." }

Info "Instalando $family via Oh My Posh. Isso baixa alguns MB."
& $omp font install CascadiaCode --plain | Out-Null

$installed = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
if ($installed -contains $family) {
    Info "Fonte instalada: $family"
} else {
    Warn "Nao consegui confirmar a instalacao de $family. Verifique em Configuracoes > Personalizacao > Fontes."
}
