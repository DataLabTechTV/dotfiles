source $HOME/.config/zsh/env.zsh
source $HOME/.config/zsh/options.zsh

[[ $- != *i* ]] && return

fpath=("$HOME/.config/zsh/functions" $fpath)
autoload -Uz $HOME/.config/zsh/functions/*(N:t)

if [[ "$TERM_PROGRAM" == (alacritty|WezTerm) ]]; then
  command -v tmux >/dev/null 2>&1 &&
    [[ -z "$TMUX" ]] &&
    exec tmux new-session -A -s main
fi

source $HOME/.config/zsh/aliases.zsh
source $HOME/.config/zsh/completion.zsh
source $HOME/.config/zsh/keybinds.zsh
source $HOME/.config/zsh/plugins.zsh
source $HOME/.config/zsh/prompt.zsh

