/**
* Desktop related configuration.
* Desktop is all that is not a server .-.
*/
{ config, pkgs, lib, ... }:
let
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
    };
  _env = import ./secret/env.nix;

in
{

  imports  = [
    ./kde/system.nix
    # ./sway/system.nix
  ];

  documentation = {
    dev.enable = true;
    nixos.includeAllModules = true;
  };

  xdg = enableThings [ "portal" "mime" "sounds" "menus" "icons" "autostart" ] {};

  services = enableThings [
    "ntp" "locate" "upower" "xserver"
    "actkbd" "throttled" "blueman" "flatpak"
    "tor"
#    "gnunet"
  ] {

    logind = {
      lidSwitch = "suspend-then-hibernate";
      lidSwitchExternalPower = "suspend";
    };

    actkbd = {
      bindings = [
        {keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 2"; }
        {keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 2"; }
      ];
    };

    udev.packages = [
      pkgs.android-udev-rules
      (pkgs.writeTextDir "/etc/udev/rules.d/42-user-devices.rules" ''
      # Saleae Logic thing
      ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", GROUP+="dialout"
      # USBTiny
      ATTR{idVendor}=="1781", ATTR{idProduct}=="0c9f", GROUP+="dialout"
      '')
    ];

    xserver = {
      libinput = {
        enable = true;
        naturalScrolling = true;
        tapping = false;
      };
      wacom.enable = true;
    };

    tor = {
      controlSocket.enable = true;
      client.enable = true;
    };

  };

  # == Sound
  sound.enable = true;
  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      zeroconf.discovery.enable = true;
      daemon.config = {
        flat-volumes = "no";
      };
    };
    bluetooth.enable = true;
  };

  virtualisation.anbox.enable = true;
  virtualisation.docker.enable = true;

  programs = enableThings [
    "light" # brightness control
    "plotinus" # command pallet that doesn't work yet for some reason
    "wireshark" # should create some missing groups
  ] {};

  powerManagement.powertop.enable = true;

  environment.systemPackages = with pkgs; [
    gnome3.dconf xfce.xfconf  # programs <3 configs
  ];

  users.users."${_env.username}".extraGroups = [
    "docker" "containers" "plugdev"
    "tor" "wireshark" "libvirtd"
  ];

}
