# Dotfiles

Repositorio pessoal de configuracoes e scripts para ambientes de desenvolvimento.

> Este repositorio e **publico**. Nunca commite credenciais. Em especial, `NuGet.Config`
> costuma carregar um PAT em texto claro em `<packageSourceCredentials>` — ele esta
> bloqueado no [`.gitignore`](.gitignore).

## Conteudo

| Diretorio | O que e |
|---|---|
| [`scripts/windows/`](scripts/windows/README.md) | Setup do host Windows: PowerShell, Oh My Posh, fonte Nerd, Windows Terminal. |
| [`scripts/wsl-debian/`](scripts/wsl-debian/README.md) | Setup de um Debian no WSL para desenvolvimento via terminal. |
| [`PowerShell/`](PowerShell/README.md) | Snapshot do profile do PowerShell e o shim de profile. |
| `WindowsTerminal/` | `settings.json` do Windows Terminal. |
| `VSCode/` | `settings.json` do Visual Studio Code. |
| `wsl/` | `.wslconfig`, copiado para `%USERPROFILE%`. |

## Replicando em uma maquina nova

A ordem importa: o Windows primeiro, porque e ele quem instala a fonte e o terminal de
onde voce vai rodar o resto.

**1. Pre-requisitos**

```powershell
winget install Microsoft.PowerShell
winget install Microsoft.WindowsTerminal
winget install Git.Git
```

**2. Clonar o repo**

```powershell
git clone https://github.com/rodrigoffinger/dotfiles.git
```

**3. Host Windows** — Oh My Posh, modulos, fonte e Windows Terminal:

```powershell
cd dotfiles\scripts\windows
.\install.ps1
```

**4. WSL Debian**, se for usar:

```powershell
wsl --install -d Debian
```

Depois, dentro do Debian:

```sh
cd /mnt/d/Projects/dotfiles/scripts/wsl-debian
bash ./install.sh
```

**5. Ajustes manuais** que os scripts nao fazem:

- Copiar `wsl/.wslconfig` para `%USERPROFILE%\.wslconfig` e rodar `wsl --shutdown`.
  Confira o `memory=` antes: o valor atual e conservador demais para o ambiente que os
  scripts do WSL montam.
- Copiar `VSCode/settings.json` para `%APPDATA%\Code\User\settings.json`.
  Ele depende da fonte **Fira Code** e das extensoes `dracula-theme.theme-dracula` e
  `PKief.material-icon-theme`.
- `startingDirectory` dos perfis do terminal aponta para `D:/Projetos`. Ajuste se a
  maquina nova nao tiver esse caminho.

## Fonte da verdade

Configuracao que muda com frequencia — hoje, o profile do PowerShell — tem como fonte da
verdade o **OneDrive**, que propaga entre as maquinas automaticamente. Este repositorio
guarda o snapshot versionado e os scripts que montam uma maquina do zero.

Detalhes em [`PowerShell/README.md`](PowerShell/README.md).

## Observacao

Os scripts de instalacao devem ser revisados antes de serem executados.
