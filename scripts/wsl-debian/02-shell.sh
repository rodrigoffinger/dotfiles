#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
. "$SCRIPT_DIR/common.sh"

require_debian_wsl
require_sudo

info "Instalando zsh e dependencias do shell."
apt_install zsh fzf zsh-autosuggestions zsh-syntax-highlighting

ensure_dir "$HOME/.local/bin"
ensure_path_line "$HOME/.profile" "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

info "Instalando Starship em ~/.local/bin."
curl -fsSL https://starship.rs/install.sh -o /tmp/install-starship.sh
sh /tmp/install-starship.sh --yes --bin-dir "$HOME/.local/bin"
rm -f /tmp/install-starship.sh

info "Configurando completions, historico e sugestoes do zsh."
ensure_dir "$HOME/.config/zsh"
ensure_dir "$HOME/.local/share/zsh/site-functions"
ensure_dir "$HOME/.local/share/zsh/plugins"

if apt_has_candidate zsh-completions; then
  apt_install zsh-completions
else
  warn "Pacote zsh-completions nao encontrado no apt. Usando completions geradas pelas ferramentas."
fi

if [[ -d "$HOME/.local/share/zsh/plugins/zsh-autocomplete/.git" ]]; then
  git -C "$HOME/.local/share/zsh/plugins/zsh-autocomplete" pull --ff-only
else
  git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete "$HOME/.local/share/zsh/plugins/zsh-autocomplete"
fi

if has_command gh; then
  gh completion -s zsh >"$HOME/.local/share/zsh/site-functions/_gh"
fi

cat >"$HOME/.config/zsh/completions.zsh" <<'ZSH'
export FPATH="$HOME/.local/share/zsh/site-functions:$FPATH"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"
compinit -d "$HOME/.cache/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh"

if [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

if [[ -r /usr/share/doc/fzf/examples/completion.zsh ]]; then
  source /usr/share/doc/fzf/examples/completion.zsh
fi

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} --height=40% --layout=reverse --border"
export FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS:-} --preview 'echo {}' --preview-window=down:3:wrap"

if command -v dotnet >/dev/null 2>&1; then
  _dotnet_zsh_complete() {
    local completions
    completions=("${(@f)$(dotnet complete "$words")}")
    compadd -- "${completions[@]}"
  }
  compdef _dotnet_zsh_complete dotnet
fi

if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -r "$HOME/.local/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]]; then
  zstyle ':autocomplete:*:*' list-lines 10
  zstyle ':autocomplete:history-incremental-search-backward:*' list-lines 10
  zstyle ':autocomplete:*' delay 0.05
  zstyle ':autocomplete:*' min-input 1
  zstyle ':autocomplete:*' add-space executables aliases functions builtins reserved-words commands
  source "$HOME/.local/share/zsh/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
fi
ZSH

info "Configurando tmux e helpers de terminal."
ensure_dir "$HOME/.config/tmux"
backup_path "$HOME/.config/tmux/tmux.conf"
cat >"$HOME/.config/tmux/tmux.conf" <<'TMUX'
set -g default-terminal "tmux-256color"
set -as terminal-features ",xterm-256color:RGB"

set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
setw -g mode-keys vi

set -g prefix C-Space
set -g prefix2 C-b
bind C-Space send-prefix
bind C-b send-prefix

bind q source-file ~/.config/tmux/tmux.conf \; display-message "tmux.conf reloaded"

bind v split-window -h -c "#{pane_current_path}"
bind h split-window -v -c "#{pane_current_path}"
bind x kill-pane
bind z resize-pane -Z

bind c new-window -c "#{pane_current_path}"
bind k kill-window
bind r command-prompt -I "#{window_name}" "rename-window '%%'"

bind C new-session
bind K kill-session
bind R command-prompt -I "#{session_name}" "rename-session '%%'"
bind N switch-client -n
bind P switch-client -p
bind s choose-tree -s
bind d detach-client

bind -n M-1 select-window -t :=1
bind -n M-2 select-window -t :=2
bind -n M-3 select-window -t :=3
bind -n M-4 select-window -t :=4
bind -n M-5 select-window -t :=5
bind -n M-6 select-window -t :=6
bind -n M-7 select-window -t :=7
bind -n M-8 select-window -t :=8
bind -n M-9 select-window -t :=9
bind -n M-Left previous-window
bind -n M-Right next-window
bind -n M-Up switch-client -p
bind -n M-Down switch-client -n

