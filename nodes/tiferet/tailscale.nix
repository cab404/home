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
  services.headscale =
    on // {
      settings = {
        server_url = "https://hs.cab.moe";
        prefixes = {
          v4 = "100.113.0.0/16";
          v6 = "fd7a:115c:a1e0::/48";
        };
        policy.mode = "database";
        log.level = "debug";
        derp.server = {
          enabled = true;

          region_id = 999;
          region_code = "headscale";
          region_name = "Headscale Embedded DERP";

          stun_listen_addr = "0.0.0.0:3478";
          ipv4 = "51.15.83.8";
          ipv6 = "2001:bc8:1640:82b:dc00:ff:fe13:4109";
        };

        dns = {
          nameservers.global = [ "8.8.8.8" "8.8.4.4" "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
          base_domain = "keter";
          extra_records = [
            # if tailscale works, tailscale the heck out of coordination server
            {
              name = "hs.cab.moe";
              type = "A";
              value = "100.113.0.1";
            }
          ];
        };

        randomize_client_port = true;
      };
    };

  environment.defaultPackages = with pkgs; [ headscale ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ 3478 ];

}
