{
  description = "cab's system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
#    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hw.url = "github:nixos/nixos-hardware";

    wg-bond.url = "github:cab404/wg-bond";
    wg-bond.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";

    swaycwd.url = "sourcehut:~cab/swaycwd";

  };

  outputs = inputs @ { self, nixpkgs, home-manager, emacs-overlay, deploy-rs, wg-bond, ... }:
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
      hostAttrs = dir: {
        settings = import "${dir}/host-metadata.nix";
        config = import "${dir}/configuration.nix";
        hw-config = import "${dir}/hardware-configuration.nix";
      };
      node = dir: with hostAttrs dir; buildSystem [
        config
        hw-config
      ] settings.system;

      onPkgs = f: builtins.mapAttrs f patchedPkgs.legacyPackages;
      deployNixos = s: deploy-rs.lib.${s.pkgs.system}.activate.nixos s;
      deployHomeManager = sys: s: deploy-rs.lib.${sys}.activate.home-manager s;

    in
    {

      nixosConfigurations =
        {
          # My notebook
          yuna = node ./nodes/portables/yuna;

          # My new notebook
          eris = node ./nodes/portables/eris;

          # My printer
          fudemonix = node ./nodes/fudemonix;

          # Yup, installer
          installer = buildSystem [
            (nixpkgs + (toString /nixos/modules/installer/cd-dvd/installation-cd-base.nix))
            ./modules/home-manager
            ./modules/sway/system.nix
            ./modules/core.nix
            ({config, lib, pkgs, ...}: {
              _.user = "nixos";
              boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
              networking.wireless.enable = false;
              home-manager.users.${config._.user}.imports = [
                ./modules/sway/core.nix
              ];
            })
          ];
        } // (builtins.mapAttrs (k: v: buildSystem v) (import ./nodes/keter));

      deploy = {

        autoRollback = true;
        magicRollback = true;
        sshOpts = [ ];
        nodes = {
          c1 = {
            hostname = "192.168.1.65"; #"10.0.10.2";
            profiles = {
              system = {
                path = deployNixos self.nixosConfigurations.c1;
                user = "root";
              };
            };
          };
          tiferet = {
            hostname = "51.15.83.8";
            profiles = {
              system = {
                path = deployNixos self.nixosConfigurations.tiferet;
                user = "root";
              };
            };
          };
          yuna = {
            hostname = "localhost";
            profiles = {
              system = {
                path = deployNixos self.nixosConfigurations.yuna;
                user = "root";
                ssh-user = "root";
              };
            };
          };
          eris = {
            hostname = "localhost";
            profiles = {
              system = {
                path = deployNixos self.nixosConfigurations.eris;
                user = "root";
                ssh-user = "root";
              };
            };
          };
          fudemonix = {
            hostname = "fudemonix";
            profiles = {
              system = {
                path = deployNixos self.nixosConfigurations.fudemonix;
                user = "root";
                ssh-user = "root";
              };
            };
          };
          cabriolet = {
            hostname = "83.97.20.94";
            profiles = {
              system = {
                path = deployNixos self.nixosConfigurations.cabriolet;
                user = "root";
              };
            };
          };
        };
      };

      devShells = onPkgs (system: pkgs: with pkgs; {
        default = mkShell {
          buildInputs = [
            nixUnstable
            nixpkgs-fmt
            rnix-lsp
            # deploy-rs.defaultPackage.${system}
            wg-bond.defaultPackage.${system}
          ];
        };
      });

      packages = {

        x86_64-linux.vm =
          let
            cfg = import "${nixpkgs}/nixos/lib/eval-config.nix" (buildConfig [
              ./nodes/portables/yuna
              "${nixpkgs}/nixos/modules/virtualisation/build-vm.nix"
              { }
            ]);
          in
          cfg.config.system.build.vm;
      };

    };

}
