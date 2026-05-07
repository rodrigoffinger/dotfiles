#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

require_debian_wsl

has_command curl || die "curl nao encontrado. Rode 01-base.sh antes."
has_command git || die "git nao encontrado. Rode 01-base.sh antes."

ensure_dir "$HOME/.local/bin"
ensure_path_line "$HOME/.profile" "$HOME/.local/bin"

info "Instalando mise em ~/.local/bin."
if ! has_command mise; then
  curl https://mise.run | sh
else
  info "mise ja esta instalado: $(mise --version)"
fi

export PATH="$HOME/.local/bin:$PATH"
activate_mise
prefer_linux_node_tools

info "Ativando mise em bash e zsh."
touch "$HOME/.bashrc" "$HOME/.zshrc"
ensure_line "$HOME/.bashrc" 'eval "$($HOME/.local/bin/mise activate bash)"'
ensure_line "$HOME/.zshrc" 'eval "$($HOME/.local/bin/mise activate zsh)"'
ensure_dir "$HOME/.local/share/zsh/site-functions"
if has_command mise; then
  mise completion zsh >"$HOME/.local/share/zsh/site-functions/_mise"
fi

info "Configurando suporte a arquivos idiomaticos de versao."
mise settings add idiomatic_version_file_enable_tools node || true
mise settings add idiomatic_version_file_enable_tools dotnet || true
mise settings add idiomatic_version_file_enable_tools java || true

mise_install_dotnet() {
  local version="$1"

  if mise install "dotnet@$version"; then
    return 0
  fi

  warn "mise falhou instalando dotnet@$version. Tentando corrigir permissao do dotnet-install.sh e repetir."
  if [[ -f "$HOME/.cache/mise/dotnet/dotnet-install.sh" ]]; then
    chmod +x "$HOME/.cache/mise/dotnet/dotnet-install.sh"
  fi

  mise install "dotnet@$version"
}

info "Instalando runtimes gerenciados pelo mise."
mise use -g node@22
mise install node@20 node@22

mise use -g java@temurin-17
mise install java@temurin-8 java@temurin-17

mise use -g dotnet@10
mise_install_dotnet 7
mise_install_dotnet 8
mise_install_dotnet 9
mise_install_dotnet 10

info "Instalando ferramentas JS globais no Node ativo do mise."
prefer_linux_node_tools
npm install -g \
  npm@latest \
  pnpm \
  prettier \
  tree-sitter-cli \
  tsx \
  typescript

mise reshim node || true
prefer_linux_node_tools

info "Runtimes concluidos:"
mise ls

warn ".NET 7 esta fora de suporte, mas foi incluido para compatibilidade com projetos legados."
warn "Para projetos, prefira commitar mise.toml, .tool-versions, .nvmrc ou global.json conforme o caso."
