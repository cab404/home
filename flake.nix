{
  description = "cab's system config";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://helix.cachix.org"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };

  inputs = {

    helix.url = "github:helix-editor/helix";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    snm.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";

    # emacs-overlay.url = "github:nix-community/emacs-overlay";
    # emacs-overlay.follows = "nix-doom-emacs/emacs-overlay";

    # deploy-rs.url = "github:serokell/deploy-rs";
    # deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hw.url = "github:nixos/nixos-hardware";

    wg-bond.url = "github:cab404/wg-bond";
    wg-bond.inputs.nixpkgs.follows = "nixpkgs";

    # nix-doom-emacs.url = "github:thiagokokada/nix-doom-emacs";
    # nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";

    gtch.url = "/home/cab/data/cab/ticket-checker";
    gtch.inputs.nixpkgs.follows = "nixpkgs";

    swaycwd.url = "sourcehut:~cab/swaycwd";

  };

  outputs = inputs @ {  self
                      , nixpkgs
                      , home-manager
                      , wg-bond
                      , ... }:
    let
      system = "x86_64-linux";
      patchedPkgs =
        let
          patches = [
            # Place your nixpkgs patches here
          ];
          patched = import "${nixpkgs.legacyPackages.${system}.applyPatches {
              inherit patches;
              name = "nixpkgs-patched";
              src = nixpkgs;
          }}/flake.nix";
          invoked = patched.outputs { self = invoked; };
        in
        if builtins.length patches > 0 then invoked else nixpkgs;

      inherit (patchedPkgs) lib;

      prelude = import ./modules/prelude.nix { lib = nixpkgs.lib; };

      specialArgs = {
        inherit inputs prelude;
      };

      buildConfig = modules: system: { inherit modules system specialArgs; };
      buildSystem = modules: system: lib.nixosSystem (buildConfig modules system);

      hosts = [
        ./nodes/keter/tiferet
        ./nodes/keter/c1
      ];
      
      hostAttrs = dir: {
        settings = import "${dir}/host-metadata.nix";
        config = import "${dir}/configuration.nix";
        hw-config = import "${dir}/hardware-configuration.nix";
      };

      node = dir: with hostAttrs dir; buildSystem [
        config
        hw-config
      ]
        settings.system;

      virt-node = dir: with hostAttrs dir; buildSystem [
        config
        "${nixpkgs}/nixos/modules/virtualisation/build-vm.nix"
      ]
        settings.system;

      onPkgs = f: builtins.mapAttrs f patchedPkgs.legacyPackages;
     
    in
    {

      nixosConfigurations =
        {
          # My notebook
          yuna = node ./nodes/portables/yuna;

          # My new notebook
          eris = node ./nodes/portables/eris;

          # First server
          c1 = node ./nodes/keter/c1;

          # Scaleway proxy
          tiferet = node ./nodes/keter/tiferet;

          # My printer
          fudemonix = node ./nodes/fudemonix;

          # Yup, installer
          installer = buildSystem [
            (nixpkgs + (toString /nixos/modules/installer/cd-dvd/installation-cd-base.nix))
            ./modules/home-manager
            ./modules/sway/system.nix
            ./modules/core.nix
            ({ config, lib, pkgs, ... }: {
              _.user = "nixos";
              boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
              networking.wireless.enable = false;
              home-manager.users.${config._.user}.imports = [
                ./modules/sway/core.nix
              ];
            })
          ];
        }; #// (builtins.mapAttrs (k: v: buildSystem v) (import ./nodes/keter));

      devShells = onPkgs (system: pkgs: with pkgs; {
        default = mkShell {
          buildInputs = [
            nixUnstable
            nixpkgs-fmt
            rnix-lsp
            # wg-bond.defaultPackage.${system}
          ];
        };
      });

      packages = {
        x86_64-linux.vm = (virt-node ./nodes/portables/eris).config.system.build.vm;
      };

      nodeMeta = with builtins; with nixpkgs.lib; listToAttrs (map 
        (path: let meta = hostAttrs path; in 
          { name = toString (baseNameOf path); value = meta; }
        ) 
        hosts
      );
    };

}
