# Porte NixOS (Flake + Home Manager)

Este diretório empacota o rice **XFCE + i3 (X11) + iris** como um Nix Flake com módulos para **NixOS** e **Home Manager**, além dos pacotes `iris-colors` e `skippy-xd` construídos a partir do upstream.

## O que o flake expõe

- `nixosModules.default` / `nixosModules.xfce-i3`: base do sistema (X11, LightDM com sessão `xfce+i3`, XFCE sem `xfwm4`/`xfdesktop`, `i3`, `xfce4-panel` + plugins, `picom`, `rofi`, `feh`, `adw-gtk3`, `bibata-cursors`, `papirus-icon-theme`, fontes, Thunar, etc.).
- `homeManagerModules.default` / `homeManagerModules.xfce-i3`: dotfiles (`i3`, `picom`, `rofi`, templates do `iris`, `wireplumber`, `neovim` opcional e stack de terminal com `kitty`, `fish`, `starship`, `yazi`, `cava`, `btop`, `fastfetch`), scripts em wrapper com dependências no `PATH`, arquivos de autostart, fallback inicial em `~/.cache/iris` e seed inicial opcional do XFCE.
- `packages.<system>.{iris-colors,skippy-xd}` e `overlays.default`.
- `checks.<system>.{iris-colors,skippy-xd,nixos-eval,nixos-eval-brilho}`.

Sistemas declarados: `x86_64-linux` e `aarch64-linux`.

## Como usar

Veja o arquivo pronto para copiar em [`example/flake.nix`](./example/flake.nix).

Resumo dos passos no seu `flake.nix` do NixOS:

1. Adicione o repositório como input (junto com `nixpkgs` `nixos-unstable` e `home-manager`).
2. Importe `rice.nixosModules.default` nos módulos do sistema e ative `rice.xfce-i3.enable = true;`.
3. Importe `rice.homeManagerModules.default` nos módulos do usuário no Home Manager e ative `rice.xfce-i3.enable = true;`.
4. Rode `sudo nixos-rebuild switch --flake .#seu-host`.

## Primeiro login

- No LightDM, a sessão padrão configurada é **`xfce+i3`** (inicia os serviços do XFCE com o `i3` como gerenciador de janelas).
- Antes do primeiro wallpaper, o Home Manager cria um tema neutro escuro inicial em `~/.cache/iris/` e `~/.local/share/themes/Iris-A/` (apenas se ainda não existirem), para que `i3`, `rofi`, `kitty`, `btop` e `skippy-xd` abram sem erros.
- Pressione **`Super+Shift+b`** (ou rode `iris-wall --pick` / `iris-wall caminho/da/imagem`) para escolher um wallpaper e gerar a paleta de cores da sessão. Por padrão o `iris-wall` procura imagens em `~/Imagens/Wallpapers`, `~/Pictures/Wallpapers`, `~/Wallpapers` e nos diretórios listados em `wallpaperDirs`.

## Notas importantes

### Não ative `gtk.enable = true` no Home Manager

O `iris-wall` alterna o tema GTK 3 ao vivo entre os slots `Iris-A` e `Iris-B` em `~/.local/share/themes/`, além de gravar `~/.config/gtk-3.0/settings.ini` e `~/.config/gtk-4.0/{gtk.css,settings.ini}`. Gerenciar esses arquivos pelo Home Manager criaria symlinks somente leitura que bloqueiam a troca de cores ao vivo.

### Como funciona o `seedXfce`

Quando `seedXfce = true` (padrão), a ativação do Home Manager copia configurações iniciais higienizadas do painel, notificações, atalhos, `xsettings.xml`, `uca.xml` do Thunar e `helpers.rc` **apenas se o arquivo de destino ainda não existir**. Depois do primeiro login você pode alterar o painel, DPI ou atalhos normalmente pelas janelas do XFCE.

### Controle de brilho via DDC/CI (`enableBrilho`)

