#!/usr/bin/env bash

set -Eeuo pipefail

info() {
  printf '\033[1;34m[info]\033[0m %s\n' "$*"
}

warn() {
  printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2
}

die() {
  printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2
  exit 1
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

require_sudo() {
  has_command sudo || die "sudo nao encontrado. Instale sudo ou execute em um usuario com permissao administrativa."
  sudo -v
}

require_debian_wsl() {
  [[ -r /etc/os-release ]] || die "/etc/os-release nao encontrado."
  # shellcheck disable=SC1091
  . /etc/os-release

  [[ "${ID:-}" == "debian" ]] || die "Este script foi feito para Debian. Detectado: ${ID:-desconhecido}."
  [[ "${VERSION_ID:-}" == "13" ]] || warn "Testado para Debian 13. Detectado: ${VERSION_ID:-desconhecido}."

  if [[ -r /proc/version ]] && ! grep -qiE "microsoft|wsl" /proc/version; then
    warn "Nao parece ser WSL. Continuando, mas estes scripts foram pensados para WSL."
  fi
}

apt_update_once() {
  if [[ -z "${APT_UPDATED:-}" ]]; then
    require_sudo
    sudo apt-get update
    export APT_UPDATED=1
  fi
}

apt_install() {
  apt_update_once
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

apt_has_candidate() {
  apt-cache policy "$1" 2>/dev/null | grep -q 'Candidate: [^(]'
}

ensure_dir() {
  mkdir -p "$1"
}

ensure_line() {
  local file="$1"
  local line="$2"

  touch "$file"
  grep -Fqx "$line" "$file" || printf '%s\n' "$line" >>"$file"
}

ensure_path_line() {
  local file="$1"
  local dir="$2"

  ensure_line "$file" "export PATH=\"$dir:\$PATH\""
}

activate_mise() {
  if [[ -x "$HOME/.local/bin/mise" ]]; then
    eval "$("$HOME/.local/bin/mise" activate bash)"
  elif has_command mise; then
    eval "$(mise activate bash)"
  fi
}

prefer_linux_node_tools() {
  local cleaned_path=""
  local part

  IFS=':' read -r -a path_parts <<<"$PATH"
  for part in "${path_parts[@]}"; do
    case "$part" in
      /mnt/c/Users/*/AppData/Roaming/npm* | /mnt/c/Program\ Files/nodejs* | /mnt/c/Program\ Files\ \(x86\)/nodejs*)
        continue
        ;;
    esac

    if [[ -z "$cleaned_path" ]]; then
      cleaned_path="$part"
    else
      cleaned_path="$cleaned_path:$part"
    fi
  done

  export PATH="$HOME/.local/bin:$HOME/.dotnet/tools:$cleaned_path"
  hash -r

  if has_command npm; then
    npm config set prefix "$HOME/.local" >/dev/null
  fi
}

backup_path() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    local stamp
    stamp="$(date +%Y%m%d-%H%M%S)"
    mv "$target" "$target.bak-$stamp"
    info "Backup criado: $target.bak-$stamp"
  fi
}

repo_root() {
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  cd "$script_dir/../.." && pwd
}
