args@{ inputs, lib, config, pkgs, ... }: with import "${inputs.self}/lib.nix" args; {

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "keter-builders:tkX3vAac9+Zg9v0hGcCfuPBkykQm/PNQ4/QNpz4Ulgc="
  ];

}
