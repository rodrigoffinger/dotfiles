# Debian WSL Dev Setup

Scripts para configurar um ambiente Debian no WSL focado em desenvolvimento via terminal.

## Objetivo

Este diretório vai concentrar scripts incrementais para preparar um Debian WSL com ferramentas de shell, desenvolvimento .NET, React, Docker, Neovim e CLIs de AI.

O foco inicial e:

- Debian GNU/Linux 13 (trixie) no WSL2
- zsh, starship, tmux e utilitarios modernos de terminal
- .NET SDKs, PowerShell 7 e ferramentas C#
- Node.js para projetos React, com multiplas versoes via mise
- Java 8/17 para projetos legados e atuais, com multiplas versoes via mise
- Neovim com LazyVim e suporte a C#
- Docker CLI e ferramentas TUI
- CLIs de AI para uso no terminal

## Estrutura planejada

```text
scripts/wsl-debian/
  README.md
  common.sh
  01-base.sh
  02-shell.sh
  03-dotnet.sh
  04-runtimes.sh
  05-ai-cli.sh
  06-neovim-dotnet.sh
  07-docker-tools.sh
  08-extra-tuis.sh
  install.sh
```

## Scripts

- `common.sh`: funcoes compartilhadas de validacao, apt, PATH e backup.
- `install.sh`: orquestrador geral que executa as etapas em ordem.
- `01-base.sh`: pacotes base, build tools, GitHub CLI, fzf, zoxide, ripgrep, fd, bat, tmux, btop, fastfetch, eza/lazygit quando disponiveis, e configuracao global do Git para WSL.
- `02-shell.sh`: zsh, Starship, prompt, completions, historico, autosuggestions, tmux, aliases e helpers `tdl`/`tdlm`/`tsl`.
- `03-dotnet.sh`: repositorio Microsoft, .NET SDKs 10/9/8, PowerShell 7 e CSharpier como fallback de sistema. Se `powershell` nao existir no apt, usa o `.deb` universal oficial.
- `04-runtimes.sh`: mise, Node.js 20/22, Java Temurin 8/17, .NET 7/8/9/10 e ferramentas JS globais.
- `05-ai-cli.sh`: OpenCode, Claude Code, Codex, Gemini CLI e GitHub Copilot CLI via npm.
- `06-neovim-dotnet.sh`: Neovim stable em `~/.local`, LazyVim e configuracao C# com `roslyn.nvim`.
- `07-docker-tools.sh`: Docker CLI, Buildx, Compose plugin, LazyDocker e verificacao de integracao Docker/WSL.
- `08-extra-tuis.sh`: TUIs/CLIs extras da comunidade, como k9s, lazysql, posting, yazi, glow, duf, gdu, delta, tldr e clientes HTTP.

## O que e instalado

Base e produtividade:

- `git`, `gh`, `curl`, `wget`, `jq`, `yq`, `tree`, `unzip`, `less`
- `build-essential`, `cmake`, `make`, `pkg-config`, `python3`, `python3-venv`, `python3-pip`
- `ripgrep`, `fd`, `bat`, `fzf`, `zoxide`, `direnv`
- `tmux`, `btop`, `htop`, `fastfetch`
- `eza` e `lazygit`, quando disponiveis no apt

Shell e prompt:

- `zsh` como shell padrao
- `starship` em `~/.local/bin`
- prompt segmentado com usuario, caminho completo, Git, duracao, shell, bateria e hora
- `fastfetch` ao abrir shell interativo
- `zsh-autocomplete`, `zsh-autosuggestions` e `zsh-syntax-highlighting`
- `fzf` para historico com `Ctrl+R`
- completions para `gh`, `mise`, `docker` e `dotnet`

Configuracao Git global para WSL:

- `core.autocrlf=input`
- `core.eol=lf`
- `core.filemode=false`
- `init.defaultBranch=main`

Runtimes e linguagens:

- .NET SDKs via apt: `10.0`, `9.0`, `8.0`
- PowerShell 7
- CSharpier como `dotnet tool`
- `mise` para gerenciar versoes por projeto
- Node.js via mise: `20`, `22`
- Java Temurin via mise: `8`, `17`
- .NET via mise: `7`, `8`, `9`, `10`
- ferramentas JS globais: `npm@latest`, `pnpm`, `prettier`, `tree-sitter-cli`, `tsx`, `typescript`

AI CLIs:

- `claude`
- `codex`
- `gemini`
- `copilot`
- `opencode`

Neovim:

- Neovim stable em `~/.local/opt/nvim`
- LazyVim starter em `~/.config/nvim`
- `mason.nvim`
- `nvim-lspconfig`
- `roslyn.nvim`
- Mason registry extra `Crashdummyy/mason-registry`
- ferramentas C# via Mason: `roslyn`, `netcoredbg`, `csharpier`
- Tree-sitter usando `tree-sitter-cli` Linux, evitando o binario Node do Windows herdado pelo WSL

Docker:

- Docker CLI
- Docker Buildx plugin
- Docker Compose plugin
- LazyDocker via apt ou GitHub Releases
- completion zsh para `docker`
- usuario adicionado ao grupo `docker`, quando o grupo existir

TUIs e extras opcionais:

- `k9s`
- `lazysql`
- `posting`
- `yazi`
- `glow`
- `duf`
- `gdu`
- `git-delta`
- `tldr` ou fallback `tealdeer`/npm
- `xh`
- `httpie`

Alguns extras sao best effort: se o pacote nao existir no apt do Debian 13, o script tenta um fallback quando existe um caminho oficial razoavel, ou apenas avisa e continua.

## Como executar

Abra o Debian pelo Windows Terminal ou pelo PowerShell:

```powershell
wsl -d Debian
```

