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
      wireplumber = on;
      # media-session = on;
    };

    printing = on // {
      drivers = [
        pkgs.gutenprint
      ];
    };

    logind = {
      lidSwitch = "ignore";
      lidSwitchExternalPower = "ignore";
      extraConfig = ''
        # IdleAction=lock
        # IdleActionSec=30
        HandlePowerKey=suspend
      '';
    };

    actkbd = on // {
      bindings = [
        { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -T 0.6"; }
        { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -A 0.1; /run/current-system/sw/bin/light -T 1.5"; }
        # that's pretty much ctrlaltdel on steroids - lalt + super + ralt + rctrl + delete
        { keys = [ 56 97 100 111 125 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/killall -9 sway"; }
      ];
    };

    udev.packages = with pkgs; [
      android-udev-rules
      stlink
      openocd
      (writeTextDir "/etc/udev/rules.d/42-user-devices.rules" ''
        # Saleae Logic thing
        ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", GROUP+="dialout"
        # USBTiny
        ATTR{idVendor}=="1781", ATTR{idProduct}=="0c9f", GROUP+="dialout"
      '')
      ledger-udev-rules
    ];

    tor = on // {
      client = on // { dns = on; };
      controlSocket = on;
    };

  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1000000;
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
    dconf
    xfce.xfconf # programs <3 configs
    polkit_gnome # and polkit guis :\
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
