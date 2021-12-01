#!/bin/sh
# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# Environment variables
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="qutebrowser"
export TERMINAL="st"
export READER="zathura"
export IMAGE="nsxiv"
export VIDEO="mpv"

# This is for lf
export OPENER="open"

export PATH="$PATH:$HOME/.local/bin":"$HOME/.dotfiles/bin"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc"
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/shell/inputrc"
export LESSHISTFILE="-"
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.local/cache}/bash_history"
export _JAVA_OPTIONS="-Djava.util.prefs.userRoot="${XDG_CONFIG_HOME:-$HOME/.config}"/java"
export _JAVA_OPTIONS="-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"

# Having a "gtk3" value works on Void Linux for the font size
# (tested only with KeePassXC)
# On Arch/Artix, having a "gtk2" value should work
export QT_QPA_PLATFORMTHEME="gtk3"	# Have Qt use GTK theme

export MOZ_USE_XINPUT2="1"		# Mozilla smooth scrolling/touchpads
export _JAVA_AWT_WM_NONREPARENTING=1	# Fix for Java applications in dwm
export JAVA_FONTS="/usr/share/fonts/TTF"

export FZF_DEFAULT_OPTS="-i --layout=reverse"

# Have less display colours
#export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
#export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
#export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
#export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
#export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
#export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
#export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
# Percentage and line count for man pages
#export MANPAGER='less -s -M +Gg'

export LESS=-R
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
