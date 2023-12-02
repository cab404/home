args@{ pkgs, config, inputs, prelude, ... }:
with prelude; let __findFile = prelude.__findFile; in
{
  services.tailscale = on;
  systemd.services.headscale = {
    # It is dumb-ish
    serviceConfig.TimeoutStopSec = 2;
    environment = {
      HEADSCALE_EXPERIMENTAL_FEATURE_SSH = "1";
    };
  };
  services.headscale = let 
    aclFile = builtins.toFile "acl.json" acl;
    accept = src: dst: { action = "accept"; inherit src dst; }; 
    deny = src: dst: { action = "deny"; inherit src dst; }; 
    acl = builtins.toJSON {
      acls = [
        (accept ["*"] ["*:*"])
      ];
      ssh = [
        (accept ["*"] ["*"] // {users = ["*"];}) 
      ];
      autoApprovers = {
        exitNode = [ "*" ];
      };
    };  
  in
    on // {
      settings = {
        server_url = "https://hs.cab.moe";
        # ip_prefixes = [ 
        #   "100.64.0.0/10" 
        #   "fd80:b4b4:c4b4::/48"
        # ];
        acl_policy_path = aclFile;
        log.level = "debug";
        dns_config = {
          nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          base_domain = "keter";
        };
      };
    };

  environment.defaultPackages = with pkgs; [ headscale ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

}