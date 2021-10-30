{ pkgs, lib, config, ... }:
let
  env = config._;
in
with lib;
{

  options = {
    _ = {

      user = mkOption {
        type = types.str;
        default = "user";
        description = "Username for your single-user system.";
      };

      desktop = mkOption {
        type = with types; nullOr (enum [ "i3" "kde" "sway" ]);
        default = "i3";
        description = "Desktop environment to use. Can be either kde, i3 or sway. Or null.";
      };

    };
  };

}
