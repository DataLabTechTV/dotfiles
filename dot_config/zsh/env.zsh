# --- General ---
export SHELL=/bin/zsh
export EDITOR=vim
export VISUAL=$EDITOR
export PAGER='less -X -F -i'
export BC_ENV_ARGS=$HOME/.bcrc


# --- Z Shell ---
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=100000
WORDCHARS="${WORDCHARS//\/}"


# --- Path ---
typeset -U path
path=(
  $HOME/.local/bin
  $HOME/go/bin
  $HOME/.cargo/bin
  $HOME/.pyenv/bin
  $HOME/.cabal/bin
  $HOME/.config/emacs/bin
  /usr/local/go/bin
  $path
)


# --- MacOS Only ---
if [[ "$(uname)" == "Darwin" ]]; then
  # Java
  export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=1
  command -v /usr/libexec/java_home >/dev/null 2>&1 &&
    export JAVA_HOME=$(/usr/libexec/java_home)

  # PostgreSQL
  path=("/opt/homebrew/opt/postgresql@15/bin" $path)
  export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
  export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
fi


# --- WSL2 only ---
if uname -r | grep -q WSL2; then
  export BROWER=wslview
fi


# --- pyenv ---
export CLOUDSDK_PYTHON_SITEPACKAGES=1
export CLOUDSDK_PYTHON="$(command -v python)"


# --- podman ---
if command -v podman >/dev/null 2>&1; then
  export DOCKER_HOST="unix://$(podman info --format '{{.Host.RemoteSocket.Path}}')"
  export REGISTRY_AUTH_FILE="$HOME/.config/containers/auth.json"
fi


# --- homebrew ---
export HOMEBREW_NO_ENV_HINTS=1
