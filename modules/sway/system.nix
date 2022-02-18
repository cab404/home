{ config, pkgs, lib, ... }@args:
with import ../../lib.nix args; {

  require = [ ../desktop.nix ];

  users.users.${config._.user}.extraGroups = [ "input" ];

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
    gvfs = on;
    gnome = {
      gnome-online-miners = on;
      sushi = on;
    };

    syslogd.enable = true;

  };

  # That adds /etc/sway/config.d/nixos.conf with one important line.
  # Yeah, I'm too lazy to copy it here.
  # also it enables whole bunch of other options, which I am too lazy to describe here.
  # just look at <nixpkgs/nixos/modules/programs/sway.nix>
  programs.sway = on;

  xdg = {
    portal = {
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      wlr = on;
      gtkUsePortal = true;
    };
  };

}