bind -n C-M-Left select-pane -L
bind -n C-M-Right select-pane -R
bind -n C-M-Up select-pane -U
bind -n C-M-Down select-pane -D
bind -n C-M-S-Left resize-pane -L 5
bind -n C-M-S-Right resize-pane -R 5
bind -n C-M-S-Up resize-pane -U 5
bind -n C-M-S-Down resize-pane -D 5

bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel
TMUX

cat >"$HOME/.local/bin/tdl" <<'SH'
#!/usr/bin/env bash
set -Eeuo pipefail

[[ -n "${TMUX:-}" ]] || {
  echo "tdl precisa rodar dentro de uma sessao tmux." >&2
  exit 1
}

agent_one="${1:-}"
agent_two="${2:-}"
editor="${EDITOR:-nvim}"

tmux rename-window "dev"
tmux send-keys "$editor ." C-m
tmux split-window -h -p 40 -c "#{pane_current_path}"

if [[ -n "$agent_one" ]]; then
  tmux send-keys "$agent_one" C-m
fi

tmux split-window -v -p 30 -c "#{pane_current_path}"

if [[ -n "$agent_two" ]]; then
  tmux send-keys "$agent_two" C-m
fi

tmux select-pane -L
SH

cat >"$HOME/.local/bin/tdlm" <<'SH'
#!/usr/bin/env bash
set -Eeuo pipefail

[[ -n "${TMUX:-}" ]] || {
  echo "tdlm precisa rodar dentro de uma sessao tmux." >&2
  exit 1
}

agent_one="${1:-}"
agent_two="${2:-}"

for dir in */; do
  [[ -d "$dir" ]] || continue
  tmux new-window -c "$PWD/$dir" -n "${dir%/}" "tdl ${agent_one} ${agent_two}; exec ${SHELL:-bash}"
done
SH

cat >"$HOME/.local/bin/tsl" <<'SH'
#!/usr/bin/env bash
set -Eeuo pipefail

[[ -n "${TMUX:-}" ]] || {
  echo "tsl precisa rodar dentro de uma sessao tmux." >&2
  exit 1
}

count="${1:-}"
shift || true
command="${*:-}"

[[ "$count" =~ ^[0-9]+$ ]] || {
  echo "Uso: tsl <quantidade> <comando>" >&2
  exit 1
}

[[ -n "$command" ]] || {
  echo "Uso: tsl <quantidade> <comando>" >&2
  exit 1
}

tmux rename-window "swarm"
tmux send-keys "$command" C-m

for _ in $(seq 2 "$count"); do
  tmux split-window -c "#{pane_current_path}"
  tmux select-layout tiled >/dev/null
  tmux send-keys "$command" C-m
done

tmux select-layout tiled >/dev/null
SH

chmod +x "$HOME/.local/bin/tdl" "$HOME/.local/bin/tdlm" "$HOME/.local/bin/tsl"

info "Atualizando ~/.zshrc com Starship, zoxide, fzf e aliases."
touch "$HOME/.zshrc"
ensure_line "$HOME/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
ensure_line "$HOME/.zshrc" '[[ $- == *i* ]] && command -v fastfetch >/dev/null 2>&1 && fastfetch'
ensure_line "$HOME/.zshrc" 'source "$HOME/.config/zsh/completions.zsh"'
ensure_line "$HOME/.zshrc" 'eval "$(starship init zsh)"'
ensure_line "$HOME/.zshrc" 'eval "$(zoxide init zsh)"'
ensure_line "$HOME/.zshrc" 'alias n="nvim"'
ensure_line "$HOME/.zshrc" 'alias t="tmux new-session -A -s main"'
ensure_line "$HOME/.zshrc" 'alias sysinfo="fastfetch"'
ensure_line "$HOME/.zshrc" 'alias ls="eza --icons=auto --group-directories-first"'
ensure_line "$HOME/.zshrc" 'alias ll="eza -la --icons=auto --group-directories-first"'
ensure_line "$HOME/.zshrc" 'alias lsa="eza -la --icons=auto --group-directories-first"'
ensure_line "$HOME/.zshrc" 'alias lt="eza --tree --level=2 --icons=auto --group-directories-first"'
ensure_line "$HOME/.zshrc" 'alias lta="eza --tree --level=2 -a --icons=auto --group-directories-first"'
ensure_line "$HOME/.zshrc" 'alias ff="fzf --preview '\''bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || sed -n \"1,200p\" {}'\''"'
ensure_line "$HOME/.zshrc" 'alias cat="bat --paging=never 2>/dev/null || command cat"'

