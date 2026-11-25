# dotfiles

Personal dotfiles for Arch Linux and Artix Linux with Sway and Zsh, tailored to my own workflow. The desktop PC is the main machine; the laptop is secondary. This file documents how the system is put together.

## Machines

| | Desktop PC (main) | Laptop |
|---|---|---|
| CPU | AMD | Intel |
| Distribution | Arch (systemd) | Arch (systemd) or Artix (runit) |
| Kernel | linux-zen | distribution default |
| Display | two monitors: HDMI-A-1 (1920x1080) on the left, DP-1 (1600x900) on the right | built-in eDP-1, optional HDMI-A-2 |
| Music | MPD (systemd user service) + rmpc, scrobbling with mpdscribble | mpv |
| Power | none | TLP + thermald (Arch); none on Artix by choice |
| Networking | NetworkManager (with wpa_supplicant) | dhcpcd + iwd |
| Login | tty1 autologin, `zprofile` starts Sway | same |

Machine-specific files use the suffixes `.pc` and `.laptop`. The installer links the right one under the plain name:

| Program | Repository files | Linked as |
|---|---|---|
| Sway | `config/sway/config.*` | `~/.config/sway/config` |
| Waybar | `config/waybar/config.jsonc.*`, `style.css.*` | `~/.config/waybar/` |
| foot | `config/foot/foot.ini.*` | `~/.config/foot/foot.ini` |
| Fuzzel | `config/fuzzel/fuzzel.ini.*` | `~/.config/fuzzel/fuzzel.ini` |
| Shell | `config/shell/{pc,laptop}` | `~/.config/shell/` |

PC only: `mpd`, `rmpc`. Everything else is shared.

## Installation

```bash
git clone <repository-url> ~/.dotfiles
cd ~/.dotfiles
./install
```

Run it as the normal user. The user needs sudo first (`usermod -aG wheel <user>` and enable `%wheel` with `visudo`). The installer asks for laptop or desktop and checks the CPU vendor (Intel for the laptop, AMD for the PC). It then:

1. configures pacman (Color, 10 parallel downloads) and, on Artix, enables Arch's `extra` and `multilib`,
2. installs the official packages for the machine, then the AUR packages with `yay`,
3. enables services: systemd units, or runit services resolved from the `*-runit` packages; on the PC also NetworkManager and the MPD user service,
4. sets up tty1 autologin (systemd), UFW, journald and sudoers,
5. links the configuration, creates local state folders and installs the Neovim plugins from `lazy-lock.json`,
6. sets Zsh as the login shell,
7. applies the laptop power settings.

It can run again. Wrong symlinks are replaced, and a real file in the way is renamed to `*.bak.TIMESTAMP`. Failed AUR packages are listed at the end and do not stop the install.

Choices worth knowing:

- **UFW:** open for KDE Connect (1714-1764, TCP and UDP) and SSH. Logging is off.
- **journald:** volatile storage, limited to 50 MB, to reduce writes.
- **sudoers:** `pacman`, `reboot`, `poweroff` and `nvim` run without a password.
- **NetworkManager:** enabled on the PC but never restarted by the installer, so the connection does not drop.
- **Arch laptop:** TLP with the M-Audio Fast Track Pro (`0763:2012`) excluded from USB autosuspend, thermald, and the Bluetooth radio blocked at boot while `bluetooth.service` runs.
- **Artix laptop:** no TLP or thermald, a udev rule that gives the `video` group write access to the backlight, and `bluetoothd` that starts only on demand.

## Layout

```
bin/        scripts, on PATH through zshenv
config/     one folder per program, linked into ~/.config
share/      applications, wallpapers, sounds, linked into ~/.local/share
zshenv      environment, linked to ~/.zshenv
install     the installer
```

`config/lf/preview` is also linked as `~/.local/bin/preview`, because the `o` function looks for it on `PATH`.

## Environment (`zshenv`)

- **Programs:** editor and visual `nvim`, browser `qutebrowser`, terminal `foot`, reader `zathura`, images `swayimg`, video `mpv`, opener `open`, pager `nvimpager` (also the man pager).
- **PATH:** `~/.local/bin`, then `~/.dotfiles/bin`.
- **XDG:** config, cache and data homes are the defaults. GnuPG, the password store, Go, Cargo and the Python bytecode cache are moved under them.
- **Zsh:** `ZDOTDIR` is `~/.config/zsh`, and history is `~/.cache/zsh/history`.
- **ydotool:** `ydotool` is installed on the PC and its socket is set to `$XDG_RUNTIME_DIR/ydotool/.socket`. The installer does not start its daemon.
- **fzf:** case-insensitive, reverse layout.

