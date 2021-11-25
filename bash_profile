#!/bin/sh
# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

# Environment variables
export EDITOR="vim"
export BROWSER="qutebrowser"
export TERMINAL="st"

# This is for lf
export OPENER="open"

# Have less display colours
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
# Percentage and line count for man pages
export MANPAGER='less -s -M +Gg'

export PATH="$PATH:$HOME/.local/bin:$HOME/.dotfiles/bin"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc"
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export XAUTHORITY="$XDG_RUNTIME_DIR/Xauthority"
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/shell/inputrc"
export LESSHISTFILE="-"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="${XDG_CONFIG_HOME:-$HOME/.config}"/java

# Having a "gtk3" value works on Void Linux for the font size
# (tested only with KeePassXC)
# On Arch/Artix, having a "gtk2" value should work
export QT_QPA_PLATFORMTHEME="gtk3"	# Have Qt use GTK theme

export MOZ_USE_XINPUT2="1"		# Mozilla smooth scrolling/touchpads
export _JAVA_AWT_WM_NONREPARENTING=1	# Fix for Java applications in dwm

# Automatically start X session if logged on tty1.
if [ "$(tty)" = "/dev/tty1" ]; then
	pgrep -x dwm || exec startx "$XINITRC"
fi
