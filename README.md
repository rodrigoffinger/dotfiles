# Dotfiles

Repositorio pessoal de configuracoes e scripts para ambientes de desenvolvimento.

## Conteudo

- `VSCode/`: configuracoes do Visual Studio Code.
- `WindowsTerminal/`: configuracoes do Windows Terminal.
- `scripts/wsl-debian/`: scripts para configurar um ambiente Debian no WSL.

## WSL Debian

A area `scripts/wsl-debian` monta um ambiente Linux/WSL focado em desenvolvimento via terminal, com suporte a:

- shell moderno com zsh, starship e tmux
- ferramentas CLI/TUI para produtividade
- .NET, PowerShell e ferramentas C#
- Node.js para projetos React, com multiplas versoes via mise
- Java para projetos legados e atuais, com multiplas versoes via mise
- Neovim com LazyVim
- Docker CLI e ferramentas auxiliares
- CLIs de AI

Veja [scripts/wsl-debian/README.md](scripts/wsl-debian/README.md) para o plano inicial.

## Observacao

Os scripts de instalacao devem ser revisados antes de serem executados no WSL.
