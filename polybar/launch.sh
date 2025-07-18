#!/usr/bin/env sh

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar bspwm &

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload bspwm &
  done
else
 polybar --reload bspwm &
fi


polybar bspwm -c ~/.config/polybar/config.ini &
