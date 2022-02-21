{
  description = "cab's system config";

  inputs = {
    # dwarffs.url = "github:edolstra/dwarffs";
    # nix.url = "github:NixOS/nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    wg-bond.url = "github:cab404/wg-bond";
    wg-bond.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = inputs @ { self, nixpkgs, home-manager, emacs-overlay, deploy-rs, wg-bond, ... }:
    let
      system = "x86_64-linux";
      patchedPkgs =
        let
          patched = import "${nixpkgs.legacyPackages.${system}.applyPatches {
            name = "nixpkgs-patched";
            src = nixpkgs;
            patches = [ ./0001-wg-file-patch.patch ];
          }}/flake.nix";
          invoked = patched.outputs { self = invoked; };
        in
          invoked;

      inherit (patchedPkgs) lib;
      specialArgs = {
        inherit inputs;
      };
      buildConfig = modules: { inherit modules system specialArgs; };
      buildSystem = modules: lib.nixosSystem (buildConfig modules);
      onPkgs = f: builtins.mapAttrs f patchedPkgs.legacyPackages;
      deployNixos = deploy-rs.lib.${system}.activate.nixos;
    in
    {

      nixosConfigurations =
        {
          # My notebook
          yuna = buildSystem [ ./hw/portables/yuna ];

        } // (builtins.mapAttrs (k: v: buildSystem v) (import ./hw/keter));

      deploy = {

        autoRollback = true;
        magicRollback = true;
        sshOpts = [ ];
        nodes = {
          c1 = {
            hostname = "10.0.10.2";
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
              };
            };
          };
        };
      };

      devShells = onPkgs (system: pkgs: with pkgs; {
        default = mkShell {
          buildInputs = [
            nixfmt
            rnix-lsp
            deploy-rs.defaultPackage.${system}
            wg-bond.defaultPackage.${system}
          ];
        };
      });

      packages = {

        x86_64-linux.vm =
          let
            cfg = import "${nixpkgs}/nixos/lib/eval-config.nix" (buildConfig [
              ./hw/portables/yuna
              "${nixpkgs}/nixos/modules/virtualisation/build-vm.nix"
              { }
            ]);
          in
          cfg.config.system.build.vm;
      };

    };

}
