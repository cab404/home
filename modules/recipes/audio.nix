args@{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in {

  # == Sound
  sound.enable = true;

  services = {

    pipewire = on // {
      config.pipewire = {
        "context.modules" = [
          {
            args = { "nice.level" = -11; };
            flags = [ "ifexists" "nofail" ];
            name = "libpipewire-module-rt";
          }
          { name = "libpipewire-module-protocol-native"; }
          { name = "libpipewire-module-profiler"; }
          { name = "libpipewire-module-metadata"; }
          { name = "libpipewire-module-spa-device-factory"; }
          { name = "libpipewire-module-spa-node-factory"; }
          { name = "libpipewire-module-client-node"; }
          { name = "libpipewire-module-client-device"; }
          {
            flags = [ "ifexists" "nofail" ];
            name = "libpipewire-module-portal";
          }
          {
            args = { };
            name = "libpipewire-module-access";
          }
          { name = "libpipewire-module-adapter"; }

          # Config to make pipewire discover stuff around it with zeroconf.
          { name = "libpipewire-module-link-factory"; }
          { name = "libpipewire-module-session-manager"; }
          { name = "libpipewire-module-zeroconf-discover"; }
          { name = "libpipewire-module-raop-discover"; }
        ];
      };
      audio = on;
      jack = on;
      alsa = on;
      pulse = on;
      wireplumber.enable = true;
    };

  };

}
