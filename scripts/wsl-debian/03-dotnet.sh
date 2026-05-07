#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

require_debian_wsl
require_sudo

info "Configurando repositorio Microsoft para Debian 13."
tmp_deb="$(mktemp --suffix=.deb)"
wget https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb -O "$tmp_deb"
sudo dpkg -i "$tmp_deb"
rm -f "$tmp_deb"

info "Instalando .NET SDKs 10, 9 e 8."
unset APT_UPDATED
apt_install dotnet-sdk-10.0 dotnet-sdk-9.0 dotnet-sdk-8.0

info "Instalando PowerShell 7."
if apt_has_candidate powershell; then
  apt_install powershell
else
  warn "Pacote powershell nao encontrado no apt. Usando pacote .deb universal oficial."
  arch="$(dpkg --print-architecture)"
  case "$arch" in
    amd64) pwsh_deb="powershell_7.6.0-1.deb_amd64.deb" ;;
    arm64) pwsh_deb="powershell_7.6.0-1.deb_arm64.deb" ;;
    *) die "Arquitetura nao suportada para PowerShell via .deb universal: $arch" ;;
  esac

  tmp_pwsh="$(mktemp --suffix=.deb)"
  wget "https://github.com/PowerShell/PowerShell/releases/download/v7.6.0/$pwsh_deb" -O "$tmp_pwsh"
  sudo dpkg -i "$tmp_pwsh" || sudo apt-get install -f -y
  rm -f "$tmp_pwsh"
fi

info "Configurando dotnet tools no PATH."
ensure_path_line "$HOME/.profile" "$HOME/.dotnet/tools"
ensure_line "$HOME/.zshrc" 'export PATH="$HOME/.dotnet/tools:$PATH"'

info "Instalando/atualizando CSharpier como dotnet tool global."
if dotnet tool list -g | awk '{print $1}' | grep -Fxq csharpier; then
  dotnet tool update -g csharpier
else
  dotnet tool install -g csharpier
fi

info "Validacao rapida:"
dotnet --list-sdks
pwsh --version

warn "netcoredbg sera instalado pelo Mason no script do Neovim, junto com as ferramentas de debug."
