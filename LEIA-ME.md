# rice: XFCE + i3

CachyOS com o **i3** cuidando das janelas e o **XFCE** cuidando do resto: painel,
bandeja, notificações, volume, energia, bloqueio, configurações e Thunar.
O **iris** tira as cores do wallpaper e pinta tudo.
Monitor DP-0 a 1920x1080 / 165 Hz, escala 1.3 por DPI (125), cursor Bibata 32.

Montado em 2026-11-18/19, depois da saída do Ryoku e do pleamar-wm.

## Como esta pasta funciona

Os arquivos de verdade moram aqui. Nos lugares de sempre (`~/.config/...`,
`~/.local/bin/...`) ficam **links** para cá. Editar `~/.config/i3/config` ou
`~/rice/config/i3/config` dá no mesmo.

As configs do XFCE são a exceção: o próprio XFCE regrava esses arquivos, então
`xfce/` é uma **cópia**. Depois de mexer no painel, nos atalhos ou nas
configurações pelas janelas do XFCE, rode `bash ~/rice/salvar-xfce.sh`.

| Pasta / arquivo | O quê |
|---|---|
| `config/i3/config` | i3: atalhos vim, regras de flutuação, workspaces dinâmicos, overview |
| `config/picom/picom.conf` | compositor: animações, blur, sombras e cantos só nas flutuantes, apps GTK "de vidro" (opacidade 0.92 + blur) |
| `config/iris/templates/` | cores geradas a partir do wallpaper: GTK 3/4, painel, notificações, i3, rofi, fish, btop, overview |
| `config/rofi/`, `config/kitty/`, `config/fish/`, `config/btop/`, `config/fastfetch/` | apps do dia a dia |
| `config/gtk-3.0/gtk.css` | vazio de propósito (qualquer cor aqui travaria o tema do iris) |
| `config/autostart/` | o que o XFCE sobe no login: picom, wallpaper, overview, workspaces dinâmicos, nomes no pager |
| `bin/iris-wall` | troca o wallpaper e repinta tudo ao vivo |
| `bin/i3-ws`, `bin/i3-dynamic-ws` | workspaces dinâmicos estilo GNOME/niri (sempre 1..9 em sequência) |
| `bin/brilho` | brilho real do monitor via DDC/CI, com OSD e indicador no painel |
| `bin/i3-desktop-mode` | alterna o workspace atual entre tiling e tudo flutuando |
| `bin/i3-xfce-wsnames` | faz o pager do painel mostrar os nomes dos workspaces do i3 |
| `applications/` | "Papel de parede" nas Configurações abre o seletor do iris-wall |
| `xfce/` | cópia das configs do XFCE: painel, DPI/tema, monitor, sessão com i3, atalhos, notificações, Thunar, apps padrão |
| `pacotes.txt`, `pacotes-aur.txt` | o que o rice precisa instalado |
| `instalar.sh`, `salvar-xfce.sh` | colocar o rice no lugar / atualizar a cópia do XFCE |

## Atalhos (Super = tecla Windows)

| Tecla | Ação |
|---|---|
| `Super+h j k l` | foco (setas também) |
| `Super+Shift+h j k l` | mover janela |
| `Super+Ctrl+h j k l` | redimensionar; `Super+r` entra no modo resize (hjkl, Shift = passo maior) |
| `Super+v` / `Super+s` | próxima janela à direita (`:vsplit`) / embaixo (`:split`) |
| `Super+Shift+v` | alternar a direção do split |
| `Super+t` / `Super+g` | abas / empilhado |
| `Super+f` | tela cheia |
| `Super+x` | flutuar / voltar pro tiling |
| `Super+space` | foco entre tiled e flutuantes |
| `Super+a` / `Super+Shift+a` | foco no pai / filho |
| `Super+q` | fechar |
| `Super+Shift+w` / `Super+w` | "minimizar" (scratchpad) / mostrar |
| `Super+Alt+h j k l` (ou setas) | workspace anterior (h/k) / próximo (j/l); como `Super+,` / `Super+.` |
| `Super+Shift+t` | modo desktop: o workspace todo flutua ou volta pro tiling |
| `Super+1..9` | workspace N (se não existe, abre um novo no fim) |
| `Super+Shift+1..9` | mandar a janela pro workspace N |
| `Super+0` | workspace 10 "livre", onde tudo flutua |
| `Super+n` / `Super+Shift+n` | workspace vazio novo / levar a janela pra um novo |
| `Super+.` / `Super+,` | próximo / anterior (no último, `Super+.` cria um novo) |
| `Super+Shift+.` / `Super+Shift+,` | levar a janela pro próximo / anterior |
| `Super+Tab` / `Super+Shift+Tab` | overview dos workspaces / das janelas do atual (hjkl, Enter, Esc) |
| `Super+Return` | terminal (kitty) |
| `Super+e` | Thunar |
| `Super+d` | Localizador de aplicativos |
| `Super+Shift+d` | rofi |
| `Alt+Tab` | lista de janelas |
| `Ctrl+Esc` / `Alt+F1` | menu de aplicativos |
| `Super+Shift+b` | escolher wallpaper (o tema muda junto) |
| `Super+p` | monitores |
| `Super+Ctrl+-` / `Super+Ctrl+=` | brilho do monitor −10% / +10% (com Shift: passo de 2%); clique no ☀ do painel escolhe um nível |
| `Super+Escape` | bloquear |
| `Super+Shift+e` | sair / desligar |
| `Super+Shift+c` / `Super+Shift+r` | recarregar / reiniciar o i3 |
| `Print`, `Shift+Print`, `Alt+Print` | screenshot da tela / área / janela |

## Uso diário

- **Trocar o wallpaper:** `Super+Shift+b`, botão direito numa imagem no Thunar
  ("Usar como papel de parede"), ou `iris-wall caminho/da/imagem`. Os wallpapers
  ficam em `~/Imagens/Wallpapers`. Use `-d`/`-l` para forçar tema escuro/claro.
- **Mudar uma cor ou estilo:** edite o template em `config/iris/templates/` e rode
  `iris-wall --restore`. Não edite os arquivos gerados em `~/.cache/iris`.
- **Animações, blur e transparência:** `config/picom/picom.conf`, depois `pkill -USR1 -x picom`. Os apps "de vidro" ficam na regra com `opacity = 0.92`; tire um app da lista ou suba o valor para deixar mais opaco.
- **Apps GTK 4** pegam as cores novas quando são reabertos; o resto muda na hora.

## Reinstalar do zero

```sh
bash ~/rice/instalar.sh --pacotes --xfce
```

Depois disso, faça logout/login (escolha a sessão "Xfce Session" no LightDM) e rode
`iris-wall --pick` para escolher um wallpaper.

## Backups

Tudo o que é backup ficou em `~/Documentos/Backups/`:

- `2026-11-18 xfce antes do i3/`: configs do XFCE e do GTK de antes do i3.
- `2026-11-18 remoção ryoku-pleamar/`: backups do sistema da remoção do Ryoku,
  dados do Ryoku e `pleamar-arquivo/`. Essa última tem commits seus do Marea e do
  Vitreus que nunca foram para o GitHub; veja o `LEIA-ME.txt` dentro dela.
- `dotfiles/`: `.bashrc` antigo.
