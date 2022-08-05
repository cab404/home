{ ... }: {

  imports = [
    ./hardware-confugration.nix
    ../../../modules/home-manager
    ../../../modules/sway/system.nix
  ];

  networking.firewall.enable = false;
  networking.hostName = "jigglypuff";
  _.user = "user";

}
