# Desktop related configuration.
# Desktop is all that is not a server .-.
{ config, pkgs, lib, ... }@args:
with import ../lib.nix args; {

  require = [
    ./.
    ./recipes/audio.nix
  ];

  documentation = {
    dev.enable = true;
    # makes all the external modules break builds :/
    # nixos.includeAllModules = true;
  };

  nixpkgs.config.android_sdk.accept_license = true;

  # Yeah, desktop needs one
  networking.networkmanager.enable = true;

  # Can't enable flatpak without this
  xdg.portal = on // {
    # xdgOpenUsePortal = true;
  };

  # Enabling experimental features on bluetooth daemon
  systemd.services.bluetooth.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.bluezFull}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf -E"
  ];

  services = {
    # yeah, bluetooth
    blueman = on;

    gnunet = on;

    tor = on // {
      client = on // { dns = on; };
      controlSocket = on;
    };

    locate = on // {
      locate = pkgs.plocate;
      localuser = null;
    };

    udev.packages = with pkgs; [
      android-udev-rules
    ];

    flatpak = on;

    printing = on // { drivers = [ pkgs.gutenprint ]; };

    # logind = lib.mkDefault {
    #   # lidSwitch = "hybrid-sleep";
    #   # lidSwitchExternalPower = "hybrid-sleep";
    #   extraConfig = ''
    #     # IdleAction=lock
    #     # IdleActionSec=30
    #     HandlePowerKey=suspend
    #   '';
    # };

    actkbd = on // {
      bindings = [
        {
          keys = [ 224 ];
          events = [ "key" ];
          command = "/run/current-system/sw/bin/light -T 0.6";
        }
        {
          keys = [ 225 ];
          events = [ "key" ];
          command =
            "/run/current-system/sw/bin/light -A 0.1; /run/current-system/sw/bin/light -T 1.5";
        }
        # that's pretty much ctrlaltdel on steroids - lalt + super + ralt + rctrl + delete
        {
          keys = [ 56 97 100 111 125 ];
          events = [ "key" ];
          command = "/run/current-system/sw/bin/killall -9 sway";
        }
      ];
    };

  };

  boot.kernel.sysctl = { "fs.inotify.max_user_watches" = 1000000; };

  hardware = {
    opengl = on;
    bluetooth = on;
#    opentabletdriver = on;
  };

  virtualisation.podman = on;

  programs = {
    light = on; # brightness control
#    plotinus = on; # command pallet that doesn't work yet for some reason
    wireshark = on; # should create some missing groups
  };

  environment.systemPackages = with pkgs; [
    dconf
    xfce.xfconf # programs <3 configs
    polkit_gnome # and polkit guis :\
  ];

  users.users."${config._.user}".extraGroups =
    [ "docker" "containers" "plugdev" "tor" "wireshark" "libvirtd" "sound" ];

}
