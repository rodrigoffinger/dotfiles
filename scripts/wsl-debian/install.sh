#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

steps=(
  "01-base.sh"
  "02-shell.sh"
  "03-dotnet.sh"
  "04-runtimes.sh"
  "05-ai-cli.sh"
  "06-neovim-dotnet.sh"
  "07-docker-tools.sh"
  "08-extra-tuis.sh"
)

usage() {
  cat <<USAGE
Usage:
  bash ./install.sh
  bash ./install.sh --from 03-dotnet.sh
  bash ./install.sh --only 04-runtimes.sh
  bash ./install.sh --list

Options:
  --from STEP   Run STEP and everything after it.
  --only STEP   Run only STEP.
  --list        List available steps.
  -h, --help    Show this help.
USAGE
}

list_steps() {
  printf '%s\n' "${steps[@]}"
}

step_exists() {
  local wanted="$1"
  local step
  for step in "${steps[@]}"; do
    [[ "$step" == "$wanted" ]] && return 0
  done
  return 1
}

run_step() {
  local step="$1"
  info "==> Rodando $step"
  activate_mise || true
  bash "$SCRIPT_DIR/$step"
  activate_mise || true
  info "<== Concluido $step"
}

from_step=""
only_step=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from)
      [[ $# -ge 2 ]] || die "--from precisa de uma etapa."
      from_step="$2"
      shift 2
      ;;
    --only)
      [[ $# -ge 2 ]] || die "--only precisa de uma etapa."
      only_step="$2"
      shift 2
      ;;
    --list)
      list_steps
      exit 0
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      die "Opcao desconhecida: $1"
      ;;
  esac
done

require_debian_wsl

if [[ -n "$from_step" && -n "$only_step" ]]; then
  die "Use --from ou --only, nao ambos."
fi

if [[ -n "$only_step" ]]; then
  step_exists "$only_step" || die "Etapa desconhecida: $only_step"
  run_step "$only_step"
  exit 0
fi

started=0
if [[ -z "$from_step" ]]; then
  started=1
else
  step_exists "$from_step" || die "Etapa desconhecida: $from_step"
fi

for step in "${steps[@]}"; do
  if [[ "$step" == "$from_step" ]]; then
    started=1
  fi

  if [[ "$started" -eq 1 ]]; then
    run_step "$step"
  fi
done

info "Instalacao concluida."
warn "Feche e abra o terminal/WSL para aplicar shell, PATH e grupos."
