export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="qutebrowser"
export TERMINAL="st"
export READER="zathura"
export IMAGE="nsxiv"
export VIDEO="mpv"
export PAGER="nvimpager"
export MANPAGER="nvimpager"
export PATH="$PATH:$HOME/.local/bin":"$HOME/.dotfiles/bin"
export OPENER="open"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_RUNTIME_DIR="/run/user/1000"
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.local/cache}/zsh/history"
export NOTMUCH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/notmuch-config"
export MBSYNCRC="${XDG_CONFIG_HOME:-$HOME/.config}/mbsync/mbsyncrc"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export QT_QPA_PLATFORMTHEME="gtk3"	# Have Qt use GTK theme
export MOZ_USE_XINPUT2="1"		# Mozilla smooth scrolling/touchpads
export _JAVA_AWT_WM_NONREPARENTING=1	# Fix for Java applications in dwm
export JAVA_FONTS="/usr/share/fonts/TTF"
export _JAVA_OPTIONS="-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot="${XDG_CONFIG_HOME:-$HOME/.config}"/java"
export FZF_DEFAULT_OPTS="-i --layout=reverse"
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
