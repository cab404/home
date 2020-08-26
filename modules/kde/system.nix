{ pkgs, config, ... }: {

  services.xserver = {
    # enabled = true;
    desktopManager.plasma5.enable = true;

    # displayManager.sddm = {
    #   enable = true;
    # };

  };

  environment.systemPackages = with pkgs; [
    kdeconnect
    redshift-plasma-applet
    flameshot
  ];

}
