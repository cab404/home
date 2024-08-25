{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%

  imports = [
    <modules/core.nix>

    <modules/cab/system.nix>
    <modules/kde/system.nix>
    <modules/home-manager>

    # usecase-specific
    <modules/recipes/ssh.nix>
    <modules/recipes/ssh-persist.nix>
    <modules/recipes/streaming.nix>
    <modules/recipes/audio.nix>
    <modules/recipes/nixld.nix>
    <modules/recipes/hwhack.nix>
    <modules/recipes/substituters.nix>
    <modules/recipes/oculus.nix>
    <modules/recipes/btkill.nix>
    <modules/recipes/splash.nix>
  ];

  # the keyboard got weird
  services.xserver.xkb = {
    layout = "us,ru";
    options = "ctrl:nocaps,misc:typo,grp:win_space_toggle,lv3:ralt_switch_multikey";
  };
  services.hardware.bolt = on;

  # services.guix.enable = true;

  # security.audit = on // {};

  # Doesn't work with Linux 6
  # virtualisation.anbox = on // {
  #   ipv4.container = {
  #     address = "10.120.0.2";
  #     prefixLength = 16;
  #   };
  #   ipv4.gateway = {
  #     address = "10.120.0.1";
  #     prefixLength = 16;
  #   };
  # };

  networking = {
    networkmanager.dns = "systemd-resolved";
    firewall = on // rec {
      checkReversePath = "loose";
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
  };

  services.resolved = {
    enable = true;
    fallbackDns = [
      "8.8.8.8" "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"
    ];
  };
  services.tailscale.enable = true;

  # nixpkgs.overlays = [ inputs.helix.overlays.default ];

  # In the grim dark future there is only NixOS
  # system.stateVersion = lib.mkForce "40000.05";
  # (enables all of the unstable features pretty much always)

  # services.power-profiles-daemon.enable = false;
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_BOOST_ON_BAT = 0;
  #     CPU_SCALING_GOVERNOR_ON_BATTERY = "schedutil";
  #     START_CHARGE_THRESH_BAT0 = 90;
  #     STOP_CHARGE_THRESH_BAT0 = 97;
  #     RUNTIME_PM_ON_BAT = "auto";
  #   };
  # };
  # it will ruin you USB devices
  # powerManagement.powertop.enable = true;

  networking.hostName = "eris";
  _.user = "cab";
  i18n.defaultLocale = "C.UTF-8";
  home-manager.users.cab = { imports = [ ./home.nix ]; };
  users.users.cab.hashedPasswordFile = "/secrets/password";
  users.users.root.hashedPasswordFile = "/secrets/password";

  nixpkgs.overlays = [
    (super: self: {
      fprintd = self.fprintd.overrideAttrs (_: {
        mesonCheckFlags = [
          "--no-suite" "fprintd:TestPamFprintd"
        ];
      });
    })
  ];

  boot.tmp.useTmpfs = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  nix.settings.system-features = [ "gccarch-alderlake" "kvm" "nixos-test"  ];

  zramSwap = on;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.udev.packages = with pkgs; [ qFlipper ];

  services.usbguard = on // {
    dbus = on;
    IPCAllowedGroups = [ "wheel" ];
  };

  services.ratbagd = on;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-run"
    "steam-original"
  ];


}
