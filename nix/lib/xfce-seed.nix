# Gera arquivos iniciais do XFCE higienizados e portáveis para o primeiro login.
# Eles são apenas copiados (se ainda não existirem) pelo Home Manager para não
# impedir mudanças pela interface do XFCE nem a troca de tema ao vivo pelo iris-wall.
{
  pkgs,
  lib,
  riceScripts,
  homeDirectory,
  enableTerminalStack ? true,
  enableBrilho ? false,
  dpi ? null,
  cursorTheme ? "Bibata-Modern-Ice",
  cursorSize ? 24,
  iconTheme ? "Papirus",
  webBrowser ? null,
}:

let
  # Remove X-XFCE-Source=file:///usr/share/... dos lançadores do painel
  stripXfceSource =
    path:
    let
      lines = lib.splitString "\n" (builtins.readFile path);
      kept = builtins.filter (line: !(lib.hasPrefix "X-XFCE-Source=" line)) lines;
    in
    lib.concatStringsSep "\n" kept;

  helpersContent =
    (lib.optionalString (webBrowser != null) ''
      WebBrowser=${webBrowser}
    '')
    + (lib.optionalString enableTerminalStack ''
      TerminalEmulator=kitty
      TerminalEmulatorDismissed=true
    '');

  panelXml = pkgs.writeText "xfce4-panel.xml" ''
    <?xml version="1.1" encoding="UTF-8"?>

    <channel name="xfce4-panel" version="1.0">
      <property name="configver" type="int" value="2"/>
      <property name="plugins" type="empty">
        <property name="plugin-2" type="string" value="tasklist">
          <property name="grouping" type="uint" value="1"/>
          <property name="include-all-workspaces" type="bool" value="false"/>
        </property>
        <property name="plugin-3" type="string" value="separator">
          <property name="expand" type="bool" value="true"/>
          <property name="style" type="uint" value="0"/>
        </property>
        <property name="plugin-4" type="string" value="pager">
          <property name="miniature-view" type="bool" value="false"/>
          <property name="rows" type="uint" value="1"/>
        </property>
        <property name="plugin-5" type="string" value="separator">
          <property name="style" type="uint" value="0"/>
        </property>
        <property name="plugin-6" type="string" value="systray">
          <property name="square-icons" type="bool" value="true"/>
        </property>
        <property name="plugin-7" type="string" value="separator">
          <property name="style" type="uint" value="0"/>
        </property>
        <property name="plugin-8" type="string" value="clock">
          <property name="mode" type="uint" value="2"/>
        </property>
        <property name="plugin-9" type="string" value="separator">
          <property name="style" type="uint" value="0"/>
        </property>
        <property name="plugin-10" type="string" value="actions"/>
        <property name="plugin-13" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="17950471821.desktop"/>
          </property>
        </property>
        <property name="plugin-14" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="17950471822.desktop"/>
          </property>
        </property>
        <property name="plugin-15" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="17950471833.desktop"/>
          </property>
        </property>
        <property name="plugin-16" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="17950471834.desktop"/>
          </property>
        </property>
        <property name="plugin-18" type="string" value="directorymenu">
          <property name="base-directory" type="string" value="${homeDirectory}"/>
        </property>
        <property name="plugin-20" type="string" value="pulseaudio">
          <property name="enable-keyboard-shortcuts" type="bool" value="true"/>
        </property>
        <property name="plugin-22" type="string" value="xfce4-clipman-plugin"/>
        <property name="plugin-1" type="string" value="applicationsmenu"/>
    ${lib.optionalString enableBrilho ''
          <property name="plugin-21" type="string" value="genmon">
            <property name="command" type="string" value="${riceScripts}/bin/brilho panel"/>
            <property name="use-label" type="bool" value="false"/>
            <property name="update-period" type="int" value="1500"/>
          </property>
    ''}  </property>
      <property name="panels" type="array">
        <value type="int" value="1"/>
        <property name="dark-mode" type="bool" value="true"/>
        <property name="panel-1" type="empty">
          <property name="position" type="string" value="p=6;x=0;y=0"/>
          <property name="length" type="double" value="100"/>
          <property name="position-locked" type="bool" value="true"/>
          <property name="size" type="uint" value="34"/>
          <property name="icon-size" type="uint" value="22"/>
          <property name="mode" type="uint" value="0"/>
          <property name="plugin-ids" type="array">
            <value type="int" value="1"/>
            <value type="int" value="4"/>
            <value type="int" value="5"/>
            <value type="int" value="2"/>
            <value type="int" value="3"/>
            <value type="int" value="13"/>
            <value type="int" value="14"/>
            <value type="int" value="15"/>
            <value type="int" value="16"/>
            <value type="int" value="18"/>
            <value type="int" value="7"/>
    ${lib.optionalString enableBrilho ''        <value type="int" value="21"/>
    ''}        <value type="int" value="20"/>
            <value type="int" value="22"/>
            <value type="int" value="6"/>
            <value type="int" value="8"/>
            <value type="int" value="9"/>
            <value type="int" value="10"/>
          </property>
        </property>
      </property>
    </channel>
  '';

  notifydXml = pkgs.writeText "xfce4-notifyd.xml" ''
    <?xml version="1.1" encoding="UTF-8"?>

    <channel name="xfce4-notifyd" version="1.0">
      <property name="log-max-size-enabled" type="bool" value="true"/>
      <property name="theme" type="string" value="Iris-A"/>
      <property name="initial-opacity" type="double" value="1"/>
      <property name="do-fadeout" type="bool" value="false"/>
      <property name="do-slideout" type="bool" value="false"/>
    </channel>
  '';

  # Não sobrescrevemos Client0_Command: no NixOS a sessão xfce+i3 já sobe o i3 diretamente
  sessionXml = pkgs.writeText "xfce4-session.xml" ''
    <?xml version="1.1" encoding="UTF-8"?>

    <channel name="xfce4-session" version="1.0">
      <property name="general" type="empty">
        <property name="SaveOnExit" type="bool" value="false"/>
      </property>
    </channel>
  '';

  xsettingsXml = pkgs.writeText "xsettings.xml" ''
    <?xml version="1.1" encoding="UTF-8"?>

    <channel name="xsettings" version="1.0">
      <property name="Net" type="empty">
        <property name="ThemeName" type="string" value="Iris-A"/>
        <property name="IconThemeName" type="string" value="${iconTheme}"/>
      </property>
      <property name="Xft" type="empty">
        ${
          if dpi != null then
            ''<property name="DPI" type="int" value="${toString dpi}"/>''
          else
            ''<property name="DPI" type="empty"/>''
        }
        <property name="HintStyle" type="string" value="hintslight"/>
        <property name="RGBA" type="string" value="rgb"/>
      </property>
      <property name="Gtk" type="empty">
        <property name="CursorThemeName" type="string" value="${cursorTheme}"/>
        <property name="CursorThemeSize" type="int" value="${toString cursorSize}"/>
        <property name="DecorationLayout" type="string" value="icon,menu:minimize,maximize,close"/>
      </property>
    </channel>
  '';

  ucaXml = pkgs.writeText "uca.xml" (
    builtins.replaceStrings [ "/home/geko/.local/bin/iris-wall" ] [ "${riceScripts}/bin/iris-wall" ] (
      builtins.readFile ../../xfce/uca.xml
    )
  );
