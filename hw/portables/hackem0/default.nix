{ config, ... }: {

  imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./syncthing.nix
    ../../../modules/home-manager
    ../../../modules/sway/system.nix
  ];

  networking.firewall.enable = false;
  networking.hostName = "jigglypuff";
  _.user = "user";

  home-manager.users.user = {
    imports = [ ../../../modules/sway/home.nix ];
    home.keyboard = {
      layout = config.services.xserver.layout;
      options = with builtins;
        filter isString (split "," config.services.xserver.xkbOptions);
    };
  };

  users.users.user.password = "12345";
  users.users.root.password = "12345";
  security.sudo.wheelNeedsPassword = false;

}
