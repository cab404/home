{ pkgs, lib, config, ... }:
let
  env = config._;
in
with lib; with types;
{

  options = {
    users.users = mkOption {
      type = attrsOf (submodule {
        options.homeModules = {
          type = listOf path;
          default = [];
          description = "List of modules to include in a home profile.";
        };
      });
    };

    _ = {

      user = mkOption {
        type = str;
        default = "user";
        description = "Username for your single-user system.";
      };

      # multiuser = mkOption {
      #   default = {
      #     ${env.user} = {

      #     };
      #   };
      #   type = attrsOf {
      #     homeModules = {
      #       type = listOf path;
      #       default = [];
      #       description = "List of modules to include in a home profile.";
      #     };
      #     nixTrusted = {
      #       type = bool;
      #       default = true;
      #       description = "Whether the user is entrusted with Nix daemon.";
      #     };
      #   };
      # };

    };

  };

  config = {

    # users = {
    #   mutableUsers = false;
    #   users = builtins.mapAttrs (username: opts:
    #     {
    #       shell = pkgs.zsh;
    #       isNormalUser = true;
    #       extraGroups = [
    #         "plugdev"
    #         "wheel"
    #         "containers"
    #         "networkmanager"
    #         "dialout"
    #         "video"
    #       ];
    #     }
    #     ) env.multiuser;
    # };

    # users = {
    #   mutableUsers = false;
    #   users."${config._.user}" = {
    #     isNormalUser = true;
    #     extraGroups = [
    #       "plugdev"
    #       "wheel"
    #       "containers"
    #       "networkmanager"
    #       "dialout"
    #       "video"
    #     ];
    #     shell = pkgs.zsh;
    #   };
    #   users.root.shell = pkgs.zsh;
    # };


  };

}
