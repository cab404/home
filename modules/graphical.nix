{ config, ... }: {

  require = [ ./desktop.nix ];

  fonts.fontconfig.enable = true;
  services = {

    xserver = {
      enable = true;

      displayManager.autoLogin = {
        enable = true;
        user = "${config._.user}";
      };

      libinput = {
        enable = true;
        naturalScrolling = true;
        tapping = false;
      };
      wacom.enable = true;
    };

  };

}
