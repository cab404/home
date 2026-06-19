{ config, pkgs, ... }:
let
  steam-gamescope = pkgs.writeShellScriptBin "steam-gamescope" ''
    exec ${pkgs.gamescope}/bin/gamescope \
      --prefer-vk-device 1002:73bf \
      --steam \
      -- flatpak run com.valvesoftware.Steam -gamepadui
  '';

  steam-gamescope-session =
    (pkgs.writeTextDir "share/wayland-sessions/steam-gamescope.desktop" ''
      [Desktop Entry]
      Name=Steam (Flatpak Gamescope)
      Comment=Flatpak Steam Big Picture in gamescope
      Exec=${steam-gamescope}/bin/steam-gamescope
      Type=Application
      DesktopNames=gamescope
    '') // { providedSessions = [ "steam-gamescope" ]; };
in
{
  programs.gamescope.enable = true; # host gamescope + CAP_SYS_NICE

  environment.systemPackages = [ steam-gamescope ];
  services.displayManager.sessionPackages = [ steam-gamescope-session ];
}
