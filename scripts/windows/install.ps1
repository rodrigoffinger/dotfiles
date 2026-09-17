# Orquestrador do setup do Windows. Espelha scripts/wsl-debian/install.sh.

[CmdletBinding()]
param(
    [string]$From,
    [string]$Only,
    [switch]$List
)

. (Join-Path $PSScriptRoot 'common.ps1')

$steps = @(
    '01-shell.ps1',
    '02-fonts.ps1',
    '03-terminal.ps1'
)

if ($List) { $steps; exit 0 }
if ($From -and $Only) { Die "Use -From ou -Only, nao ambos." }
if ($From -and $steps -notcontains $From) { Die "Etapa desconhecida: $From" }
if ($Only -and $steps -notcontains $Only) { Die "Etapa desconhecida: $Only" }

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Die "Rode com PowerShell 7 (pwsh). Versao atual: $($PSVersionTable.PSVersion)"
}

function Invoke-Step {
    param([string]$Step)
    Info "==> Rodando $Step"

    # Chamadas nativas dentro da etapa (wsl.exe, winget) deixam $LASTEXITCODE sujo.
    # Zerar antes garante que so o codigo de saida da propria etapa seja lido.
    $global:LASTEXITCODE = 0
    & (Join-Path $PSScriptRoot $Step)
    if ($LASTEXITCODE -ne 0) { Die "Etapa falhou: $Step (exit $LASTEXITCODE)" }

    Info "<== Concluido $Step"
}

if ($Only) { Invoke-Step $Only; exit 0 }

$started = -not $From
foreach ($step in $steps) {
    if ($step -eq $From) { $started = $true }
    if ($started) { Invoke-Step $step }
}

Info "Setup concluido."
Warn "Feche e abra o Windows Terminal para aplicar profile, fonte e perfis."
