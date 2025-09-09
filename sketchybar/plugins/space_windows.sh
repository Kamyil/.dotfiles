#!/usr/bin/env bash
 
echo AEROSPACE_PREV_WORKSPACE: $AEROSPACE_PREV_WORKSPACE, \
 AEROSPACE_FOCUSED_WORKSPACE: $AEROSPACE_FOCUSED_WORKSPACE \
 SELECTED: $SELECTED \
 BG2: $BG2 \
 INFO: $INFO \
 SENDER: $SENDER \
 NAME: $NAME \
  >> ~/aaaa

source "$CONFIG_DIR/colors.sh"

AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
AEROSAPCE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKESPACE=$(aerospace list-workspaces --monitor focused --empty)

reload_workspace_icon() {
  # echo reload_workspace_icon "$@" >> ~/aaaa
  if [ -z "$1" ] || ! sketchybar --query space.$1 >/dev/null 2>&1; then
    return
  fi
  
  apps=$(aerospace list-windows --workspace "$@" 2>/dev/null | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --animate sin 10 --set space.$@ label="$icon_strip"
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then

  reload_workspace_icon "$AEROSPACE_PREV_WORKSPACE"
  reload_workspace_icon "$AEROSPACE_FOCUSED_WORKSPACE"

  # current workspace space border color
  if [ -n "$AEROSPACE_FOCUSED_WORKSPACE" ] && sketchybar --query space.$AEROSPACE_FOCUSED_WORKSPACE >/dev/null 2>&1; then
    sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE icon.highlight=true \
                           label.highlight=true \
                           background.border_color=$GREY
  fi

  # prev workspace space border color
  if [ -n "$AEROSPACE_PREV_WORKSPACE" ] && sketchybar --query space.$AEROSPACE_PREV_WORKSPACE >/dev/null 2>&1; then
    sketchybar --set space.$AEROSPACE_PREV_WORKSPACE icon.highlight=false \
                           label.highlight=false \
                           background.border_color=$BACKGROUND_2
  fi

  ## focused 된 모니터에 space 상태 보이게 설정
  for i in $AEROSAPCE_WORKSPACE_FOCUSED_MONITOR; do
    if sketchybar --query space.$i >/dev/null 2>&1; then
      sketchybar --set space.$i display=$AEROSPACE_FOCUSED_MONITOR
    fi
  done

  for i in $AEROSPACE_EMPTY_WORKESPACE; do
    if sketchybar --query space.$i >/dev/null 2>&1; then
      sketchybar --set space.$i display=0
    fi
  done

  if [ -n "$AEROSPACE_FOCUSED_WORKSPACE" ] && sketchybar --query space.$AEROSPACE_FOCUSED_WORKSPACE >/dev/null 2>&1; then
    sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE display=$AEROSPACE_FOCUSED_MONITOR
  fi

fi