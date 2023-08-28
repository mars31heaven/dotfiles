#!/bin/sh

swayidle -w \
	timeout 300 'hyprctl dispatch dpms off' \
	resume 'hyprctl dispatch dpms on' &

wl-paste -t text --watch clipman store --no-persist &

swaybg --color '#1c1c1c' &

dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus &

/usr/bin/pipewire &
/usr/bin/pipewire-pulse &
/usr/bin/wireplumber &

mako
