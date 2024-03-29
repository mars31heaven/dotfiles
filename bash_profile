#!/bin/sh
# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# Environment variables
export EDITOR="vim"
export VISUAL="vim"
export BROWSER="qutebrowser"
export TERMINAL="st"
export READER="zathura"
export IMAGE="nsxiv"
export VIDEO="mpv"
export PATH="$PATH:$HOME/.local/bin":"$HOME/.dotfiles/bin"

# This is for lf
export OPENER="open"

# XDG Based Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/shell/inputrc"
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.local/cache}/bash_history"
export LESSHISTFILE="-"
export NOTMUCH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/notmuch-config"
export MBSYNCRC="${XDG_CONFIG_HOME:-$HOME/.config}/mbsync/mbsyncrc"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot="${XDG_CONFIG_HOME:-$HOME/.config}"/java"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"

# Having a "gtk3" value works on Void Linux for the font size
# (tested only with KeePassXC)
# On Arch/Artix, having a "gtk2" value should work
export QT_QPA_PLATFORMTHEME="gtk3"	# Have Qt use GTK theme

# Other programs settings
export MOZ_USE_XINPUT2="1"		# Mozilla smooth scrolling/touchpads
export _JAVA_AWT_WM_NONREPARENTING=1	# Fix for Java applications in dwm
export JAVA_FONTS="/usr/share/fonts/TTF"
export _JAVA_OPTIONS="-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
export FZF_DEFAULT_OPTS="-i --layout=reverse"
export HSTR_CONFIG="hicolor,raw-history-view"

# Ensure synchronization between bash memory and history file
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

# Have less display colours
export LESS="-R"
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"

# Automatically start X session if logged on tty1.
if [ "$(tty)" = "/dev/tty1" ]; then
	pgrep -x dwm || exec startx "$XINITRC"
fi
