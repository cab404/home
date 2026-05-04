{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%

  imports = [
    <modules/core.nix>

    <modules/cab/system.nix>
    <modules/kde/system.nix>
#     <modules/sway/system.nix>
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
    <modules/awg>
    <modules/recipes/tailscale.nix>
    # <modules/recipes/sunshine.nix>
  ];

  # the keyboard got weird
  services.xserver.xkb = {
    layout = "us,ru";
    options = "ctrl:nocaps,misc:typo,grp:win_space_toggle,lv3:ralt_switch_multikey";
  };
  services.hardware.bolt = on;

  networking = {
    networkmanager.dns = "systemd-resolved";
    firewall = on // rec {
      checkReversePath = "loose";
      allowedTCPPorts = [ 24800 ];
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

  networking.hostName = "baba";

  # boot.kernelPackages = with pkgs; let tune = "alderlake"; in (linuxKernel.packagesFor (linux_latest.override ({
  #   stdenv = stdenvAdapters.addAttrsToDerivation {
  #     env.KCPPFLAGS = "-march=${tune} -O3";
  #     env.KCFLAGS = "-march=${tune} -O3";
  #   } stdenv;
  # })));
  # boot.kernelPackages = with pkgs; let tune = "alderlake"; in (linuxKernel.packagesFor (linux_latest.override ({
  #   stdenv = stdenvAdapters.addAttrsToDerivation {
  #     env.KCPPFLAGS = "-march=${tune} -O2";
  #     env.KCFLAGS = "-march=${tune} -O2";
  #   } stdenv;
  # })));
  # boot.kernelPackages = with pkgs; let tune = "alderlake"; in (linuxKernel.packagesFor (linux_latest.override ({
  #   stdenv = stdenvAdapters.addAttrsToDerivation {
  #     env.KCPPFLAGS = "-march=${tune} -mtune=${tune}";
  #     env.KCFLAGS = "-march=${tune} -mtune=${tune}";
  #   } stdenv;
  # })));
  boot.kernelPackages = pkgs.linuxPackages_6_18;

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
  nix.settings.system-features = [ "gccarch-alderlake" "kvm" "nixos-test"  ];

  zramSwap = on;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.udev.packages = with pkgs; [ qFlipper ];

  # services.usbguard = on // {
  #   dbus = on;
  #   IPCAllowedGroups = [ "wheel" ];
  # };

  services.ratbagd = on;
  virtualisation.docker = {
    enable = true;
  };

  system.stateVersion = "26.05";

}
