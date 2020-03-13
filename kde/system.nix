{ pkgs, ... } :
let
  env = import ../secret/env.nix;
in
{

  services.xserver = {
    # enabled = true;
    desktopManager.plasma5.enable = true;

    displayManager.sddm = {
      enable = true;
      autoLogin = {
        enable = true;
        user = env.username;
      };
    };

  };

  environment.systemPackages = with pkgs; [
    kdeconnect
    redshift-plasma-applet
    flameshot
  ];

}