in
{
  "xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" = panelXml;
  "xfce4/xfconf/xfce-perchannel-xml/xfce4-notifyd.xml" = notifydXml;
  "xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml" =
    ../../xfce/xfconf/xfce4-keyboard-shortcuts.xml;
  "xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml" = sessionXml;
  "xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" = xsettingsXml;

  "xfce4/panel/launcher-13/17950471821.desktop" = pkgs.writeText "17950471821.desktop" (
    stripXfceSource ../../xfce/panel/launcher-13/17950471821.desktop
  );
  "xfce4/panel/launcher-14/17950471822.desktop" = pkgs.writeText "17950471822.desktop" (
    stripXfceSource ../../xfce/panel/launcher-14/17950471822.desktop
  );
  "xfce4/panel/launcher-15/17950471833.desktop" = pkgs.writeText "17950471833.desktop" (
    stripXfceSource ../../xfce/panel/launcher-15/17950471833.desktop
  );
  "xfce4/panel/launcher-16/17950471834.desktop" = pkgs.writeText "17950471834.desktop" (
    stripXfceSource ../../xfce/panel/launcher-16/17950471834.desktop
  );

  "Thunar/uca.xml" = ucaXml;
}
// lib.optionalAttrs (helpersContent != "") {
  "xfce4/helpers.rc" = pkgs.writeText "helpers.rc" helpersContent;
}
