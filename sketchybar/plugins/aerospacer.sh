#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=on icon.color=$BLACK
else
  sketchybar --set $NAME background.drawing=off icon.color=$WHITE
fi
