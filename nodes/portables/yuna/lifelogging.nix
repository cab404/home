{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%
  services = {
    loki = on // {
      configuration = {
        auth_enabled = false;

        server = {
          http_listen_port = 3100;
        };

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring.kvstore.store = "inmemory";
            ring.replication_factor = 1;
            final_sleep = "0s";
          };
          chunk_idle_period = "5m";
          chunk_retain_period = "30s";

        };

        schema_config = {
          configs = [
            {
              store = "boltdb";
              object_store = "filesystem";

              schema = "v11";
              index = {
                period = "24h";
              };
            }
          ];
        };

        storage_config = {
          boltdb.directory = "/var/lib/loki/index";
          filesystem.directory = "/var/lib/loki/chunks";
        };
      };
    };
  };
}
