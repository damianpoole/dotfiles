#!/bin/sh

if [ "$SENDER" = "front_app_switched" ]; then
  ICON=$($HOME/.config/sketchybar/plugins/icon_map.sh "$INFO")
  sketchybar --set "$NAME" label="$ICON" label.padding_left=7 label.padding_right=7 label.font="sketchybar-app-font:Regular:14.0" label.color=0xffffffff label.drawing=on
fi
