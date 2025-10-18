#!/bin/sh

if [ "$SENDER" = "front_app_switched" ]; then
  ICON=$($HOME/.config/sketchybar/plugins/icon_map.sh "$INFO")
  sketchybar --set "$NAME" label="$ICON" icon.padding_left=10 label.font="sketchybar-app-font:Regular:15.0" label.color=0xffffffff label.drawing=on
fi
