#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

if [ "$SENDER" = "front_app_switched" ]; then
  ICON=$($HOME/.config/sketchybar/plugins/icon_map.sh "$INFO")
  bar=(
    label=$ICON
    background.color=$ICON_BACKGROUND
    label.padding_left=7
    label.padding_right=7
    label.font="sketchybar-app-font:Regular:14.0"
    label.color=$BLACK
    label.drawing=on
    icon.drawing=off
  )
  sketchybar --set "$NAME" "${bar[@]}"
fi