## Sway

Mod key is Super. Vim keys (`h j k l`) move focus, and `Shift` moves windows. Borders are one pixel, light grey on the focused window. `autotiling --limit 2` runs on both machines. The wallpaper is `share/wallpapers/mar.jpg`. The cursor hides after 5 seconds and while typing. Clipboard history comes from `cliphist`.

### Shared keys

| Keys | Action |
|---|---|
| `Mod+d` | Fuzzel launcher |
| `Mod+w` | qutebrowser |
| `Mod+Shift+q` | Close window |
| `Mod+Shift+Return` | Floating foot (800x500, centered) |
| `Mod+f` | Fullscreen |
| `Mod+Shift+Space`, `Mod+Space` | Toggle floating, swap tiling and floating focus |
| `Mod+a` | Focus parent |
| `Mod+1..9` | Workspace (the laptop has 1..6) |
| `Mod+Shift+1..9` | Move window to workspace |
| `Mod+i` / `Mod+o` | Previous or next workspace |
| `Mod+Tab` | Back and forth |
| `Mod+r` | Resize mode (`h j k l`, Escape to leave) |
| `Mod+Shift+minus`, `Mod+minus` | Send to scratchpad, show scratchpad |
| `Mod+p` | `fuzzpass` (password menu) |
| `Mod+Shift+r` | `fuzzrec` |
| `Mod+v` | Clipboard history through Fuzzel |
| `Mod+F4`, `Mod+Shift+F4` | Start or stop `wlsunset` (night light) |
| `Mod+F12` | `itoggle` |
| `Mod+Shift+Backspace` | Power menu (`fuzzpowerpc` or `fuzzpowerlaptop`) |
| `Ctrl+Space` | Dismiss all notifications |
| `Mod+Shift+c`, `Mod+Shift+End` | Reload config, exit Sway |
| `Print`, `Shift+Print`, `Shift+Ctrl+Print`, `Mod+Print` | Screenshot: full, region, region to clipboard, region to swappy |

Volume, microphone, media and brightness keys use `pactl`, `playerctl` and `brightnessctl`.

### Desktop PC

- **Monitors:** the left and right outputs are set explicitly. `Mod+Ctrl+h/l` focuses the left or right monitor. `Mod+Ctrl+Shift+h/l` moves the window there and follows it.
- **Persistent terminal workspace:** at login, foot starts with the app-id `foot-tmux` on workspace 1 and attaches to the tmux session through `tmuxattach`. Closing it by accident is harmless, because `tmuxgo` opens a new foot and reattaches.
  - `Mod+Return`: focus the last active tmux window and pane
  - `Mod+Shift+m` / `Mod+Shift+e` / `Mod+Shift+n`: tmux windows for `lf`, `nvim`, `wiki`
  - `Mod+Shift+t`: a fresh Zsh window
- **rmpc:** it runs outside tmux, in its own foot on workspace 5, for image rendering. `Mod+m` focuses it (`focusorrun`).
- **Other keys:** `Mod+Shift+w` Waterfox, `Mod+Ctrl+w` Thunderbird, `Mod+Shift+f` fsearch, `Mod+Ctrl+m` `fuzzmpd`, `Mod+c` date, time and weather popup, `Mod+Ctrl+c` full weather popup.
- **Idle:** the screens turn off after 300 seconds. Reaper inhibits idle.

### Laptop

- **Input:** Brazilian ABNT2 layout, Caps Lock as Escape, tap to click and natural scrolling.
- **Monitors:** `Mod+F1` built-in only, `Mod+F2` HDMI only, `Mod+F3` both. The first also starts night light.
- **Keys:** `Mod+Return` foot, `Mod+Shift+e` foot with nvim, `Mod+Shift+m` foot with lf, `Mod+Shift+v` wiremix, `Mod+Home` htop, `Mod+Shift+w` Waterfox, `Mod+F11` and `Mod+Shift+F11` screens off and on. Extra layout bindings: `Mod+b/n` split, `Mod+s/t/e` layouts.
- **Idle:** the screens turn off after 200 seconds, and it suspends after 600. Reaper, DuckStation and mpv inhibit idle.
- **Battery:** `batsignal` warns at 25%, 20% and 15%, and suspends at the last level.

