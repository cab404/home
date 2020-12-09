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

  # I want warnings on unfree software, but I won't stay completely free, if
  # that shatters my productivity
  forgiveMeStallman = package: package.overrideAttrs(a: { meta = {}; });
in
{

  require = [ ./. ];

  documentation = {
    dev.enable = true;
    # makes all the external modules break builds :/ # nixos.includeAllModules = true;
  };

  xdg = enableThings [ "portal" "mime" "sounds" "menus" "icons" "autostart" ] {};

  boot.extraModulePackages = with config.boot.kernelPackages; [
    # It doesn't build :| (forgiveMeStallman amdgpu-pro)
  ];

  nixpkgs.config = {
    checkMeta = true;
    android_sdk.accept_license = true;
  };

  fonts.fontconfig.enable = true;

  services = enableThings [
    "ntp" "locate" "xserver"
    "actkbd" "flatpak"
    "tor" "gnunet" "earlyoom" "printing"
  ] {

    printing.drivers = [
      pkgs.gutenprint
    ];

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
      pkgs.stlink
      (pkgs.writeTextDir "/etc/udev/rules.d/42-user-devices.rules" ''
      # Saleae Logic thing
      ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", GROUP+="dialout"
      # USBTiny
      ATTR{idVendor}=="1781", ATTR{idProduct}=="0c9f", GROUP+="dialout"
      '')
    ];

    earlyoom.freeMemThreshold = 5;

    tor = {
      controlSocket.enable = true;
      client.enable = true;
    };

  };

  # == Sound
  sound.enable = true;
  hardware = {
    opengl.enable = true;
    pulseaudio = {
      enable = true;
      extraModules = with pkgs; [
        pulseaudio-modules-bt
      ];
      package = pkgs.pulseaudioFull;
      zeroconf.discovery.enable = true;
      daemon.config = {
        flat-volumes = "no";
      };
    };
    bluetooth.enable = true;
  };

  # virtualisation.anbox.enable = true;
  virtualisation.docker.enable = true;

  programs = enableThings [
    "light" # brightness control
    # "plotinus" # command pallet that doesn't work yet for some reason
    "wireshark" # should create some missing groups
  ] {};

  powerManagement.powertop.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    gnome3.dconf xfce.xfconf  # programs <3 configs
  ];

  users.users."${config._.user}".extraGroups = [
    "docker" "containers" "plugdev"
    "tor" "wireshark" "libvirtd"
  ];

}