Dentro do Debian, entre na pasta dos scripts no drive Windows:

```sh
cd /mnt/d/Projects/dotfiles/scripts/wsl-debian
```

Opcionalmente, confira a sintaxe antes de instalar qualquer coisa:

```sh
bash -n common.sh install.sh 01-base.sh 02-shell.sh 03-dotnet.sh 04-runtimes.sh 05-ai-cli.sh 06-neovim-dotnet.sh 07-docker-tools.sh 08-extra-tuis.sh
```

Para executar tudo em ordem:

```sh
bash ./install.sh
```

Para listar as etapas:

```sh
bash ./install.sh --list
```

Para retomar a partir de uma etapa especifica:

```sh
bash ./install.sh --from 04-runtimes.sh
```

Para executar apenas uma etapa:

```sh
bash ./install.sh --only 04-runtimes.sh
```

Se preferir depurar manualmente, execute uma etapa por vez:

```sh
bash ./01-base.sh
bash ./02-shell.sh
bash ./03-dotnet.sh
bash ./04-runtimes.sh
bash ./05-ai-cli.sh
bash ./06-neovim-dotnet.sh
bash ./07-docker-tools.sh
bash ./08-extra-tuis.sh
```

Depois do `02-shell.sh`, feche e abra o terminal para entrar no `zsh`.

Se preferir clonar/copiar este repo para dentro do filesystem Linux, ajuste o `cd`:

```sh
cd ~/dotfiles/scripts/wsl-debian
bash ./01-base.sh
```

Os scripts fazem alteracoes no ambiente do usuario Linux e instalam pacotes. Revise antes da primeira execucao.

Se uma etapa falhar, pare nela, copie o erro e rode novamente apenas o mesmo script depois do ajuste. Nao precisa reexecutar tudo desde o inicio.

## Gerenciamento de versoes

O Omarchy usa `mise` para instalar e alternar versoes de runtimes. Este setup segue a mesma ideia.

Versoes globais iniciais:

- Node.js: `22`
- Java: `temurin-17`
- .NET SDK: `10`

Versoes adicionais instaladas:

- Node.js: `20`, `22`
- Java: `temurin-8`, `temurin-17`
- .NET SDK: `7`, `8`, `9`, `10`

Exemplo para um projeto React legado:

```sh
cd ~/src/projeto-react-antigo
mise use node@20
mise trust
```

Isso cria um `mise.toml` no projeto:

```toml
[tools]
node = "20"
```

Exemplo para Java 8:

```sh
cd ~/src/projeto-java-legado
mise use java@temurin-8
mise trust
```

Exemplo para .NET:

```sh
cd ~/src/projeto-dotnet
mise use dotnet@8
mise trust
```

Projetos .NET tambem podem continuar usando `global.json`; o mise foi configurado para reconhecer esse arquivo.

Arquivos de versao reconhecidos pelo setup:

- `mise.toml`
- `.tool-versions`
- `.nvmrc`
- `.node-version`
- `.java-version`
- `global.json`

## Atalhos estilo Omarchy

No WSL nao temos Hyprland, entao os atalhos globais `Super+...` do Omarchy nao se aplicam. O que foi trazido para este setup e a parte de terminal:

- `n`: abre `nvim`
- `t`: abre/retoma uma sessao tmux `main`
- `ff`: busca arquivos com `fzf` e preview
- `sysinfo`: roda `fastfetch`
- `Ctrl+R`: busca historico com `fzf`, como no Omarchy
- `ls`, `ll`, `lsa`, `lt`, `lta`: aliases com `eza`
- prefixo tmux: `Ctrl+Space` (`Ctrl+B` tambem funciona)
- `Prefix + v`: split ao lado
- `Prefix + h`: split abaixo
- `Prefix + x`: fecha pane
- `Prefix + z`: zoom do pane
- `Alt + 1-9`: vai para uma janela tmux
- `Alt + Left/Right`: troca janela
- `Alt + Up/Down`: troca sessao
- `tdl <ai> [segundo_ai]`: cria layout dev com editor, agente e terminal
- `tdlm <ai> [segundo_ai]`: cria layout dev por subdiretorio
- `tsl <quantidade> <comando>`: cria um grid de panes rodando o comando

No Neovim, o setup usa LazyVim, entao os atalhos principais seguem o LazyVim/Omarchy:

- `Space Space`: busca arquivo
- `Space E`: alterna sidebar
- `Space S G`: busca por texto
- `Space G G`: abre LazyGit
- `Shift + H/L`: navega entre buffers
- `Space B D`: fecha buffer

## Estado atual

- WSL detectado com distro `Debian` em execucao.
- Debian detectado como `Debian GNU/Linux 13 (trixie)`.
- Usuario WSL detectado como `rodri`, com permissao `sudo`.
- Distro padrao do WSL ainda esta como `Ubuntu-24.04`.

## Observacoes

Antes de fixar comandos de instalacao, vamos validar as fontes oficiais e os comandos atuais para:

- repositorios Microsoft para .NET e PowerShell no Debian 13
- versoes recomendadas de Node.js, Java e .NET via mise
- instalacao das CLIs de AI
- requisitos atuais do LazyVim e do Roslyn LSP

## Fontes usadas

- Microsoft Learn: instalacao do .NET no Debian 13
- Microsoft Learn: instalacao do PowerShell no Debian
- NodeSource: repositorio DEB para Node.js 22.x
- mise: gerenciamento de versoes de Node.js, Java e .NET
- LazyVim: requisitos e instalacao do starter
- roslyn.nvim: requisitos e uso com Mason custom registry
- Docker Docs: repositorio apt oficial para Debian
- Docs oficiais das CLIs: Claude Code, OpenAI Codex, Gemini CLI, GitHub Copilot CLI e OpenCode
