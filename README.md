![Debian Badge](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff&style=for-the-badge)
![GNU Bash Badge](https://img.shields.io/badge/GNU%20Bash-4EAA25?logo=gnubash&logoColor=fff&style=for-the-badge)
![Sway Badge](https://img.shields.io/badge/Sway-68751C?logo=sway&logoColor=fff&style=for-the-badge)
![CSS Badge](https://img.shields.io/badge/CSS-639?logo=css&logoColor=fff&style=for-the-badge)
![Python Badge](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=fff&style=for-the-badge)

Pós-Instalação Debian

Este repositório contém um script de pós-instalação para Debian, configurando ambiente de desenvolvimento, Wayland, ferramentas essenciais e aplicativos via Flatpak, VSCodium e Google Chrome. Ele também adiciona repositórios de terceiros e configura o ambiente do usuário.



Estrutura Pensada

    ├── debian_coisas.sh       # Script principal de pós-instalação
    ├── sway                  # Configurações do Sway
    │   ├── config
    │   └── volume.sh
    ├── waybar                # Configurações do Waybar
    │   ├── config
    │   └── style.css
    └── wofi                  # Configurações do Wofi
        ├── config
        └── style.css

Funcionalidades Principais

    Instalação de Pacotes Essenciais: curl, wget, git, ferramentas de sistema

    Repositórios Adicionais: VSCodium, Docker, Google Chrome

    Ambiente Wayland/Sway: Instalação completa do compositor Sway WM com waybar, wofi e alacritty

    Multimídia: PipeWire, OBS Studio, controle de áudio

    VSCodium com extensões para Python, Docker, YAML, TOML

    Ferramentas Python (pipx, black, flake8, pyright, uv)

    Docker CE e Docker Compose

    Aplicativos Flatpak: Ungoogled Chromium, Bruno (API client)

    Utilitários: Thunar, Okular, btop, tree

Comando Personalizado

    atualizar: Atualiza sistema, pacotes Flatpak e realiza limpeza

Configurações Automáticas

    Configurações do Sway, Waybar e Wofi

    Portal de desktop para Wayland

    Usuário adicionado ao grupo Docker

    Configuração inicial do Git

Como Usar

    chmod +x debian_coisas.sh
    ./debian_coisas.sh
    
Requisitos: 
    Debian,
    Usuário com privilégios de sudo,
    Conexão com a internet.