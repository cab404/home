{ config, lib, pkgs, ... }:
let keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKIABDEIeccdbZwTgxhkVUIyZa8fx9uyiE0I2S9t4x1 cab404@meow2"
]; in
{
  services.openssh = {
    enable = true;
    settings = { PasswordAuthentication = false; };
  };

  users.users."${config._.user}".openssh.authorizedKeys.keys = keys;
  users.users.root.openssh.authorizedKeys.keys = keys;
}
