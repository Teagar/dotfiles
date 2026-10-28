#!/usr/bin/env bash

# Janela atualmente focada
WINDOW_ID=$(niri msg -j windows | jq -r '.[] | select(.is_focused == true) | .id')

[ -z "$WINDOW_ID" ] && exit 0

# Informações dos workspaces
WS_JSON=$(niri msg -j workspaces)

# Workspace atualmente focado
CURR_IDX=$(echo "$WS_JSON" | jq -r '.[] | select(.is_focused == true) | .idx')
CURR_OUT=$(echo "$WS_JSON" | jq -r '.[] | select(.is_focused == true) | .output')

# Quantidade de workspaces no monitor atual.
# O último é o workspace vazio dinâmico do Niri.
LAST_WS=$(echo "$WS_JSON" | jq -r \
    --arg out "$CURR_OUT" \
    '[.[] | select(.output == $out)] | length')

# Queremos colocar o novo workspace imediatamente depois do atual.
NEW_IDX=$((CURR_IDX + 1))

# Dá temporariamente um nome ao workspace vazio final.
niri msg action set-workspace-name "_new_app" --workspace "$LAST_WS"

# Move esse workspace vazio para logo depois do atual.
niri msg action move-workspace-to-index "$NEW_IDX" --reference "_new_app"

# Move a janela para ele e acompanha a janela.
niri msg action move-window-to-workspace \
    --window-id "$WINDOW_ID" \
    "_new_app"

# Volta o workspace a ser dinâmico.
niri msg action unset-workspace-name "_new_app"
