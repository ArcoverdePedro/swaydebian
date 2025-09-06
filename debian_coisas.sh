#!/bin/bash
set -euo pipefail

# Obtem o diretorio do script para referenciar arquivos
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Iniciando pos-instalacao do Debian..."

read -rp "Deseja usar o SearXNG? (S/N): " resposta
resposta=$(echo "$resposta" | tr '[:lower:]' '[:upper:]')

USUARIO=$(id -u -n)

case "$resposta" in
    S) echo "Sera instalado o SearXNG"
        ;;

    N) echo "Nao Sera instalado o SearXNG"
        ;;

    *)
        echo "Opcao invalida. Saindo do script."
        sleep 2
        exit 1 # Sai do script com codigo de erro
        ;;
esac

# -------------------------------------------------------------------
# 1. Pacotes basicos
# -------------------------------------------------------------------

sudo apt update
sudo apt install -y \
    curl wget git ca-certificates gpg apt-transport-https flatpak coreutils

# -------------------------------------------------------------------
# 2. Flatpak
# -------------------------------------------------------------------

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub io.github.ungoogled_software.ungoogled_chromium com.usebruno.Bruno || true


# -------------------------------------------------------------------
# 3. Google Chrome
# -------------------------------------------------------------------

echo "Instalando Google Chrome..."
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

# -------------------------------------------------------------------
# 4. Wezterm Repo
# -------------------------------------------------------------------

curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg

cp -r "${SCRIPT_DIR}/wezterm/wezterm.lua" "$HOME/.wezterm.lua"

# -------------------------------------------------------------------
# 5. VSCodium Repo
# -------------------------------------------------------------------

echo "Adicionando repositorio do VSCodium..."
curl -sSL https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/vscodium-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg] \
https://download.vscodium.com/debs vscodium main" \
  | sudo tee /etc/apt/sources.list.d/vscodium.list >/dev/null

# -------------------------------------------------------------------
# 6. Docker Repo
# -------------------------------------------------------------------

echo "Adicionando repositorio do Docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# -------------------------------------------------------------------
# 7. Atualizacao do repositorio
# -------------------------------------------------------------------

sudo apt update

# -------------------------------------------------------------------
# 8. Instalacao de pacotes principais
# -------------------------------------------------------------------

echo "Instalando pacotes principais..."
sudo apt install -y \
    sway swaybg swayidle swaylock waybar wofi wezterm \
    xwayland xdg-desktop-portal xdg-desktop-portal-wlr qt6-wayland \
    pipewire pipewire-audio wireplumber pipewire-pulse pavucontrol \
    network-manager brightnessctl slurp grim \
    pcmanfm fonts-font-awesome\
    libnotify-bin fonts-jetbrains-mono nsxiv \
    vlc okular libreoffice fastfetch btop tree unzip zip 7zip \
    podman podman-compose docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin \
    obs-studio obs-plugins v4l2loopback-dkms \
    google-chrome-stable codium firefox-esr ncdu \
    xdg-utils pipx \
    dbus dbus-user-session \
    fonts-dejavu fonts-noto fonts-noto-color-emoji \
    git curl wget


# -------------------------------------------------------------------
# 9. PIPX
# -------------------------------------------------------------------

pipx ensurepath || true
pipx install ruff
pipx install bandit
pipx install flake8
pipx install uv
pipx install pyright

# -------------------------------------------------------------------
# 11. Grupo Docker
# -------------------------------------------------------------------

sudo usermod -aG docker "$USUARIO"
newgrp docker

# -------------------------------------------------------------------
# 12. Script atualizar
# -------------------------------------------------------------------

echo "Instalando comando 'atualizar'..."

sudo tee /usr/local/bin/atualizar >/dev/null <<"EOF"
#!/bin/bash

# Comando 'atualizar' - Atualizacao automatica do Debian/Ubuntu
# Coloque este arquivo em: /usr/local/bin/atualizar
# chmod +x /usr/local/bin/atualizar

set -euo pipefail

