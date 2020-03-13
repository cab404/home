params@ { ... }:
let
  evalCfg = import <nixpkgs/nixos/lib/eval-config.nix>;
  imports = [
    ./hardware-configuration.nix
    ./hw/dell-latitude-5400.nix
    ./secret/system.nix
    ./home-manager.nix
    ./desktop.nix
    ./core.nix
  ];
    result = builtins.trace "Should not be executed" (evalCfg {
    modules = map (import) imports;
  });
in
{
  inherit imports;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}
