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

    };
  };

}
