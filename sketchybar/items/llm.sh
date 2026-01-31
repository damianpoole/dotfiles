#!/usr/bin/env sh

source "$HOME/.config/sketchybar/colors.sh"

LLM_ICON_COLOR=${LLM_ICON_COLOR:-$BLACK}
LLM_ICON_BACKGROUND=${LLM_ICON_BACKGROUND:-$MAUVE}
LLM_ITEM_BACKGROUND=${LLM_ITEM_BACKGROUND:-$BACKGROUND_1}

llm_base=(
  icon.font="Hack Nerd Font:Regular:13.0"
  icon.color=$LLM_ICON_COLOR
  icon.padding_left=6
  icon.padding_right=4
  icon.background.drawing=on
  icon.background.color=$LLM_ICON_BACKGROUND
  icon.background.height=20
  icon.background.corner_radius=5
  label="--"
  label.drawing=on
  label.padding_left=6
  label.padding_right=8
  background.drawing=on
  background.color=$LLM_ITEM_BACKGROUND
  background.height=20
  background.corner_radius=5
)

llm_providers=(
  "copilot::right"
  "gemini::popup.llm_copilot"
  "cursor::popup.llm_copilot"
)

for entry in "${llm_providers[@]}"; do
  IFS=':' read -r provider icon position <<EOF
$entry
EOF

  name="llm_${provider}"
  item=(
    "${llm_base[@]}"
    icon="$icon"
  )

  case "$provider" in
    copilot)
      item+=(
        update_freq=$LLM_UPDATE_FREQ
        icon.font="Hack Nerd Font:Regular:14.0"
        icon.padding_left=7
        icon.padding_right=4
        padding_right=5
        click_script="$PLUGIN_DIR/llm_usage.sh --toggle"
        script="$PLUGIN_DIR/llm_usage.sh"
        popup.background.color=$BACKGROUND_1
        popup.background.corner_radius=5
        popup.background.drawing=on
      )
      ;;
    *)
      item+=(
        background.padding_left=5
        background.padding_right=5
      )
      ;;
  esac

  sketchybar --add item "$name" "$position" \
             --set "$name" "${item[@]}"
done
