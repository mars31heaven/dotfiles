# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# doas not required for some system commands
for command in zzz shutdown sv ; do
	alias $command="doas $command"
done; unset command

# Test if ~/.config/shell/shortcutrc and ~/.config/shell/aliasrc exists and source them
[ -f ~/.config/shell/aliasrc ] && source ~/.config/shell/aliasrc
[ -f ~/.config/shell/shortcutrc ] && source ~/.config/shell/shortcutrc

PS1='\w > '

# Infinite history
HISTSIZE= HISTFILESIZE=
# Keep repeated identical commands from being logged
export HISTCONTROL=ignoredups

# For mpc tab completion
source "/usr/share/doc/mpc/contrib/mpc-completion.bash"

# open files with fzf
o() {
	open "$(find -type f | fzf)"
}

# cd with fzf
fcd() {
	cd "$(find -type d | fzf)"
}

# fff cd on exit
f() {
	fff "$@"
	cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

# Autogenerate .m3u playlist files
play() {
	for f in *.mp3; do echo "$f" >> play.m3u; done
}

# Open another terminal on the current working directory
samedir() {
	setsid -f "$TERMINAL"
}
