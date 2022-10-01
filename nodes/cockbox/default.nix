{ ... }:
let on = { enable = true; }; in
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  networking = {
    hostName = "cabriolet";
    firewall.allowedTCPPorts = [ 80 ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIKIABDEIeccdbZwTgxhkVUIyZa8fx9uyiE0I2S9t4x1 cab404@meow2"
  ];

  services = {
    openssh = on;

    headscale = on;

    dokuwiki.sites.undef = on // {
      disableActions = "register";
      extraConfig = ''
        $conf['title'] = 'undefwiki';
        $conf['userewrite'] = 1;
      '';
    };

    nginx.virtualHosts.undef = {

    };

  };
}
