# dotfiles

Personal dotfiles for Arch Linux and Artix Linux with Sway and Zsh. The desktop PC is the main machine and the laptop is secondary. Config files are commented, so read them for details such as key bindings, aliases and functions.

## Install

```bash
git clone <repository-url> ~/.dotfiles
cd ~/.dotfiles
./install
```

Run it as a normal user with sudo access. It asks whether this is the laptop or the PC, then installs packages, enables services and links the configuration. It can be run again. A real file in the way is renamed to `*.bak.TIMESTAMP`.

To change what it installs or links, edit the lists at the top of `install`.

## Layout

```
bin/        scripts, on PATH through zshenv
config/     one folder per program, linked into ~/.config
share/      applications, wallpapers and sounds, linked into ~/.local/share
zshenv      environment variables
install     the installer
```

Files that differ per machine end in `.pc` or `.laptop`, or are named `pc` and `laptop`. The installer links the right one under the plain name.

## Where to look

- **Key bindings:** `config/sway/`, `config/lf/`, `config/tmux/tmux.conf` and `config/nvim/`.
- **Shell:** `config/shell/` (aliases, shortcuts, functions) and `config/zsh/`.
- **Scripts:** `bin/`. Each script starts with a comment that says what it does.
- **Neovim:** plugins are locked in `config/nvim/lazy-lock.json`.

## Not version-controlled

Passwords and GnuPG data, browser history, app state, credentials, shell history and `config/shell/private` stay local.
