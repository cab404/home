{ config, lib, pkgs, ... }: {
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  nix.sshServe = {
    enable = true;
    protocol = "ssh-ng";
    write = true;
    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKIABDEIeccdbZwTgxhkVUIyZa8fx9uyiE0I2S9t4x1 cab404@meow2"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEgAO0bGm5PSAfGsCetUSjcXvU9WZfq9DUsVAF8KQnae (none)"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF4B9EMG/2eoxh4mzML+Ooh4rGvjn3MRojBlv2EnjQpE vcool07@vcool07-ThinkPad-E14"
    ];
  };
  nix.settings.trusted-users = [ "nix-ssh" "cab" ];
}
