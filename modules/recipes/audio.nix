args@{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in {

  # == Sound
  sound.enable = true;
  security.rtkit = on;
  
  # == You won't believe how I found this :D
  networking.firewall.allowedUDPPorts = [ 6001 6002 ];
  # == okay, you would . but it was not obvious!
  # yeah, these are timer and control sockets which are
  # required by apple implementation of proto, but
  # not by shairport-sync

  services = {
    pipewire = on // {
      audio = on;
      jack = on;
      alsa = on;
      pulse = on;
      wireplumber.enable = true;
      extraConfig = {
        pipewire = {
          "100-user" = {
            "context.modules" = [
              # Config to make pipewire discover stuff around it with zeroconf.
              { name = "libpipewire-module-zeroconf-discover"; }
              { name = "libpipewire-module-raop-discover"; 
                raop.autoreconnect = true;
              }
            ];
          };
        };
      };
    };

  };

}
