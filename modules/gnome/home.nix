{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in# %%MODULE_HEADER%%
{
  services.copyq = on;

  xdg = on;
  qt.enable = true;
  qt.style.name = "adwaita-dark";
  qt.platformTheme = "gnome";

  # systemd.user.services.dbus.environment.PATH = "/run/wrappers/bin:/home/cab/.local/share/flatpak/exports/bin:/var/lib/flatpak/exports/bin:/home/cab/.nix-profile/bin:/etc/profiles/per-user/cab/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";

  programs.firefox.package = pkgs.firefox.override {
    cfg.enableGnomeExtensions = true;
  };
  services = {
    easyeffects = on;
    flameshot = on;
  };

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
