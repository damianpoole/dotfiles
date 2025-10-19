#!/bin/sh

source "$HOME/.config/sketchybar/colors.sh" # Loads all defined colors
PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

echo "Battery percentage: $PERCENTAGE"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
9[0-9] | 100)
  BACKGROUND=$GREEN
  ICON=""
  ;;
[6-8][0-9])
  BACKGROUND=$YELLOW
  ICON=""
  ;;
[3-5][0-9])
  BACKGROUND=$ORANGE
  ICON=""
  ;;
[1-2][0-9])
  BACKGROUND=$RED
  ICON=""
  ;;
*)
  BACKGROUND=$RED
  ICON=""
  ;;
esac

if [[ "$CHARGING" != "" ]]; then
  BACKGROUND=$BLUE
  ICON=""
fi
echo "$BACKGROUND"
# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" background.color=$BACKGROUND