## Bar and launcher

- **Waybar:** workspaces and the window title on the left, clock and tray on the right. The laptop adds the battery. Bar height and font size differ per machine.
- **Fuzzel:** vim-style `Ctrl+n/p/j/k` navigation. `Ctrl+k` is freed from "delete to end of line".
- **Mako:** notifications.

## Terminal

- **foot:** monospace at 10.8 pt on the PC and 10 pt on the laptop, 0.9 opacity, a dark palette (background `101010`, accent `de7484`), URLs open in qutebrowser (`Ctrl+Shift+o` shows them).
- **tmux:** prefix `Alt+Space`. Everything below uses Alt directly, with no prefix. Windows are named, because `tmuxgo` finds them by name.

| Keys | Action |
|---|---|
| `Alt+v` / `Alt+b` | Split side by side / stacked, in the current directory |
| `Alt+h/j/k/l` | Move between panes |
| `Alt+H/J/K/L` | Resize by 5 cells |
| `Alt+f` | Zoom pane |
| `Alt+Shift+q` | Kill pane |
| `Alt+Enter` | New Zsh window |
| `Alt+1..9`, `Alt+i`, `Alt+o` | Windows: by number, previous, next |
| `Alt+c` | Copy mode (`v` selects, `y` copies to the Wayland clipboard) |

The status bar shows the MPD track (`mpc current`).

## Shell (Zsh)

`zshrc` loads `aliasrc`, `shortcutrc`, `functionrc`, the machine file (`pc` or `laptop`) and an optional local `private` file that is not in the repository.

- **Behavior:** vi mode with a 10 ms key timeout, history of 100,000 lines shared between sessions without duplicates, `autocd`, `globdots`, case-insensitive globbing, completion menu with `h j k l`. Navigation commands (`ls`, `l`, `ll`, `t`, `o`, `lfcd` and a few more) stay out of the history.
- **Plugins:** autosuggestions, syntax highlighting, history substring search (Up and Down, `j`/`k` in command mode), fzf key bindings and completion, zoxide.
- **Prompt:** ` [host] path $`. The host is blue on the PC and orange on the laptop.
- **Keys:** `Ctrl+o` opens lf and `cd`s to where it ended, `Ctrl+f` is a fuzzy `cd`, `Ctrl+a` opens `bc`, `Ctrl+e` opens the editor, `Ctrl+v` edits the command line in the editor.
- **Machine files:** `sus`, `rbt` and `pwr` call `systemctl` on the PC and `loginctl` on the laptop. The laptop also has `bup`, `bdown`, `wup` and `wdown` for the runit Bluetooth and iwd services.

### Aliases (`aliasrc`)

- **Root:** `mount`, `umount`, `reboot`, `poweroff`, `shutdown`, `pacman` and `rsm` run with sudo. `vv` is `sudo nvim`.
- **Safer basics:** `rm -Iv`, `cp -riv`, `mv -iv`, `mkdir -p`, `grep -i --color`.
- **Pacman and yay:** `p`, `pyu` (update), `y`, `rmpkg`, `ph` (pacman log), `fixpacman` (remove the lock), `big` (largest packages), `cleanup` (orphans), `exr` and `latest` (recent installs).
- **Listing and navigation:** `eza`-based `l`, `ll`, `lll`, `lr`, `lt`, `l.`, `lh`, `lhr`, `t`. `..` up to `......` go up directories. `cat` is `bat`.
- **Git:** `gi`, `gst`, `gcl`, `gdi`, `gad`, `glo`, `gre`, `gcm`, `gca`, `gpu`.
- **Media:** `ytdl`, `yta` (audio only), `mm` (mpv music profile), `findflac`, `burncdr`.
- **albumlog:** `al`, `ald` (add), `als` (stats), `aw` (wishlist), `awd` (wishlist add).
- **MPD:** `mpfile` and `mpinfo` show the current track.

### Directory shortcuts (`shortcutrc`)

