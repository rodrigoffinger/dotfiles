#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

require_debian_wsl
require_sudo
activate_mise || true
prefer_linux_node_tools || true

ensure_dir "$HOME/.local/bin"
ensure_path_line "$HOME/.profile" "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

apt_install_if_available() {
  local package="$1"
  if apt_has_candidate "$package"; then
    apt_install "$package"
  else
    warn "Pacote apt sem candidato instalavel: $package"
    return 1
  fi
}

github_latest_asset_url() {
  local repo="$1"
  local pattern="$2"

  curl -fsSL "https://api.github.com/repos/$repo/releases/latest" |
    jq -r --arg pattern "$pattern" '.assets[] | select(.name | test($pattern)) | .browser_download_url' |
    head -n 1
}

install_k9s() {
  has_command k9s && {
    info "k9s ja instalado: $(k9s version --short 2>/dev/null | head -n 1 || true)"
    return 0
  }

  info "Instalando k9s pelo GitHub Releases oficial."
  local pattern
  case "$(uname -m)" in
    x86_64) pattern='Linux_amd64\.tar\.gz$' ;;
    aarch64 | arm64) pattern='Linux_arm64\.tar\.gz$' ;;
    *) die "Arquitetura nao suportada para k9s: $(uname -m)" ;;
  esac

  local url tmp_dir archive
  url="$(github_latest_asset_url derailed/k9s "$pattern")"
  [[ -n "$url" ]] || die "Nao encontrei asset Linux para k9s."

  tmp_dir="$(mktemp -d)"
  archive="$tmp_dir/k9s.tar.gz"
  curl -fL "$url" -o "$archive"
  tar -xzf "$archive" -C "$tmp_dir"
  install -m 0755 "$tmp_dir/k9s" "$HOME/.local/bin/k9s"
  rm -rf "$tmp_dir"
}

install_yazi() {
  has_command yazi && {
    info "yazi ja instalado: $(yazi --version 2>/dev/null || true)"
    return 0
  }

  info "Instalando yazi pelo GitHub Releases oficial."
  local pattern
  case "$(uname -m)" in
    x86_64) pattern='x86_64-unknown-linux-gnu\.zip$' ;;
    aarch64 | arm64) pattern='aarch64-unknown-linux-gnu\.zip$' ;;
    *) die "Arquitetura nao suportada para yazi: $(uname -m)" ;;
  esac

  local url tmp_dir archive
  url="$(github_latest_asset_url sxyazi/yazi "$pattern")"
  [[ -n "$url" ]] || die "Nao encontrei asset Linux GNU para yazi."

  tmp_dir="$(mktemp -d)"
  archive="$tmp_dir/yazi.zip"
  curl -fL "$url" -o "$archive"
  unzip -q "$archive" -d "$tmp_dir"
  install -m 0755 "$(find "$tmp_dir" -type f -name yazi | head -n 1)" "$HOME/.local/bin/yazi"
  install -m 0755 "$(find "$tmp_dir" -type f -name ya | head -n 1)" "$HOME/.local/bin/ya"
  rm -rf "$tmp_dir"
}

install_lazysql() {
  has_command lazysql && {
    info "lazysql ja instalado."
    return 0
  }

  info "Instalando lazysql."
  local pattern
  case "$(uname -m)" in
    x86_64) pattern='Linux_.*(x86_64|amd64).*\.tar\.gz$' ;;
    aarch64 | arm64) pattern='Linux_.*(arm64|aarch64).*\.tar\.gz$' ;;
    *) die "Arquitetura nao suportada para lazysql: $(uname -m)" ;;
  esac

  local url tmp_dir archive binary
  url="$(github_latest_asset_url jorgerojas26/lazysql "$pattern" || true)"
  if [[ -n "$url" ]]; then
    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/lazysql.tar.gz"
    curl -fL "$url" -o "$archive"
    tar -xzf "$archive" -C "$tmp_dir"
    binary="$(find "$tmp_dir" -type f -name lazysql | head -n 1)"
    [[ -n "$binary" ]] || die "Asset do lazysql nao contem binario lazysql."
    install -m 0755 "$binary" "$HOME/.local/bin/lazysql"
    rm -rf "$tmp_dir"
    return 0
  fi

  warn "Nao encontrei release binaria do lazysql. Instalando via Go com mise."
  has_command mise || die "mise nao encontrado para instalar Go/lazysql."
  mise use -g go@latest
  activate_mise
  go install github.com/jorgerojas26/lazysql@latest
  mise reshim go || true
}

install_posting() {
  has_command posting && {
    info "posting ja instalado."
    return 0
  }

  info "Instalando uv e posting."
  if ! has_command uv; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  uv tool install --python 3.12 posting
}

info "Instalando TUIs e CLIs extras disponiveis via apt."
apt_install_if_available duf || true
apt_install_if_available gdu || true
if ! apt_install_if_available tldr; then
  if apt_install_if_available tealdeer; then
    if has_command tldr; then
      info "tldr disponivel via tealdeer."
    elif has_command tealdeer; then
      ln -sf "$(command -v tealdeer)" "$HOME/.local/bin/tldr"
    fi
  elif has_command npm; then
    warn "Instalando tldr via npm como fallback."
    npm install -g tldr
  else
    warn "tldr nao instalado; npm nao encontrado para fallback."
  fi
fi
apt_install_if_available xh || true
apt_install_if_available httpie || true
apt_install_if_available git-delta || true
apt_install_if_available glow || true

info "Instalando TUIs extras via releases/instaladores oficiais."
install_k9s
install_yazi
install_lazysql
install_posting

info "Adicionando aliases extras."
touch "$HOME/.bashrc" "$HOME/.zshrc"
ensure_line "$HOME/.bashrc" 'alias lg="lazygit"'
ensure_line "$HOME/.bashrc" 'alias lzg="lazygit"'
ensure_line "$HOME/.bashrc" 'alias lzd="lazydocker"'
ensure_line "$HOME/.bashrc" 'alias y="yazi"'
ensure_line "$HOME/.bashrc" 'alias md="glow"'
ensure_line "$HOME/.zshrc" 'alias lg="lazygit"'
ensure_line "$HOME/.zshrc" 'alias lzg="lazygit"'
ensure_line "$HOME/.zshrc" 'alias lzd="lazydocker"'
ensure_line "$HOME/.zshrc" 'alias y="yazi"'
ensure_line "$HOME/.zshrc" 'alias md="glow"'

info "Extras concluidos. Ferramentas principais:"
printf '%s\n' \
  "- k9s: Kubernetes TUI" \
  "- lazysql: SQL TUI" \
  "- posting: HTTP/API TUI" \
  "- yazi: file manager TUI" \
  "- glow: Markdown TUI" \
  "- duf/gdu: disco" \
  "- delta: Git diff pager" \
  "- tldr/xh/httpie: ajuda e HTTP"
