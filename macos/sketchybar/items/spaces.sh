#!/usr/bin/env sh

sketchybar --add event aerospace_workspace_change
RED=0xffed8796
for sid in $(aerospace list-workspaces --all); do
  sketchybar --add item "space.$sid" left \
    --subscribe "space.$sid" aerospace_workspace_change \
    --set "space.$sid" \
    icon="$sid" \
    icon.padding_left=10 \
    icon.padding_right=10 \
    label.padding_right=5 \
    background.color=0xffef9f76 \
    background.corner_radius=5 \
    background.height=20 \
    background.drawing=on \
    label.font="sketchybar-app-font:Regular:12.0" \
    label.background.height=14 \
    label.background.drawing=off \
    label.background.color=0x00494d64 \
    label.background.corner_radius=9 \
    label.drawing=off \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospacer.sh $sid"
done

sketchybar --add bracket spacesBracket '/space\..*/' \
  --set spacesBracket background.color=$BACKGROUND_1 background.corner_radius=5 background.drawing=on background.height=20

sketchybar --add item spacesSpacer left \
  --set spacesSpacer padding_right=10 icon=""
