# ── Applications ─────────────────────────────────────────────

export EDITOR="nvim"
export VISUAL="$EDITOR"
export BROWSER="qutebrowser"
export TERMINAL="foot"
export READER="zathura"
export IMAGE="swayimg"
export VIDEO="mpv"
export OPENER="open"

export PAGER="nvimpager"
export MANPAGER="$PAGER"


# ── XDG Base Directories ─────────────────────────────────────

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"


# ── PATH ─────────────────────────────────────────────────────

export PATH="$HOME/.local/bin:$HOME/.dotfiles/bin:$PATH"


# ── Application data ─────────────────────────────────────────

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
export GOPATH="$XDG_DATA_HOME/go"
export CARGO_HOME="$XDG_DATA_HOME/cargo"


# ── Zsh ──────────────────────────────────────────────────────

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_CACHE_HOME/zsh/history"


# ── fzf ──────────────────────────────────────────────────────

export FZF_DEFAULT_OPTS="-i --layout=reverse"
