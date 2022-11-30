{ config, lib, pkgs, inputs, ... }@args:
with import "${inputs.self}/lib.nix" args;
{

  boot.loader.systemd-boot = on;

  # In the grim dark future there is only NixOS
  system.stateVersion = lib.mkForce "40000.05";
  # (enables all of the unstable features pretty much always)

  home-manager.users.cab = { imports = [ ./home.nix ]; };

  users.users.cab.passwordFile = "/secrets/password";
  users.users.root.passwordFile = "/secrets/password";

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "keter-builders:tkX3vAac9+Zg9v0hGcCfuPBkykQm/PNQ4/QNpz4Ulgc="
  ];

  # dns = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
  # networking.wg-quick.interfaces."keter".configFile = "/secrets/keter.conf";
  # networking.hosts = {
  #   "10.0.10.2" = [ "c1.keter" "cab404.ru" "nextcloud.cab404.ru" ];
  # };

  programs.ssh = {
    extraConfig = ''
      Host *
        ControlMaster auto
        ControlPath ~/.ssh/master-%r@%n:%p
        ControlPersist 2m
    '';
  };


  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.sensor.iio.enable = true;


  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_testing;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.resumeDevice = "/dev/disk/by-uuid/2622a677-90ba-4182-9a66-845e72710533";
  boot.kernelParams = [ 
    "mem_sleep_default=deep"
    "resume=/dev/disk/by-uuid/2622a677-90ba-4182-9a66-845e72710533"
    "resume_offset=6131420"


    "intel_pstate=no_hwp"
    "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "i915.enable_psr=1"
    "i915.enable_gvt=1"
    "nvme.noacpi=1"
  ];

  # Well, otherwise it's unbearable
  services.xserver.libinput.touchpad.tapping = lib.mkForce true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd 'zsh -ic sway'";
      };
    };
  };

  # OpenCL stuff
  environment.systemPackages = [ pkgs.clinfo ];
  hardware.opengl = on // {
    driSupport = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      vulkan-loader
    ];
  };

  # Power management tweaks

  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_BATTERY = "schedutil";
      START_CHARGE_THRESH_BAT0 = 90;
      STOP_CHARGE_THRESH_BAT0 = 97;
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  powerManagement = on // {
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };
  systemd.sleep.extraConfig = "HibernateDelaySec=30m";

  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices = {
    rootfs = {
      device = "/dev/disk/by-label/eris-enc-root";
      allowDiscards = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/eris-root";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/eris-boot";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/var/swapfile";
    size = 17 * 1024;
  }];

}
