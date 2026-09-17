{ config, pkgs, lib, prelude, ... }: with prelude; {


  home-manager.users.${config._.user}.imports = [
    ./home.nix
  ];

  imports = [
    ../graphical.nix
  ];

  fonts = {
    enableDefaultFonts = true;

    fontconfig = on // {
      defaultFonts = {
        monospace = ["Fira Mono"];
      };
    };

    fonts = with pkgs; [
      source-code-pro noto-fonts
      roboto fira-code fira
      font-awesome
      orbitron
    ];

  };

  services = {

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd}/bin/agreety --cmd 'dbus-launch sway'";
        };
      };
    };

  };

  # That adds /etc/sway/config.d/nixos.conf with one important line.
  # Yeah, I'm too lazy to copy it here.
  # also it enables whole bunch of other options, which I am too lazy to describe here.
  # just look at <nixpkgs/nixos/modules/programs/sway.nix>
  programs.sway = on;
  programs.wshowkeys = on;

  # That makes screensharing possible
  xdg = {
    portal = on // {
     extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
     wlr = on // {
       settings.screencast = {
         chooser_type = "dmenu";
         chooser_cmd = "${pkgs.rofi}/bin/rofi -dmenu";
         max_fps = 30;
       };
     };
    };
  };

}
