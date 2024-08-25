{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in# %%MODULE_HEADER%%
{

  xdg = on;

  programs.firefox.package = pkgs.firefox-wayland.override {
    nativeMessagingHosts = with pkgs; [
      libsForQt5.plasma-browser-integration
      browserpass
    ];
  };

  programs.zsh.shellAliases = {
    "reboot" = "qdbus org.kde.Shutdown /Shutdown logoutAndReboot";
  };

  services = {
    easyeffects = on;
    copyq = on;
  };

  # systemd.user.services.copyq.Service.Environment = lib.mkForce [ "QT_QPA_PLATFORM=wayland" ];

  systemd.user.sessionVariables = {

  #   # okay, okay, whatever.
  #   QT_QPA_PLATFORM = "wayland";

    # for some reason it doesn't want to read anything else
    SDL_VIDEODRIVER = "wayland";

  #   # self-descriptive
  #   MOZ_ENABLE_WAYLAND = "1";

  #   # actually I'm sure it's set somewhere else too
  #   GDK_BACKEND = "wayland";
  #   # DISPLAY = "_";
    # woo wrappers
    NIXOS_OZONE_WL = "1";

  #   QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Fixing java apps (especially idea)
    _JAVA_AWT_WM_NONREPARENTING = "1";

  };

}
