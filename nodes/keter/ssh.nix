{
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKIABDEIeccdbZwTgxhkVUIyZa8fx9uyiE0I2S9t4x1 cab404@meow2"
  ];
}
