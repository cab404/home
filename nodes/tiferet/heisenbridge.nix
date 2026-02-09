args@{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in {
  # services.matterbridge = on // {
  #   configPath = "/secrets/matterbridge.toml";
  # };

  # services.caddy = on // {
  #   virtualHosts = {
  #     "hb.cab.moe".extraConfig = ''
  #        reverse_proxy localhost:8008
  #     '';
  #   };
  # };

}

