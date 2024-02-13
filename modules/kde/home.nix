{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in# %%MODULE_HEADER%%
{

  xdg = on;

  programs.firefox.package = pkgs.firefox-wayland.override {
    nativeMessagingHosts = with pkgs; [
      libsForQt5.plasma-browser-integration
      browserpass
    ];
  };

  services = {
    easyeffects = on;
    copyq = on;
  };

  systemd.user.targets.plasma = {
    Unit = {
      Description = "KDE Plasma in Wayland";
      BindsTo = ["graphical-session.target"];
      Wants = [ "graphical-session-pre.target" "xdg-desktop-autostart.target" ];
      After = ["graphical-session-pre.target"];
      Before = [ "xdg-desktop-autostart.target" ];
    };
  };

  home.packages = [
    (pkgs.writeShellScriptBin "plasma" ''
      dbus-run-session startplasma-wayland 2>&1 & systemctl start --user plasma.target
      systemctl stop --user plasma.target
    '')
  ];

  systemd.user.services.copyq.Service.Environment = lib.mkForce [ "QT_QPA_PLATFORM=wayland" ];

  home.sessionVariables = {
    # for some reason it doesn't want to read anything else
    SDL_VIDEODRIVER = "wayland";

    # self-descriptive
    MOZ_ENABLE_WAYLAND = "1";

    # actually I'm sure it's set somewhere else too
    GDK_BACKEND = "wayland";
    # DISPLAY = "_";
    # woo wrappers
    NIXOS_OZONE_WL = "1";

    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Fixing java apps (especially idea)
    _JAVA_AWT_WM_NONREPARENTING = "1";

  };

}