touch "$HOME/.bashrc"
ensure_line "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
ensure_line "$HOME/.bashrc" 'eval "$(zoxide init bash)"'
ensure_line "$HOME/.bashrc" 'alias n="nvim"'
ensure_line "$HOME/.bashrc" 'alias t="tmux new-session -A -s main"'
ensure_line "$HOME/.bashrc" 'alias sysinfo="fastfetch"'
ensure_line "$HOME/.bashrc" 'alias ls="eza --icons=auto --group-directories-first"'
ensure_line "$HOME/.bashrc" 'alias ll="eza -la --icons=auto --group-directories-first"'
ensure_line "$HOME/.bashrc" 'alias lsa="eza -la --icons=auto --group-directories-first"'
ensure_line "$HOME/.bashrc" 'alias lt="eza --tree --level=2 --icons=auto --group-directories-first"'
ensure_line "$HOME/.bashrc" 'alias lta="eza --tree --level=2 -a --icons=auto --group-directories-first"'
ensure_line "$HOME/.bashrc" 'alias ff="fzf --preview '\''bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || sed -n \"1,200p\" {}'\''"'

info "Configurando Starship com caminho completo, Git, hora e bateria."
ensure_dir "$HOME/.config"
cat >"$HOME/.config/starship.toml" <<'TOML'
add_newline = true
command_timeout = 1000

format = """
$username\
$directory\
$git_branch\
$git_status\
$cmd_duration\
$fill\
$shell\
$battery\
$time\
$line_break\
$character"""

[fill]
symbol = " "

[username]
show_always = true
format = "[](fg:#c678dd)[ $user ](fg:#ffffff bg:#c678dd bold)[ ](fg:#c678dd)"

[directory]
format = "[](fg:#ff5fa2)[  $path ](fg:#ffffff bg:#ff5fa2 bold)[ ](fg:#ff5fa2)"
style = "bold #7aa2f7"
truncation_length = 0
truncate_to_repo = false
read_only = " 󰌾"
home_symbol = "~"

[git_branch]
format = "[](fg:#7c6fdd)[ $symbol$branch ](fg:#ffffff bg:#7c6fdd bold)"
symbol = " "
style = "bold #ffffff"

[git_status]
format = "[$all_status$ahead_behind ](fg:#ff6b6b bg:#7c6fdd bold)[ ](fg:#7c6fdd)"
style = "bold #ff6b6b"
conflicted = "=${count} "
ahead = "⇡${count} "
behind = "⇣${count} "
diverged = "⇕⇡${ahead_count}⇣${behind_count} "
up_to_date = ""
untracked = "?${count} "
stashed = "$${count} "
modified = "!${count} "
staged = "+${count} "
renamed = "»${count} "
deleted = "x${count} "

[cmd_duration]
min_time = 1000
format = "[](fg:#6c7086)[  $duration ](fg:#ffffff bg:#6c7086 bold)[ ](fg:#6c7086)"
style = "bold #ffffff"

[shell]
disabled = false
format = "[](fg:#1e88e5)[  $indicator ](fg:#ffffff bg:#1e88e5 bold)[ ](fg:#1e88e5)"
zsh_indicator = "zsh"
bash_indicator = "bash"
powershell_indicator = "pwsh"
unknown_indicator = "sh"

[battery]
format = "[](fg:#4caf50)[ $symbol $percentage ](fg:#111111 bg:#4caf50 bold)[ ](fg:#4caf50)"
full_symbol = "󰁹"
charging_symbol = "󰂄"
discharging_symbol = "󰂃"
unknown_symbol = "󰁽"
empty_symbol = "󰂎"
disabled = false

[[battery.display]]
threshold = 100
style = "bold #111111"

[aws]
format = "[](fg:#f9c74f)[  ($profile )($region) ](fg:#111111 bg:#f9c74f bold)[ ](fg:#f9c74f)"
symbol = ""
style = "bold #111111"

[time]
disabled = false
format = "[](fg:#26a69a)[  $time ](fg:#111111 bg:#26a69a bold)[](fg:#26a69a)"
time_format = "%H:%M:%S"
style = "bold #111111"

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
TOML

if [[ "${SHELL:-}" != "$(command -v zsh)" ]]; then
  info "Alterando shell padrao do usuario para zsh."
  sudo chsh -s "$(command -v zsh)" "$USER"
else
  info "zsh ja e o shell padrao."
fi

info "Shell concluido. Reinicie o terminal para entrar no zsh."
