{ config, lib, pkgs, ... }: {
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.sshServe = {
    enable = true;
    protocol = "ssh-ng";
    write = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKIABDEIeccdbZwTgxhkVUIyZa8fx9uyiE0I2S9t4x1 cab404@meow2"
    ];
  };
  nix.settings.trusted-users = [ "nix-ssh" "cab" ];
}
