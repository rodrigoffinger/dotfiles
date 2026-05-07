#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

require_debian_wsl

activate_mise
prefer_linux_node_tools

has_command node || die "Node.js nao encontrado. Rode 04-runtimes.sh antes."
has_command npm || die "npm nao encontrado. Rode 04-runtimes.sh antes."

ensure_dir "$HOME/.local/bin"
npm config set prefix "$HOME/.local"
ensure_path_line "$HOME/.profile" "$HOME/.local/bin"
ensure_line "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
prefer_linux_node_tools

info "Instalando CLIs de AI via npm global no prefixo do usuario."
npm install -g \
  @anthropic-ai/claude-code \
  @github/copilot \
  @google/gemini-cli \
  @openai/codex \
  opencode-ai

info "AI CLIs instaladas. Autenticacao fica para uso interativo:"
printf '%s\n' \
  "- claude: execute claude" \
  "- codex: execute codex" \
  "- gemini: execute gemini" \
  "- copilot: execute copilot e use /login" \
  "- opencode: execute opencode auth login"
