#!/bin/sh
echo "$INFO"
if [ "$SENDER" = "front_app_switched" ]; then
  bar=(
    label=$INFO
    padding_left=6
    padding_right=5
  )
  sketchybar --set "$NAME" "${bar[@]}"
fi
