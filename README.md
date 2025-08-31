![Debian Badge](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff&style=for-the-badge)
![GNU Bash Badge](https://img.shields.io/badge/GNU%20Bash-4EAA25?logo=gnubash&logoColor=fff&style=for-the-badge)
![Sway Badge](https://img.shields.io/badge/Sway-68751C?logo=sway&logoColor=fff&style=for-the-badge)
![CSS Badge](https://img.shields.io/badge/CSS-639?logo=css&logoColor=fff&style=for-the-badge)
![VSCodium Badge](https://img.shields.io/badge/VSCodium-2F80ED?logo=vscodium&logoColor=fff&style=for-the-badge)

Pós-Instalação Debian

Este repositório contém um script de pós-instalação para Debian, configurando ambiente de desenvolvimento, Wayland, ferramentas essenciais e aplicativos via Flatpak, VSCodium e Google Chrome.
Ele também adiciona repositórios de terceiros e configura o ambiente do usuário.



Estrutura Pensada

    ├── debian_coisas.sh # Script principal de pós-instalação
    ├── sway             # Configurações para o Sway ~/.config/sway
    │   ├── config       
    │   └── volume.sh    # Script para controle de volume
    ├── waybar           # Configurações para o Waybar ~/.config/waybar
    │   ├── config       
    │   └── style.css    
    └── wofi             # Configurações do Wofi ~/.config/wofi
        ├── config       
        └── style.css    

Funcionalidades Principais

    Instalação de Pacotes Essenciais: curl, wget, git, ferramentas de sistema

    Ambiente Wayland/Sway: Instalação completa do compositor Sway WM com waybar, wofi e alacritty

    Multimídia: PipeWire, OBS Studio, controle de áudio

    VSCodium com extensões para Python, Docker, YAML, TOML

    Ferramentas Python (pipx, ruff, flake8, pyright, uv)

    Ferramanta Bun para JavaScript

    Docker CE, Docker Compose, Podman e Podman Compose

    Aplicativos Flatpak: Ungoogled Chromium, Bruno (API client)

    Utilitários: Thunar, Okular, btop, tree

Configurações Automáticas

    Configurações do Sway, Waybar e Wofi

    Portal de desktop para Wayland

    Usuário adicionado ao grupo Docker

    Configuração inicial do Git

    Comando Personalizado - atualizar: Atualiza sistema, pacotes Flatpak e realiza limpeza

Como Usar:

    chmod +x debian_coisas.sh
    ./debian_coisas.sh
    
Requisitos

    Debian
    Sudo User
    Internet