`h` home, `d` Documents, `D` Downloads, `m` Music, `P` Pictures, `V` Videos, `dfs` dotfiles with git status, `dx` dotfiles `bin`, `dcf` dotfiles `config`, `x` `~/.local/bin`, `shr` `~/.local/share`, `src` `~/.local/src`, `cf` `~/.config`, `ca` `~/.cache`, `M` `/mnt`, `T` `/tmp`. lf has the same set under `g` (for example `gdf`, `gx`, `gHd1`).

### Functions (`functionrc`)

- **Files:** `o` (fuzzy file picker with preview, then `open`), `lfcd`, `fcd`, `rotate DEG FILE` (lossless JPEG rotation), `ipa` (local IP).
- **MPD:**
  - queue and playlists: `mpload`, `mpappend`, `mpsave`, `mpaddcurrent`, `mpaddcurrentfzf`
  - search and albums: `mpsearch`, `mpalbum`, `mpaddalbum`, `mpplayalbum`, `mpaddalbumfzf`, `mpplayalbumfzf`
  - random: `rad` and `rac` (random album, add or replace), `mprand [N]`
  - tracks and library: `mpadd`, `mpnextfzf` (insert after the current track), `mproots`, `mpupdatepath`

## File manager (lf)

Shell is bash, with previews from `config/lf/preview` (text, Markdown, media and image metadata, EPUB, office and PDF, HTML and archives, through `bat`, `mediainfo`, `exiv2`, `mdcat`, `batdoc`, `w3m` and others). The same script is linked as `~/.local/bin/preview`.

| Key | Action |
|---|---|
| `f` | Fuzzy file search from here, then jump to the file |
| `z` / `Z` | Fuzzy directory below here / zoxide history |
| `e`, `E` | Edit in nvim, run an nvim command |
| `x`, `y`, `p`, `D` | Cut, copy, paste, delete |
| `v`, `V`, `U` | Toggle selection, invert, unselect |
| `A`, `B` | Rename, bulk rename (`vidir`) |
| `X` | Extract an archive |
| `m`, `N` | Make a directory, create a file |
| `.` | Show or hide hidden files |
| `u`, `d` | Half page up, down |
| `Ctrl+y` | Copy the path to the clipboard |
| `W` | New terminal here |
| `g…` | Directory shortcuts |

## Music

- **PC:** MPD (`config/mpd/mpd.conf`) runs as a systemd user service, plays through PipeWire from `~/Music` and listens on `127.0.0.1`. Control it with `systemctl --user status mpd`. rmpc is the client, with `fuzzmpd`, the `mp*` functions and the tmux status as shortcuts. `mpdscribble` scrobbles; its config holds credentials and stays local.
- **Laptop:** mpv only.
- **mpv:** a `music` profile (alias `mm`), MPRIS support, and `librefmscrobbler.lua` with `bin/librefmscrobbler`. Its state is `~/.local/cache/librefm.journal`, and `librefmscrobbler.conf.example` is a template for the local config.

## Neovim

Plugins are managed by lazy.nvim, which bootstraps itself on the first run. Versions are pinned in `lazy-lock.json`, and the installer restores them. The leader key is Space.

- **Plugins:** fzf-lua (files, grep, buffers, `ui.select`), oil.nvim (file manager, edit the filesystem like a buffer), oil-copy.nvim, and Vimwiki.
- **Look:** the same palette as the rest of the system (`313131` background, `de7484` accent), a minimal statusline with file, directory, filetype and position.
- **Behavior:** relative line numbers, system clipboard (`unnamedplus`), 4-space indents, no swap file but persistent undo, last cursor position restored, trailing whitespace removed on save, no automatic comment continuation. Markdown and text wrap at words.
- **Vimwiki:** Markdown wiki in `~/Documents/Vimwiki/`. `<leader>x` toggles a checkbox. The shell alias `wi` opens the index.

| Keys | Action |
|---|---|
| `<leader>w`, `<leader>q`, `ZZ` | Save, quit, save if modified |
| `<leader>S` | Replace all |
| `<leader>]` / `<leader>[` | Next or previous buffer |
| `<leader>v` / `<leader>-` | Vertical or horizontal split |
| `Ctrl+h/j/k/l` | Move between splits; at the edge, move to the neighbouring tmux pane |
| `Ctrl+arrows` | Resize splits |
| `<leader>t`, `J`, `K`, `d` | New, next, previous, close tab |
| `<leader>h` | Clear search highlight |
| `<leader>en`, `<leader>pt` | Toggle English or Portuguese spellcheck |
| `F5` | Insert date and time |
| `oo`, `OO` | Blank line below or above |

