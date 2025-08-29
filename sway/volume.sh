#!/bin/bash

# Define o volume máximo permitido
MAX_VOLUME=150

# Qual ação: up/down/mute
ACTION="$1"

# Pega o volume atual (sem o '%')
CURRENT=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)

if [[ "$ACTION" == "up" ]]; then
  if [ "$CURRENT" -lt "$MAX_VOLUME" ]; then
    pactl set-sink-volume @DEFAULT_SINK@ +5%
  fi
elif [[ "$ACTION" == "down" ]]; then
  pactl set-sink-volume @DEFAULT_SINK@ -5%
elif [[ "$ACTION" == "mute" ]]; then
  pactl set-sink-mute @DEFAULT_SINK@ toggle
fi
