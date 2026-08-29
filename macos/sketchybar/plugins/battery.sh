#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

default=(
  icon.background.height=20
  icon.background.corner_radius=5
  label.padding_left=6
  label.color=$WHITE
  icon.color=$BLACK
  icon.padding_left=7
  icon.padding_right=7
)

case "${PERCENTAGE}" in
9[0-9] | 100)
  bar_update=(
    icon.background.color=$GREEN
    icon=""
  ) 
  ;;
[6-8][0-9])
  bar_update=(
    icon.background.color=$YELLOW
    icon=""
  )
  ;;
[3-5][0-9])
  bar_update=(
    icon.background.color=$ORANGE
    icon=""
  )
  ;;
[1-2][0-9])
  bar_update=(
    icon.background.color=$RED
    icon=""
  )
  ;;
*)
  bar_update=(
    icon.background.color=$RED
    icon=""
  )
  ;;
esac

if [[ "$CHARGING" != "" ]]; then
  bar_update=(
    icon.background.color=$BLUE
    icon=""
  )
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" label="${PERCENTAGE}%" "${default[@]}" "${bar_update[@]}"
