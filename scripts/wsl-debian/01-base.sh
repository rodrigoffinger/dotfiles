#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

require_debian_wsl
require_sudo

info "Instalando pacotes base de terminal e build."
apt_install \
  apt-transport-https \
  bat \
  btop \
  build-essential \
  ca-certificates \
  cmake \
  curl \
  direnv \
  fastfetch \
  fd-find \
  fzf \
  git \
  gnupg \
  htop \
  jq \
  less \
  lsb-release \
  make \
  pkg-config \
  python3 \
  python3-pip \
  python3-venv \
  ripgrep \
  shellcheck \
  tmux \
  tree \
  unzip \
  wget \
  yq \
  zoxide

info "Criando aliases/symlinks locais para comandos com nomes Debian."
ensure_dir "$HOME/.local/bin"
if has_command batcat && ! has_command bat; then
  ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
fi
if has_command fdfind && ! has_command fd; then
  ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi
ensure_path_line "$HOME/.profile" "$HOME/.local/bin"

info "Instalando eza se estiver disponivel no repositorio Debian."
if apt_has_candidate eza; then
  apt_install eza
else
  warn "Pacote eza nao encontrado no apt. Pulando por enquanto."
fi

info "Instalando lazygit se estiver disponivel no repositorio Debian."
if apt_has_candidate lazygit; then
  apt_install lazygit
else
  warn "Pacote lazygit nao encontrado no apt. Pulando por enquanto."
fi

info "Configurando Git global para uso no WSL."
git config --global core.autocrlf input
git config --global core.eol lf
git config --global core.filemode false
git config --global init.defaultBranch main

info "Configurando repositorio oficial do GitHub CLI."
sudo install -m 0755 -d /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]]; then
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |
    sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
fi

arch="$(dpkg --print-architecture)"
printf 'deb [arch=%s signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' "$arch" |
  sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
unset APT_UPDATED
apt_install gh

info "Base concluida. Abra um novo shell ou rode: source ~/.profile"
