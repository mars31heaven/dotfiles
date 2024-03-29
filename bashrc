# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# doas not required for some system commands
for command in zzz reboot poweroff shutdown sv vsv ; do
	alias $command="doas $command"
done; unset command

# Test if files for aliases, shortcuts and
# functions exists and source them
[ -f ~/.config/shell/aliasrc ] && source ~/.config/shell/aliasrc
[ -f ~/.config/shell/shortcutrc ] && source ~/.config/shell/shortcutrc
[ -f ~/.config/shell/functionrc ] && source ~/.config/shell/functionrc

[ -f ~/.config/shell/private ] && source ~/.config/shell/private

PS1='\w > '

# Auto cd when entering a path
shopt -s autocd

# Autocorrect typos in path names when using cd
shopt -s cdspell

# Infinite history size (line count) and file size
export HISTSIZE="-"
export HISTFILESIZE="-"
# Keep repeated identical commands and lines which
# begin with space from being logged
export HISTCONTROL=ignoreboth
# Commands to be ignore from being logged altogether
export HISTIGNORE="cd:cd ..:ls:clear:o:fcd"
# Append new history items
shopt -s histappend
