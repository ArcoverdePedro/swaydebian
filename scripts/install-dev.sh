#!/usr/bin/env bash
# Ferramentas de desenvolvimento opcionais, apenas dos repositorios Debian.
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if (( EUID == 0 )); then
    echo "Execute com seu usuario normal." >&2
    exit 1
fi
if [[ ! -r /etc/os-release ]]; then
    echo "Nao foi possivel identificar o sistema." >&2
    exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
[[ "${ID:-}" == debian ]] || { echo "Suportado apenas no Debian." >&2; exit 1; }

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    git curl wget build-essential python3 python3-pip pipx \
    nodejs npm btop tree jq fastfetch

# Configuracoes do VSCodium apenas quando ele ja estiver instalado.
if command -v codium >/dev/null 2>&1; then
    mkdir -p "$HOME/.config/VSCodium/User"
    for file in settings.json keybindings.json; do
        if [[ ! -e "$HOME/.config/VSCodium/User/$file" ]]; then
            cp -- "$ROOT/User/$file" "$HOME/.config/VSCodium/User/$file"
        fi
    done
fi
echo "Ferramentas opcionais instaladas. VSCodium e outros apps podem ser instalados separadamente."