Quando `enableBrilho = true`:

- O módulo NixOS ativa `hardware.i2c.enable = true` e instala `ddcutil`.
- Adicione seu usuário ao grupo **`i2c`** (`users.users.<nome>.extraGroups = [ "i2c" ];`) para acessar `/dev/i2c-*` sem `root`.
- Se você tiver mais de um monitor, pode fixar o barramento em `brilhoBus` (no Home Manager); com `brilhoBus = null` (padrão), o `brilho` usa detecção automática do `ddcutil`.

## Opções dos módulos

### Módulo NixOS (`rice.xfce-i3.*`)

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `enable` | `bool` | `false` | Habilita o ambiente XFCE + i3 e pacotes base. |
| `enableDisplayManager` | `bool` | `true` | Habilita LightDM (GTK greeter) e sessão padrão `xfce+i3`. |
| `enableBrilho` | `bool` | `false` | Ativa `hardware.i2c` e instala `ddcutil`. |
| `installFonts` | `bool` | `true` | Instala `noto-fonts`, `nerd-fonts.jetbrains-mono` e `nerd-fonts.space-mono`. |
| `installExtraApps` | `bool` | `true` | Instala aplicativos extras (`mpv` e `file-roller`). |
| `enableTerminalStack` | `bool` | `true` | Habilita `programs.fish` no sistema. |

### Módulo Home Manager (`rice.xfce-i3.*`)

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `enable` | `bool` | `false` | Ativa dotfiles, scripts e seeds do usuário. |
| `enableTerminalStack` | `bool` | `true` | Instala `kitty`, `fish`, `starship`, `zoxide`, `fzf`, `eza`, `fd`, `btop`, `fastfetch`, `yazi`, `cava` e `TERMINAL=kitty`. |
| `enableNeovim` | `bool` | `true` | Instala `neovim` com a config LazyVim (`lazy-lock.json` semeado como gravável). |
| `enableBrilho` | `bool` | `false` | Instala o script `brilho` e adiciona o indicador `genmon` ao seed do painel. |
| `brilhoBus` | `nullOr int` | `null` | Barramento I2C do monitor (`null` usa detecção automática). |
| `dpi` | `nullOr int` | `null` | DPI inicial gravado em `xsettings.xml` (ex.: `125`). |
| `cursorTheme` | `str` | `"Bibata-Modern-Ice"` | Tema de cursor inicial no seed do XFCE. |
| `cursorSize` | `int` | `24` | Tamanho inicial do cursor no seed do XFCE. |
| `iconTheme` | `str` | `"Papirus"` | Tema de ícones inicial no seed do XFCE. |
| `kitty.fontFamily` | `str` | `"JetBrainsMono Nerd Font"` | Fonte em `~/.config/kitty/current-font.conf`. |
| `kitty.fontSize` | `int \| float` | `12` | Tamanho da fonte em `~/.config/kitty/current-font.conf`. |
| `fastfetch.logo` | `str` | `"NixOS_small"` | Logo embutido do `fastfetch`. |
| `wallpaperDirs` | `listOf str` | `[]` | Diretórios extras para o seletor do `iris-wall`. |
| `initialWallpaper` | `nullOr path` | `null` | Wallpaper gravado em `~/.cache/iris/wallpaper` se não houver estado salvo. |
| `seedXfce` | `bool` | `true` | Semeia configs iniciais do XFCE/Thunar apenas se faltarem. |
| `webBrowser` | `nullOr str` | `null` | Navegador padrão inicial gravado em `~/.config/xfce4/helpers.rc`. |
| `extraI3Config` | `lines` | `""` | Linhas extras anexadas ao final de `~/.config/i3/config`. |

## Verificar e compilar

Em uma máquina com Nix + flakes habilitados e `nix-daemon` ativo:

```sh
nix flake check
nix build .#iris-colors .#skippy-xd
```
