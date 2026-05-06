# --- Antidote ---

ANTIDOTE_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
PLUGINS_FILE="$HOME/.config/zsh/plugins.txt"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/antidote"
PLUGINS_OUTPUT="$CACHE_DIR/plugins.zsh"

if [[ -r "$ANTIDOTE_HOME/antidote.zsh" && -r "$PLUGINS_FILE" ]]; then
  source "$ANTIDOTE_HOME/antidote.zsh"

  mkdir -p "$CACHE_DIR"

  if [[ ! -r "$PLUGINS_OUTPUT" || "$PLUGINS_FILE" -nt "$PLUGINS_OUTPUT" ]]; then
    antidote bundle <"$PLUGINS_FILE" >"$PLUGINS_OUTPUT"
  fi

  source "$PLUGINS_OUTPUT"
fi


# --- iterm2 (MacOS Only) ---
if [[ "$(uname)" == "Darwin" ]]; then
  [[ -f "$HOME/.iterm2_shell_integration.zsh" ]] &&
    source "$HOME/.iterm2_shell_integration.zsh"
fi


# --- zoxide ---
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi


# --- direnv ---
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi


# --- pyenv ---
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init - zsh)"
fi


# --- fnm (Node version manager) ---
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi


# --- cargo ---
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi


# --- keychain (SSH agent) ---
if command -v keychain >/dev/null 2>&1; then
  ssh_keys=($HOME/.ssh/*.pub)

  if (( ${#ssh_keys[@]} > 0 )); then
    eval "$(keychain --quiet --eval ${ssh_keys[@]%.pub})"
  fi
fi
