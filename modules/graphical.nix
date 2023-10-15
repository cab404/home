{ config, lib, ... }: {

  require = [ ./desktop.nix ];

  fonts.fontconfig.enable = true;
  services = {

    xserver = {
      enable = true;

      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          tapping = lib.mkDefault false;
        };
      };

    };

  };

  users.users.${config._.user}.extraGroups = [ "input" ];

}
