#!/usr/bin/env bash

declare -A KNOWN

niri msg --json event-stream | while IFS= read -r event; do

    # No começo, o Niri envia todas as janelas que já existem.
    # Marcamos elas para NÃO mover tudo quando o script iniciar.
    if jq -e 'has("WindowsChanged")' >/dev/null 2>&1 <<< "$event"; then
        while read -r id; do
            [[ -n "$id" ]] && KNOWN["$id"]=1
        done < <(
            jq -r '.WindowsChanged.windows[]?.id' <<< "$event"
        )

        continue
    fi

    # Pega uma janela que acabou de aparecer.
    id="$(
        jq -r '
            .WindowOpenedOrChanged.window.id // empty
        ' <<< "$event"
    )"

    [[ -z "$id" ]] && continue

    # Se já conhecemos a janela, é apenas uma alteração
    # de foco/título/tamanho. Não fazemos nada.
    if [[ -n "${KNOWN[$id]+x}" ]]; then
        continue
    fi

    KNOWN["$id"]=1

    # Não cria workspace separado para diálogos/popups flutuantes.
    floating="$(
        jq -r '
            .WindowOpenedOrChanged.window.is_floating // false
        ' <<< "$event"
    )"

    [[ "$floating" == "true" ]] && continue

    # Foca a janela recém-aberta para que
    # window-new-workspace.sh trabalhe nela.
    niri msg action focus-window --id="$id" >/dev/null 2>&1

    # Pequeno tempo para o Niri terminar de mapear a janela.
    sleep 0.08

    "$HOME/.config/niri/scripts/window-new-workspace.sh"

done
