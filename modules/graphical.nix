{ config, lib, ... }: {

  require = [ ./desktop.nix ];

  # pretty much all screens I have are 200DPI+
  fonts.fontconfig = {
    allowBitmaps = false;

    enable = true;
    subpixel = {
      rgba = "none";
      lcdfilter = "none";
    };
    hinting = {
      enable = false;
    };
    antialias = false;
  };
  # services = {

  #   xserver = {
  #     enable = true;

  #     libinput = {
  #       enable = true;
  #       touchpad = {
  #         naturalScrolling = true;
  #         tapping = lib.mkDefault false;
  #       };
  #     };

  #   };

  # };

  users.users.${config._.user}.extraGroups = [ "input" "uinput" ];
  users.groups.uinput = { };
  users.groups.input = { };

}
