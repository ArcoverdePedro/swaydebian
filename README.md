# Sway no Debian — simples, modular e portatil

Configuracao Gruvbox leve do **Sway + Waybar + Wofi**, pensada para desktops,
notebooks, maquinas antigas e computadores com diferentes monitores.
A instalacao basica usa **somente repositorios oficiais do Debian**:
sem Emacs, Docker, Node.js, Flatpak, instaladores remotos ou reboot automatico.

## Instalacao

**Debian 12 (Bookworm) ou 13 (Trixie)**, com aceleracao grafica/driver
compativel com Wayland e um usuario com acesso ao `sudo`:

```bash
git clone https://github.com/ArcoverdePedro/swaydebian.git
cd swaydebian
chmod +x install.sh
./install.sh
```

A instalacao fornece compositor, terminal Foot, menu Wofi, Waybar, navegador
Firefox ESR, gerenciador PCManFM, PipeWire, applet de rede, bloqueio de tela,
notificacoes, capturas de tela e fontes comuns. Ela **nao troca seu gerenciador
de login**, nao escolhe placa de video e nao reinicia. Use a opcao **Sway**
do gerenciador de login ou abra um TTY e execute `sway` (em uma sessao
de usuario com systemd/logind).

Se os pacotes ja estiverem instalados ou se quiser apenas atualizar os dotfiles:

```bash
./install.sh --config-only
```

O comando antigo `./debian_coisas.sh` continua funcionando e chama o novo
instalador. Cada instalacao salva os diretorios substituidos em
`~/.local/share/swaydebian/backups/`; o arquivo `sway/local.conf` existente
sempre e preservado. **Nunca execute os scripts com `sudo ./install.sh`.**

## Estrutura

```text
install.sh                     Instalacao basica e backup
debian_coisas.sh              Alias de compatibilidade
scripts/install-dev.sh        Ferramentas para programar (opcional)
sway/config                   Configuracao principal: inclui os modulos
sway/config.d/
  10-aparencia.conf           Tema, bordas, gaps e wallpaper
  20-entrada.conf             Touchpad, sem ID de dispositivo fixo
  30-atalhos.conf             Atalhos, volume, brilho e screenshots
  40-sessao.conf              Waybar, rede, polkit, notificacoes e bloqueio
sway/local.conf.example       Exemplo de ajustes especificos da maquina
waybar/                       Barra de status
wofi/                         Menu de aplicativos
gtk-3.0/                      Tema GTK
wallpaper/wallpaper.png       Fundo de tela
User/                         Modelos opcionais para VSCodium
fastfetch/                    Modelo opcional do Fastfetch
```

## Configuracao por computador

A deteccao de monitores, resolucao e teclado fica com o Debian/Sway.
Para alterar preferencia de teclado, escala ou posicao dos monitores, **edite
apenas** `~/.config/sway/local.conf`, carregado apos os modulos:

```sway
# Teclado brasileiro ABNT2
input type:keyboard {
    xkb_layout br
    xkb_variant abnt2
}

# Exemplo de notebook HiDPI (habilite somente se tiver eDP-1)
# output eDP-1 scale 1.25
```

Descubra monitores com `swaymsg -t get_outputs` e entradas com
`swaymsg -t get_inputs`. Evite colocar identificadores de GPU, EDID ou
nome de monitor nos modulos compartilhados. Para escolher outra fonte,
terminal, layout de teclado ou mudar atalhos, edite os modulos ou personalize
o arquivo local.

## Atalhos basicos

| Atalho | Acao |
|---|---|
| Super+Enter | Terminal Foot |
| Super+D | Menu Wofi |
| Super+Shift+F | PCManFM |
| Super+Shift+Q | Fechar janela |
| Super+H/J/K/L | Mover foco |
| Super+Shift+H/J/K/L | Mover janela |
| Super+1…0 | Espacos 1…10 |
| Super+Shift+1…0 | Mover janela ao espaco |
| Super+F | Tela cheia |
| Super+R | Redimensionar |
| Super+Shift+C | Recarregar configuracao |
| Super+Shift+E | Sair da sessao |
| Print / Shift+Print | Capturar tela / area para clipboard |
| Teclas de volume e brilho | Ajustes quando o hardware oferece suporte |

O modulo de bateria so exibe informacoes quando a maquina possui bateria;
os atalhos de brilho sao inofensivos em equipamentos sem backlight.
O volume e limitado a 100% para evitar amplificacao excessiva.

## Pacotes adicionais de desenvolvimento

```bash
./scripts/install-dev.sh
```

Instala ferramentas disponiveis nos repositorios Debian, sem alterar o Sway.
Modelos de VSCodium sao copiados **somente se o VSCodium ja existir** e nao
sobrescrevem configuracoes existentes. Chrome, Docker, repositorios terceiros
e outras ferramentas pesadas ficam por conta do usuario.

## Verificacao e diagnostico

```bash
sway -C -c ~/.config/sway/config  # validar a sintaxe
swaymsg reload                    # recarregar sessao em execucao
swaymsg -t get_outputs            # listar monitores
journalctl --user -b -p warning   # diagnosticar servicos de usuario
```

**Compatibilidade:** funciona em varios tipos de PC, mas nenhum conjunto
de dotfiles garante Sway em *todo* hardware. Intel/AMD com drivers Mesa
normalmente sao o caminho mais simples; placas NVIDIA com driver proprietario
podem exigir configuracao especifica ou apresentar incompatibilidade com
wlroots/Sway. Instalar os arquivos **nao instala firmware/drivers de GPU ou
Wi-Fi**. Consulte o manual do Debian antes de alterar drivers.
