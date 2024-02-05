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
    kdeconnect = on;
    copyq = on;
  };

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

  # Required for some (flameshot, lol) tray services to work
  # systemd.user.targets = {
  #   # Copied from <home-manager/modules/xsession.nix>
  #   tray = {
  #     Unit = {
  #       Description = "Home Manager System Tray";
  #       Requires = [ "graphical-session-pre.target" ];
  #     };
  #   };
  # };

}