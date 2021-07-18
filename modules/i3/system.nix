{ pkgs, config, ... }: {

  require = [ ../graphical.nix ];
  services.xserver.desktopManager.plasma5.enable = true;
  xdg = {
    portal = {
      extraPortals = [
        pkgs.xdg-desktop-portal-kde
      ];
      gtkUsePortal = true;
    };
  };
}
