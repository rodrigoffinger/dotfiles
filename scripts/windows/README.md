# Windows Dev Setup

Scripts para preparar o lado Windows: PowerShell, Oh My Posh, fonte Nerd e Windows Terminal.

E o equivalente de `scripts/wsl-debian` para o host.

## Pre-requisitos

- Windows 10/11
- PowerShell 7 (`winget install Microsoft.PowerShell`)
- winget (App Installer, pela Microsoft Store)
- Windows Terminal
- OneDrive pessoal logado, se voce usa o profile compartilhado

## Como executar

Abra um **PowerShell 7** e rode:

```powershell
cd D:\Projects\dotfiles\scripts\windows
.\install.ps1
```

Nenhuma etapa precisa de privilegio de administrador.

Listar as etapas:

```powershell
.\install.ps1 -List
```

Retomar a partir de uma etapa, ou rodar so uma:

```powershell
.\install.ps1 -From 02-fonts.ps1
.\install.ps1 -Only 03-terminal.ps1
```

Se o PowerShell bloquear a execucao dos scripts:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## Etapas

| Script | O que faz |
|---|---|
| `common.ps1` | Funcoes compartilhadas: log, backup, deteccao de OneDrive/WSL/Oh My Posh. Nao roda sozinho. |
| `01-shell.ps1` | Oh My Posh via winget, modulos `posh-git`/`F7History`/`Terminal-Icons`, e instalacao do profile. |
| `02-fonts.ps1` | Fonte `CaskaydiaCove NF`, via `oh-my-posh font install`. |
| `03-terminal.ps1` | Aplica o `settings.json` do Windows Terminal, com backup do que existia. |

Todas as etapas sao idempotentes: rodar de novo nao duplica nada.

## O profile do PowerShell

A **fonte da verdade e o OneDrive**, em `OneDrive\Documents\PowerShell\`. E de la que a
configuracao propaga entre as maquinas. O `PowerShell/` deste repo guarda um snapshot,
usado para semear uma maquina nova quando o OneDrive ainda nao tem nada.

O `01-shell.ps1` cobre os dois cenarios:

- **Documentos redirecionado para o OneDrive** (o padrao quando o Backup de Pastas do
  OneDrive esta ligado): o PowerShell acha o profile compartilhado sozinho. Nada a fazer.
- **Documentos local**: o PowerShell procura em `C:\Users\<user>\Documents\PowerShell\` e
  nunca enxerga o OneDrive. O script instala entao o `profile-shim.ps1`, que faz
  dot-source do profile compartilhado. Nada e escrito dentro do OneDrive.

## Detalhes que quebram em maquina nova

Coisas que ja deram problema e estao tratadas nos scripts:

- **`$env:OneDrive` pode ser o corporativo.** Em maquina com OneDrive de trabalho, essa
  variavel aponta para `OneDrive - <Empresa>`. O pessoal e `$env:OneDriveConsumer`.
- **A familia da fonte e `CaskaydiaCove NF`**, nao `CaskaydiaCove Nerd Font`. O Nerd Fonts
  v3 renomeou. Com o nome antigo o terminal cai em fallback e os glifos do prompt viram
  quadrados.
- **Oh My Posh via winget vira pacote MSIX** e nao exporta `POSH_THEMES_PATH`. Os temas
  ficam em `C:\Program Files\WindowsApps\ohmyposh.cli_*_x64__*\themes`.
- **Arquivos do OneDrive podem ser placeholders na nuvem.** Modulos do PowerShell
  guardados la nao servem para carregar no startup: hidratam a cada abertura e quebram
  offline. Por isso os modulos sao instalados do PSGallery, localmente.
- **GUIDs de perfil do Visual Studio sao derivados do caminho de instalacao**, entao nao
  se repetem entre maquinas. O `settings.json` deste repo nao os carrega; o Windows
  Terminal os gera sozinho.
