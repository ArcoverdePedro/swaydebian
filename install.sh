#!/usr/bin/env bash
# Instalador de desktop Debian/Sway: repetivel, sem repositorios externos.
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="$HOME/.config"
ONLY_CONFIG=0

usage() {
    cat <<'HELP'
Uso: ./install.sh [--config-only] [--help]

  (padrao)       Instala pacotes do Debian e configuracoes do Sway
  --config-only  Aplica somente os arquivos de configuracao
  --help         Mostra esta ajuda

Execute como usuario comum (com sudo), nunca como root.
HELP
}

for arg in "$@"; do
    case "$arg" in
        --config-only) ONLY_CONFIG=1 ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Opcao desconhecida: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
    esac
done

if (( EUID == 0 )); then
    echo "Execute com seu usuario normal, sem sudo na frente." >&2
    exit 1
fi

if (( ONLY_CONFIG == 0 )); then
    if [[ ! -r /etc/os-release ]]; then
        echo "Nao foi possivel identificar o sistema." >&2
        exit 1
    fi
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "${ID:-}" != debian ]]; then
        echo "Instalacao de pacotes suportada somente no Debian 12/13." >&2
        exit 1
    fi
    command -v sudo >/dev/null || { echo "Instale/configure o sudo primeiro." >&2; exit 1; }
    sudo -v
    packages=(
        sway swaybg swayidle swaylock waybar wofi foot xwayland
        xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
        pipewire-audio wireplumber pavucontrol
        network-manager network-manager-gnome
        pcmanfm firefox-esr xdg-utils xdg-user-dirs
        grim slurp wl-clipboard brightnessctl
        mako-notifier lxpolkit dbus-user-session
        fonts-dejavu-core fonts-noto-color-emoji
    )
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends "${packages[@]}"
fi

# Sempre conserva a configuracao anterior antes de substitui-la.
backup_dir="$HOME/.local/share/swaydebian/backups/$(date +%Y%m%d-%H%M%S)-$$"
mkdir -p "$CONFIG_HOME"

for name in sway waybar wofi gtk-3.0; do
    src="$ROOT/$name"
    dst="$CONFIG_HOME/$name"
    [[ -d "$src" ]] || { echo "Diretorio ausente: $src" >&2; exit 1; }
    if [[ -e "$dst" || -L "$dst" ]]; then
        mkdir -p "$backup_dir"
        mv -- "$dst" "$backup_dir/$name"
    fi
    cp -R -- "$src" "$dst"
done

# local.conf e exclusivo de cada computador e sobrevive as atualizacoes.
if [[ -f "$backup_dir/sway/local.conf" ]]; then
    cp -- "$backup_dir/sway/local.conf" "$CONFIG_HOME/sway/local.conf"
else
    cp -- "$ROOT/sway/local.conf.example" "$CONFIG_HOME/sway/local.conf"
fi

install -m 0644 -- "$ROOT/wallpaper/wallpaper.png" "$CONFIG_HOME/sway/wallpaper.png"
mkdir -p "$HOME/Pictures" "$HOME/Downloads" "$HOME/Documents"

if command -v sway >/dev/null 2>&1; then
    echo "Validando configuracao do Sway (sem depender de GPU/TTY)..."
    runtime_dir="$(mktemp -d)"
    chmod 700 "$runtime_dir"
    if ! XDG_RUNTIME_DIR="$runtime_dir" WLR_BACKENDS=headless \
        WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1 \
        sway -C -c "$CONFIG_HOME/sway/config"; then
        rmdir "$runtime_dir" 2>/dev/null || true
        echo "Falha de validacao. Restaure o backup se necessario: $backup_dir" >&2
        exit 1
    fi
    rmdir "$runtime_dir" 2>/dev/null || true
fi

echo
echo "Configuracao instalada em $CONFIG_HOME"
if [[ -d "$backup_dir" ]]; then
    echo "Backup anterior em $backup_dir"
fi
echo "Entre na sessao Sway pelo gerenciador de login ou, em um TTY: sway"
echo "Nao houve reinicializacao automatica nem alteracao de drivers."
