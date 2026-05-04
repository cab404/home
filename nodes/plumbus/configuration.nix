# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

args@{ config, pkgs, inputs, prelude, ... }:
with prelude; let __findFile = prelude.__findFile; in

{

  imports =
    [
      # Include the results of the hardware scan.
      ./klipper.nix
      ./klipperscreen.nix
      <modules/tmplog.nix>
      <modules/barecore.nix>
      <modules/recipes/tailscale.nix>
    ];

  # documentation.nixos.includeAllModules = true;
  documentation.nixos.options.warningsAreErrors = false;

  hardware.raspberry-pi.config.all.options.arm_boost.enable = false;
  networking.hostName = "plumbus";

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  time.timeZone = "Asia/Yerevan";
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.systemWide = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "dialout" "video" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      waypipe
    ];
  };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    uhubctl
    ffmpeg
    gphoto2
  ];

  services.openssh.enable = true;
  services.udev.extraRules = ''
    ## rule to restart klipper when the printer is connected via usb ${pkgs.coreutils}/bin/echo RESTART > /run/klipper/tty;
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", ACTION=="remove", RUN+="${pkgs.uhubctl}/bin/uhubctl -l 1-1 -a 2 -R"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", ACTION=="add", RUN+="${pkgs.coreutils}/bin/echo RESTART > /run/klipper/tty;"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", ACTION=="add", RUN+="${pkgs.bash}/bin/sh -c '${pkgs.systemd}/bin/systemctl restart klipper'"
  '';

  networking.firewall.enable = false;

  users.users.root.hashedPassword = "$y$j9T$q4c/.wjNYg7nzUL4/38Ef0$P0nfnjRF/GZRxcLfeDkHupcoZWnr7fP.KvzpB1TiqY.";

  system.stateVersion = "25.05"; # Did you read the comment?
}
