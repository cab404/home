{ pkgs, lib, ... }:
with lib;
{
  options = {
    _ = {
      user = mkOption {
        type = types.str;
        default = "cab";
        description = "Username for your single-user system";
      };
    };
  };
  config = {};
}
