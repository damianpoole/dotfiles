#!/usr/bin/env sh

sketchybar --add event aerospace_workspace_change
RED=0xffed8796
for sid in $(aerospace list-workspaces --all); do
  sketchybar --add item "space.$sid" left \
    --subscribe "space.$sid" aerospace_workspace_change \
    --set "space.$sid" \
    icon="$sid" \
    icon.padding_left=5 \
    icon.padding_right=5 \
    label.padding_right=5 \
    icon.highlight_color=$RED \
    background.color=0x44ffffff \
    background.corner_radius=5 \
    background.height=20 \
    background.drawing=off \
    label.font="sketchybar-app-font:Regular:12.0" \
    label.background.height=14 \
    label.background.drawing=on \
    label.background.color=0xff494d64 \
    label.background.corner_radius=9 \
    label.drawing=off \
    click_script="aerospace workspace $sid" \
    script="$CONFIG_DIR/plugins/aerospacer.sh $sid"
done

sketchybar --add item separator left \
  --set separator icon= \
  icon.font="Hack Nerd Font:Regular:16.0" \
  background.padding_left=5 \
  background.padding_right=5 \
  label.drawing=off \
  associated_display=active \
  icon.color=$WHITE

