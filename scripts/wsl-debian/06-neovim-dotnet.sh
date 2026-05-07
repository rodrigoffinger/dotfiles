#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

require_debian_wsl
activate_mise
prefer_linux_node_tools

has_command git || die "git nao encontrado. Rode 01-base.sh antes."
has_command curl || die "curl nao encontrado. Rode 01-base.sh antes."
has_command npm || die "npm nao encontrado. Rode 04-runtimes.sh antes."
has_command dotnet || die "dotnet nao encontrado. Rode 03-dotnet.sh antes."
has_command tree-sitter || npm install -g tree-sitter-cli
prefer_linux_node_tools

ensure_dir "$HOME/.local/bin"
ensure_dir "$HOME/.local/opt"
ensure_path_line "$HOME/.profile" "$HOME/.local/bin"
ensure_line "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'

arch="$(uname -m)"
case "$arch" in
  x86_64) nvim_asset="nvim-linux-x86_64.tar.gz" ;;
  aarch64 | arm64) nvim_asset="nvim-linux-arm64.tar.gz" ;;
  *) die "Arquitetura nao suportada para instalacao binaria do Neovim: $arch" ;;
esac

info "Instalando Neovim stable mais recente em ~/.local/opt/nvim."
tmp_nvim="$(mktemp --suffix=.tar.gz)"
curl -fL "https://github.com/neovim/neovim/releases/latest/download/$nvim_asset" -o "$tmp_nvim"
rm -rf "$HOME/.local/opt/nvim"
tar -xzf "$tmp_nvim" -C "$HOME/.local/opt"
rm -f "$tmp_nvim"
mv "$HOME/.local/opt/${nvim_asset%.tar.gz}" "$HOME/.local/opt/nvim"
ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"

info "Criando config LazyVim. Config anterior sera preservada com backup."
backup_path "$HOME/.config/nvim"
backup_path "$HOME/.local/share/nvim"
backup_path "$HOME/.local/state/nvim"
backup_path "$HOME/.cache/nvim"

git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"

info "Adicionando configuracao C# com roslyn.nvim, Mason, netcoredbg e csharpier."
ensure_dir "$HOME/.config/nvim/lua/plugins"
cat >"$HOME/.config/nvim/lua/plugins/csharp.lua" <<'LUA'
return {
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = {
        "csharpier",
        "netcoredbg",
        "roslyn",
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {
      broad_search = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        roslyn = {
          mason = false,
          settings = {
            ["csharp|inlay_hints"] = {
              csharp_enable_inlay_hints_for_implicit_object_creation = true,
              csharp_enable_inlay_hints_for_implicit_variable_types = true,
              csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            },
            ["csharp|code_lens"] = {
              dotnet_enable_references_code_lens = true,
              dotnet_enable_tests_code_lens = true,
            },
          },
        },
      },
      setup = {
        roslyn = function()
          return true
        end,
      },
    },
  },
}
LUA

info "Sincronizando plugins do LazyVim em modo headless."
TREE_SITTER_CLI="$(command -v tree-sitter)" nvim --headless "+Lazy! sync" +qa

info "Tentando instalar ferramentas Mason em modo headless."
TREE_SITTER_CLI="$(command -v tree-sitter)" nvim --headless "+Lazy! load mason.nvim" "+MasonInstall roslyn netcoredbg csharpier" +qa || warn "MasonInstall falhou. Abra nvim e rode :Mason para instalar roslyn, netcoredbg e csharpier."

info "Neovim concluido. Rode 'nvim' e depois ':LazyHealth'."
