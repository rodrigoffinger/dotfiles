#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

require_debian_wsl
require_sudo

info "Configurando repositorio oficial do Docker para Debian."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# shellcheck disable=SC1091
. /etc/os-release
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

info "Instalando Docker CLI, Compose plugin e LazyDocker."
unset APT_UPDATED
apt_install docker-ce-cli docker-buildx-plugin docker-compose-plugin

if apt_has_candidate lazydocker; then
  apt_install lazydocker
else
  warn "Pacote lazydocker nao encontrado no apt."
  info "Instalando lazydocker pelo binario oficial do GitHub Releases."
  ensure_dir "$HOME/.local/bin"
  ensure_path_line "$HOME/.profile" "$HOME/.local/bin"

  case "$(uname -m)" in
    x86_64) lazydocker_arch="x86_64" ;;
    aarch64 | arm64) lazydocker_arch="arm64" ;;
    *) die "Arquitetura nao suportada para lazydocker: $(uname -m)" ;;
  esac

  lazydocker_version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | jq -r '.tag_name')"
  lazydocker_url="https://github.com/jesseduffield/lazydocker/releases/download/${lazydocker_version}/lazydocker_${lazydocker_version#v}_Linux_${lazydocker_arch}.tar.gz"
  tmp_lazydocker="$(mktemp --suffix=.tar.gz)"
  curl -fL "$lazydocker_url" -o "$tmp_lazydocker"
  tar -xzf "$tmp_lazydocker" -C "$HOME/.local/bin" lazydocker
  chmod +x "$HOME/.local/bin/lazydocker"
  rm -f "$tmp_lazydocker"
fi

info "Adicionando usuario atual ao grupo docker, se o grupo existir."
if getent group docker >/dev/null 2>&1; then
  sudo usermod -aG docker "$USER"
  warn "Para aplicar o grupo docker, feche e abra o WSL/terminal."
fi

info "Gerando completion zsh para Docker."
ensure_dir "$HOME/.local/share/zsh/site-functions"
if has_command docker; then
  docker completion zsh >"$HOME/.local/share/zsh/site-functions/_docker"
fi

info "Verificacao do Docker Desktop/Engine:"
if docker version >/dev/null 2>&1; then
  docker version
else
  warn "docker CLI instalado, mas daemon nao respondeu. Se voce usa Docker Desktop, confira a integracao WSL para Debian."
fi
