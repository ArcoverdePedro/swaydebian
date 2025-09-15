![Debian Badge](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=fff&style=for-the-badge)
![GNU Bash Badge](https://img.shields.io/badge/GNU%20Bash-4EAA25?logo=gnubash&logoColor=fff&style=for-the-badge)
![Sway Badge](https://img.shields.io/badge/Sway-68751C?logo=sway&logoColor=fff&style=for-the-badge)
![VSCodium Badge](https://img.shields.io/badge/VSCodium-2F80ED?logo=vscodium&logoColor=fff&style=for-the-badge)
![GNU Emacs Badge](https://img.shields.io/badge/GNU%20Emacs-7F5AB6?logo=gnuemacs&logoColor=fff&style=for-the-badge)
![WezTerm Badge](https://img.shields.io/badge/WezTerm-4E49EE?logo=wezterm&logoColor=fff&style=for-the-badge)

Pós-Instalação Debian

Este repositório contém um script de pós-instalação para Debian, configurando ambiente de desenvolvimento, Wayland, ferramentas essenciais e aplicativos via Flatpak, VSCodium e Google Chrome.
Ele também adiciona repositórios de terceiros e configura o ambiente do usuário.



Estrutura Pensada
  
    ├── debian_coisas.sh -> Script Principal
    │
    ├─ emacs
    │   └── .emacs -> Arquivo de configuração do emacs 
    ├── gtk-3.0
    │   └── settings.ini -> estilização do pcmanfm
    ├── LICENSE
    ├── README.md
    ├── sway
    │   ├── config
    │   └── volume.sh -> Script para controlar o volume
    ├── User
    │   ├── keybindings.json -> keybindings para o VSCodium
    │   └── settings.json -> Configurações do VSCodium
    ├── wallpaper
    │   └── wallpaper.png
    ├── waybar
    │   ├── config
    │   └── style.css
    ├── wezterm
    │   └── wezterm.lua -> apenas para estilizar o terminal (Gruvbox Style)
    └── wofi
        ├── config
        └── style.css

Funcionalidades Principais

    Instalação de Pacotes Essenciais: curl, wget, git, ferramentas de sistema

    Ambiente Wayland/Sway: Instalação completa do compositor Sway WM com waybar, wofi e Wezterm

    Multimídia: PipeWire, OBS Studio, controle de áudio

    VSCodium com extensões para Python, Docker, YAML, TOML

    Ferramentas Python (pipx, ruff, flake8, pyright, uv)

    Docker CE, Docker Compose, Podman e Podman Compose

    Aplicativos Flatpak: Ungoogled Chromium, Bruno (API client)

    Utilitários: pcmanfm, mupdf, btop, tree, nsxiv

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