### Navigation (`lua/nav.lua`)

Every tab has its own working directory (`:tcd`). The shell shortcuts from `shortcutrc` work here too.

| Keys | Action |
|---|---|
| `<leader>j NAME` | Jump to a shortcut (`d`, `dfs`, `x`, ...), then pick a file. Fires when unambiguous; Enter confirms. |
| `<leader>l NAME` | Same, but opens Oil |
| `<leader>cc` | Fuzzy jump over shortcuts and zoxide history |
| `<leader>cf` | `fcd`: pick a directory under the current one |
| `<leader>cd` | `:tcd` to this file's directory |
| `<leader>f` | `o`: find files (documents, images and media go to the `open` script) |
| `<leader>g`, `<leader>s` | Live grep, grep the word under the cursor |
| `<leader>o`, `<leader>b` | Recent files, buffers |
| `<leader>e`, `-` | Oil |
| `<leader>n` | New file: pick a directory under home, then type the name |

In the file picker, `Ctrl+o` forces external open and `Ctrl+g` toggles `.gitignore` filtering. In directory pickers, Enter lists files and `Ctrl+e` opens Oil. Directories changed from Neovim are added to zoxide.

## Other programs

- **qutebrowser:** the main browser. `config.py` and two Greasemonkey scripts that hide ratings on Letterboxd and RYM are versioned. History and bookmarks stay local. `python-adblock` is installed.
- **Waterfox:** the secondary browser, started with `Mod+Shift+w`.
- **Others:** newsboat (feeds), zathura (PDF), swayimg (images, `init.lua`), urlscan, htop (with vim keys), GTK 2 and 3 themes and a fontconfig file.

## Scripts (`bin/`)

Grouped by purpose:

| Group | Scripts |
|---|---|
| Launchers and menus | `fuzzmpd`, `fuzzpass`, `fuzzplay`, `fuzzrec`, `fuzzpowerpc`, `fuzzpowerlaptop`, `passmenu`, `focusorrun`, `open`, `footlfcd` |
| tmux workspace | `tmuxattach`, `tmuxgo` |
| Audio and music | `abc`, `albumartworkfix`, `audiorec`, `flac2mp3`, `flac2opus`, `nvimselectopusconvert`, `librefmscrobbler`, `mpf`, `umpv` |
| Photos and video | `compresskodak`, `compressvideos`, `cybershotimagesvariations`, `findphotoduplicates`, `reduzmuitotamvideoxaiomi`, `reduztamvideocybershot`, `webcam` |
| Documents | `md2docx`, `reduztampdf`, `gerarcardsverticais`, `marcarimagensvendas` |
| Files | `lowerext`, `normalizefilesnames`, `clearia`, `fzfpreview` |
| System | `datetimeweather`, `fullweather`, `itoggle`, `syncthingtoggle`, `printersetup`, `getdotfilessymlinks`, `gitautopushsetup` |
| Other | `dig`, `mks`, `share`, `sm` |

`getdotfilessymlinks` lists every symlink pointing into the repository. `gitautopushsetup` creates a systemd timer that pushes a repository daily at 22:00.

## Updating the install script

Everything normally edited is at the top of `install`.

- **Package:** add it to `PKGS_COMMON`, `PKGS_PC`, `PKGS_LAPTOP` or `AUR_PKGS`. To find explicitly installed packages that are missing from the lists:

```bash
pacman -Qqen | sort    # official
pacman -Qqem | sort    # AUR and other foreign
```

- **Symlink:** add `"config/program/file:.config/program/file"` to `LINKS_COMMON`, `LINKS_PC` or `LINKS_LAPTOP`. Use `@MACHINE@` for per-machine files.
- **Service:** add it to `SYSTEMD_NOW_*`, `SYSTEMD_KEEP_PC`, `SYSTEMD_USER_PC` or `SYSTEMD_ENABLE`. For runit, add the `*-runit` package to `PKGS_ARTIX*` and `RUNIT_PKGS_*`.

## Not version-controlled

The password store and GnuPG data, qutebrowser history and bookmarks, mpv and newsboat state, `mpdscribble` and `librefmscrobbler` credentials, Zsh history, the optional `shell/private` file and tokens stay local.
