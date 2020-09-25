{ pkgs, config, ... }: {

  require = [ ../graphical.nix ];

  services.xserver = {
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  environment.systemPackages = with pkgs; [
  ];

}
