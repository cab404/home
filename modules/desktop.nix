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
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-iodine
    networkmanager-l2tp
    networkmanager-strongswan
  ];
  systemd.services."NetworkManager-wait-online".wantedBy = lib.mkForce [];

  # Can't enable flatpak without this
  xdg.portal = on // {
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # HACKS: Enabling experimental features on bluetooth daemon
  systemd.services.bluetooth.serviceConfig.ExecStart = lib.mkForce [
    ""
    "${pkgs.bluez}/libexec/bluetooth/bluetoothd -f /etc/bluetooth/main.conf -E"
  ];

  # HACKS: remove if cups-browsed.service learns to shut itself down
  systemd.services.cups-browsed.serviceConfig.TimeoutStopSec=2;

  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-modify flathub 2>/dev/null || \
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      flatpak remote-modify flathub-beta 2>/dev/null || \
        flatpak remote-add --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
    '';
  };

  services = {
    # gnunet = on;

    tor = on // {
      client = on // { dns = on; };
      controlSocket = on;
    };

    locate = on // {
      package = pkgs.plocate;
    };

    avahi = on // {
      publish = on // {
        userServices = true;
      };
    };

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

    # OOOF, that was interesting never remembered it being here
    # actkbd = on // {
    #   bindings = [
    #     {
    #       keys = [ 224 ];
    #       events = [ "key" ];
    #       command = "/run/current-system/sw/bin/light -T 0.6";
    #     }
    #     {
    #       keys = [ 225 ];
    #       events = [ "key" ];
    #       command =
    #         "/run/current-system/sw/bin/light -A 0.1; /run/current-system/sw/bin/light -T 1.5";
    #     }
    #     # that's pretty much ctrlaltdel on steroids - lalt + super + ralt + rctrl + delete
    #     {
    #       keys = [ 56 97 100 111 125 ];
    #       events = [ "key" ];
    #       command = "/run/current-system/sw/bin/killall -9 sway";
    #     }
    #   ];
    # };

  };

  fonts = {
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    fontconfig = on;
    fontDir = on // { decompressFonts = true; };
  };

  boot.kernel.sysctl = { "fs.inotify.max_user_watches" = 1000000; };

  hardware = {
    graphics = on;
    bluetooth = on;
    # opentabletdriver = on;
  };

  programs = {
    # light = on; # brightness control interfering with each and every WM
    # plotinus = on; # command pallet that doesn't work yet for some reason
    wireshark = on; # should create some missing groups
  };

  environment.systemPackages = with pkgs; [
    dconf
    xfce.xfconf # programs <3 configs
    polkit_gnome # and polkit guis :\
  ];


  security.pam.loginLimits = [
    {
      domain = "@users";
      item = "rtprio";
      value = "1000";
    }
  ];

  # what a mess
  users.users."${config._.user}".extraGroups =
    [ "containers" "plugdev" "tor" "wireshark" "libvirtd" "sound" ];

}
