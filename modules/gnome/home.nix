{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in# %%MODULE_HEADER%%
{
  xdg = on // {};
  qt.enable = true;
  qt.style.name = "adwaita-dark";
  qt.platformTheme = "gnome";

  programs.firefox.package = pkgs.firefox-wayland.override { cfg.enableGnomeExtensions = true; };

  home.sessionVariables = {
    # for some reason it doesn't want to read anything else
    SDL_VIDEODRIVER = "wayland";

    # self-descriptive
    MOZ_ENABLE_WAYLAND = "1";

    # actually I'm sure it's set somewhere else too
    # GTK_BACKEND = "wayland";
    # GDK_BACKEND = "wayland";
    # woo wrappers
    NIXOS_OZONE_WL = "1";

    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Fixing java apps (especially idea)
    _JAVA_AWT_WM_NONREPARENTING = "1";

  };

}
