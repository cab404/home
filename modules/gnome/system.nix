{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in# %%MODULE_HEADER%%
{


  home-manager.users.${config._.user}.imports = [
    ./home.nix
  ];

  imports = [
    ../graphical.nix
  ];

  qt = on // {
    platformTheme = "gnome";
  };

  services.xserver.desktopManager.gnome = on // {
    sessionPath = with pkgs.gnomeExtensions; [
      pano
      caffeine
      gsconnect
      tailscale-status

      paperwm
      swap-finger-gestures-3-to-4
      gnome-40-ui-improvements
      transparent-top-bar-adjustable-transparency

      easyeffects-preset-selector

    ] ++ (with pkgs; [
      wl-clipboard
      # kdeconnect
      easyeffects
      gnome.gnome-tweaks
    ]);
  };

  services.xserver.displayManager.gdm = on;
  hardware.pulseaudio = off;

}
