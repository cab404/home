# Hacks to get all of the windows look nice
# Tries to convince QT to be GTK, and GTK to be uniform
#
{ config, pkgs, lib, inputs, ... }@args:
with import "${inputs.self}/lib.nix" args; {

  home = {
    packages = with pkgs; [ qt5.qtwayland libsForQt5.qtstyleplugins ];

    pointerCursor = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita";
      size = 14;
    };
  };

  fonts.fontconfig = on;

  wayland.windowManager.sway = on // {
    config.seat."*" = {
      xcursor_theme = "${config.home.pointerCursor.name} ${
          toString config.home.pointerCursor.size
        }";
    };
  };

  gtk = on // {
    iconTheme.package = pkgs.gnome3.adwaita-icon-theme;
    iconTheme.name = "Adwaita";

    font.name = "Noto Sans";
    font.size = 10;

    gtk2.extraConfig = ''
      gtk-enable-animations=1
      gtk-primary-button-warps-slider=0
      gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
      gtk-cursor-theme-name=${config.home.pointerCursor.name}
      gtk-cursor-theme-size=${toString config.home.pointerCursor.size}
      gtk-menu-images=1
      gtk-button-images=1
    '';
    theme.package = pkgs.gnome-themes-extra;
    theme.name = "Adwaita-dark";
  };

  qt = on // {
    platformTheme = "gtk";
    style.name = "gtk2";
    # platformTheme = "gnome";
    # style.package = pkgs.adwaita-qt;
    # style.name = "adwaita";
  };

}
