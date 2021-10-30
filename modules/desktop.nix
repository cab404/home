/**
  * Desktop related configuration.
  * Desktop is all that is not a server .-.
*/
{ config, pkgs, lib, ... }@args:
with import ../lib.nix args;
{

  require = [ ./. ];

  documentation = {
    dev.enable = true;
    # makes all the external modules break builds :/
    # nixos.includeAllModules = true;
  };

  nixpkgs.config = {
    checkMeta = true;
    android_sdk.accept_license = true;
  };

  # Can't enable flatpak without this
  xdg.portal = on;

  # @balsoft's hack to enable battery levels on supported headphones
  systemd.services.bluetooth.serviceConfig.ExecStart = lib.mkForce [ "" "${pkgs.bluezFull}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf -E" ];

  services = {

    # gnunet = e;
    locate = on;
    upower = on;
    flatpak = on;

    pipewire = on // {
      jack = on;
      alsa = on;
      pulse = on;
      media-session = on;
    };

    printing = on // {
      drivers = [
        pkgs.gutenprint
      ];
    };

    logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "suspend";
      extraConfig = ''
        # IdleAction=lock
        # IdleActionSec=30
        HandlePowerKey=suspend
      '';
    };

    actkbd = on // {
      bindings = [
        { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -U 2"; }
        { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 2"; }
        # that's pretty much ctrlaltdel on steroids - lalt + super + ralt + rctrl + delete
        { keys = [ 56 97 100 111 125 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/killall -9 sway"; }
      ];
    };

    udev.packages = [
      pkgs.android-udev-rules
      pkgs.stlink
      pkgs.openocd
      (pkgs.writeTextDir "/etc/udev/rules.d/42-user-devices.rules" ''
        # Saleae Logic thing
        ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", GROUP+="dialout"
        # USBTiny
        ATTR{idVendor}=="1781", ATTR{idProduct}=="0c9f", GROUP+="dialout"
      '')
    ];

    earlyoom = on // { freeMemThreshold = 5; };

    tor = on // {
      client = on // { dns = on; };
      controlSocket = on;
    };

  };

  # == Sound
  sound.enable = true;
  hardware = {
    opengl = on;
    bluetooth = on;
    opentabletdriver = on;
  };

  # virtualisation.anbox.enable = true;
  virtualisation.podman = on;

  programs = enableThings [
    "light" # brightness control
    # "plotinus" # command pallet that doesn't work yet for some reason
    "wireshark" # should create some missing groups
  ]
    { };

  powerManagement.powertop.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    gnome3.dconf
    xfce.xfconf # programs <3 configs
  ];

  users.users."${config._.user}".extraGroups = [
    "docker"
    "containers"
    "plugdev"
    "tor"
    "wireshark"
    "libvirtd"
    "sound"
  ];

}
