{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in # %%MODULE_HEADER%%
{

  environment.systemPackages = [
    pkgs.gnomeExtensions.paperwm
  ];

  imports = [
    ../graphical.nix
  ];

  qt = on // {
    platformTheme = "gnome";
  };

  services.xserver.desktopManager.gnome = on;
  services.xserver.displayManager.gdm = on;

  hardware.pulseaudio = off;

}
