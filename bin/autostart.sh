#!/bin/sh

swayidle -w \
	timeout 300 'hyprctl dispatch dpms off' \
	resume 'hyprctl dispatch dpms on' &

wlsunset -t 4500 -T 6500 -l -1 -L -1 -g 1.0 &

wl-paste -t text --watch clipman store --no-persist &

swaybg --color '#282828' &

ironbar &

dbus-daemon --session --address=unix:path=$XDG_RUNTIME_DIR/bus &

mako