# Cores
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[AVISO]${NC} $1"; }
log_error() { echo -e "${RED}[ERRO]${NC} $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

show_progress() {
    echo
    echo "---------------------------------------------------"
    log_info "$1"
    echo "---------------------------------------------------"
}

update_apt() {
    show_progress "Atualizando sistema via APT"
    
    if ! command_exists apt-get; then
        log_error "APT nao encontrado!"
        return 1
    fi

    log_info "Atualizando lista de pacotes..."
    sudo apt-get update -qq
    
    log_info "Verificando atualizacoes disponiveis..."
    local updates=$(apt list --upgradable 2>/dev/null | grep -c 'upgradable from' || echo "0")
    
    if [ "$updates" -gt 0 ]; then
        log_info "Encontradas $updates atualizacoes - iniciando..."
        sudo apt-get upgrade -y
        sudo apt-get dist-upgrade -y
        log_success "Sistema APT atualizado!"
    else
        log_success "Sistema APT ja esta atualizado!"
    fi
}

update_flatpak() {
    show_progress "Atualizando Flatpaks"
    
    if ! command_exists flatpak; then
        log_warning "Flatpak nao instalado - pulando..."
        return 0
    fi
    
    local apps=$(flatpak list --app 2>/dev/null | wc -l || echo "0")
    
    if [ "$apps" -eq 0 ]; then
        log_warning "Nenhum Flatpak instalado"
        return 0
    fi
    
    log_info "Atualizando $apps aplicacoes Flatpak..."
    sudo flatpak update -y --system >/dev/null 2>&1 || true
    flatpak update -y --user >/dev/null 2>&1 || true
    log_success "Flatpaks atualizados!"
}

cleanup_system() {
    show_progress "Limpeza do sistema"
    
    log_info "Removendo pacotes desnecessarios..."
    sudo apt-get autoremove -y >/dev/null 2>&1
    
    log_info "Limpando cache do APT..."
    sudo apt-get autoclean -y >/dev/null 2>&1
    sudo apt-get clean -y >/dev/null 2>&1
    
    if command_exists flatpak; then
        log_info "Removendo Flatpaks nao utilizados..."
        flatpak uninstall --unused -y >/dev/null 2>&1 || true
    fi
    
    log_success "Limpeza concluida!"
}

show_summary() {
    echo
    echo "---------------------------------------------------"
    log_success "ATUALIZACAO CONCLUIDA"
    echo "---------------------------------------------------"
    
    log_info "Sistema: $(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)"
    log_info "Data/Hora: $(date '+%d/%m/%Y %H:%M:%S')"
    
    if [ -f /var/run/reboot-required ]; then
        log_warning "Reinicializacao recomendada!"
        echo -e "Execute: ${YELLOW}sudo reboot${NC}"
    else
        log_success "Nenhuma reinicializacao necessaria"
    fi
    
    echo
    log_success "Sistema Debian/Ubuntu atualizado com sucesso!"
}

main() {
    local start_time=$(date +%s)
    
    echo "---------------------------------------------------"
    log_info "ATUALIZANDO DEBIAN/UBUNTU"
    log_info "Iniciado em: $(date '+%d/%m/%Y %H:%M:%S')"
    echo "---------------------------------------------------"
    
    if [ "$EUID" -eq 0 ]; then
        log_error "Nao execute como root! Use como usuario normal."
        exit 1
    fi
    
    log_info "Verificando conectividade..."
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        log_error "Sem conexao com internet!"
        exit 1
    fi
    log_success "Conexao OK"
    
    update_apt
    update_flatpak
    cleanup_system
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    show_summary
    log_info "Tempo total: ${duration}s"
}

trap 'log_error "Interrompido pelo usuario"; exit 130' INT TERM

main "$@"
EOF

sudo chmod +x /usr/local/bin/atualizar

# -------------------------------------------------------------------
# 13. Configuracao do Sway e Habilitando servicos do usuario
# -------------------------------------------------------------------
echo "Configurando o Sway"

mkdir -p "$HOME/.config/VSCodium/User"
mkdir -p "$HOME/.config/sway"
mkdir -p "$HOME/.config/waybar"
mkdir -p "$HOME/.config/wofi"

cp -r "${SCRIPT_DIR}/sway" "$HOME/.config/sway"
cp -r "${SCRIPT_DIR}/waybar" "$HOME/.config/waybar"
cp -r "${SCRIPT_DIR}/wofi" "$HOME/.config/wofi"

systemctl --user enable dbus
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user enable xdg-desktop-portal xdg-desktop-portal-wlr

# -------------------------------------------------------------------
# 14. Searxng
# -------------------------------------------------------------------

case "$resposta" in
    S)
        echo "Clonando Repositorio do Searxng e Subindo o Container"

        git clone https://github.com/ArcoverdePedro/SearXNG.git "/home/$USUARIO/SearXNG"

        sudo bash "/home/$USUARIO/SearXNG/init.sh"
        ;;

    N)
        echo "Voce escolheu 'Nao'. Pulando a Instalacao do SearXNG."
        ;;
esac

# -------------------------------------------------------------------
# 15. VSCODIUM-Configuracao
# -------------------------------------------------------------------

# Pre-Configurando o Git
git config --global user.name "ArcoverdePedro"
git config --global user.email "pedroarcoverde2@gmail.com"

echo "configurando keybindings"
cp "${SCRIPT_DIR}/code/keybindings.json" "$HOME/.config/VSCodium/User/keybindings.json"

extensions=(
  redhat.vscode-yaml
  ms-python.python
  charliermarsh.ruff
  tamasfe.even-better-toml
  wholroyd.jinja
  mads-hartmann.bash-ide-vscode
  njpwerner.autodocstring
  docker.docker
  ms-azuretools.vscode-containers
  usernamehw.errorlens
  ms-python.flake8
  batisteo.vscode-django
  KevinRose.vsc-python-indent
  GitHub.vscode-github-actions
  GitHub.vscode-pull-request-github
  yy0931.vscode-sqlite3-editor
  jdinhlife.gruvbox
  ms-kubernetes-tools.vscode-kubernetes-tools
  ultram4rine.vscode-choosealicense
)

for ext in "${extensions[@]}"; do
    codium --install-extension "$ext" --force
done

# -------------------------------------------------------------------
# 16. Fim do Script, reiniciando a maquina e  
# -------------------------------------------------------------------
echo "Atualizando e Reiniciando o PC"

sudo apt update
sudo apt upgrade -y

echo "Pos-instalacao concluida!"
echo ""
echo "Reiniciando a Maquina"

sleep 2
sudo shutdown -r now
