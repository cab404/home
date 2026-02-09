{
  description = "cab's system config";
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://helix.cachix.org"
      "https://nix-community.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {

    # helix.url = "github:helix-editor/helix";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    snm.url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
    snm.inputs.nixpkgs.follows = "nixpkgs";
    # emacs-overlay.url = "github:nix-community/emacs-overlay";
    # emacs-overlay.follows = "nix-doom-emacs/emacs-overlay";

    # deploy-rs.url = "github:serokell/deploy-rs";
    # deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hw.url = "github:nixos/nixos-hardware";

    wg-bond.url = "github:cab404/wg-bond";
    wg-bond.inputs.nixpkgs.follows = "nixpkgs";

    # nix-doom-emacs.url = "github:thiagokokada/nix-doom-emacs";
    # nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";

    # gtch.url = "/home/cab/data/cab/ticket-checker";
    # gtch.inputs.nixpkgs.follows = "nixpkgs";
    plymouth-is-underrated.url = "github:cab404/plymouth-is-underrated";
    # plymouth-is-underrated.url = "/home/cab/data/cab/plymouth-is-underrated";
    plymouth-is-underrated.flake = false;

    swaycwd.url = "sourcehut:~cab/swaycwd";

  };

  outputs =
    inputs @ { self
    , nixpkgs
    , home-manager
    , wg-bond
    , ...
    }:
    let
      system = "x86_64-linux";
      patchedPkgs =
        let
          patches = [
            # ./patches/soft-reboot.patch
            # Place your nixpkgs patches here
            # ./patches/v4.patch # Scary one with x86-64-v4 and a _full_ system rebuild
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
        inherit inputs prelude; inherit (inputs) nixos-raspberrypi;
      };

      buildSystem = mode: system: modules: {
          # Mode list. You can add your custom pkgs and stuff here
          default = lib.nixosSystem;
          rpi = inputs.nixos-raspberrypi.lib.nixosSystem;
        }.${mode} { inherit modules system specialArgs; };

      hostAttrs = dir: {
        settings = import "${dir}/host-metadata.nix";
        config = import "${dir}/configuration.nix";
        hw-config = import "${dir}/hardware-configuration.nix";
      };

      node = dir: with hostAttrs dir; buildSystem (settings.mode or "default") settings.system [
        config
        hw-config
      ];

      virt-node = dir: with hostAttrs dir; buildSystem "default" settings.system [
        config
        "${nixpkgs}/nixos/modules/virtualisation/build-vm.nix"
      ];

      onPkgs = f: builtins.mapAttrs f patchedPkgs.legacyPackages;

      nodes = {
        # My notebook
        yuna = ./nodes/yuna;

        # My new notebook
        eris = ./nodes/eris;

        # My temporary machine (jews stole my laptop)
        baba = ./nodes/baba;

        # First server
        c1 = ./nodes/c1;

        # Scaleway proxy
        tiferet = ./nodes/tiferet;

        # My printer
        fudemonix = ./nodes/fudemonix;

        # the other server
        twob = ./nodes/twob;

        # rpi
        bakapie = ./nodes/bakapie;
      };

    in
    {

      nixosConfigurations =
        (builtins.mapAttrs (_: node) nodes) //
        {

          # Yup, installer
          installer = buildSystem "default" "x86_64-linux" [
            (nixpkgs + (toString /nixos/modules/installer/cd-dvd/installation-cd-base.nix))
            ./modules/home-manager
            # ./modules/sway/system.nix
            ./modules/core.nix
            ({ config, lib, pkgs, ... }: {
              _.user = "nixos";
              networking.networkmanager.enable = true;

              boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
              networking.wireless.enable = false;
              environment.systemPackages = [
                config.boot.kernelPackages.chipsec
              ];
              boot.extraModulePackages = with config.boot.kernelPackages; [
                chipsec
              ];
              home-manager.users.${config._.user}.imports = [
                # ./modules/sway/core.nix
              ];
            })
          ];

        }; #// (builtins.mapAttrs (k: v: buildSystem v) (import ./nodes/keter));

      devShells = onPkgs (system: pkgs: with pkgs; {
        default = mkShell {
          buildInputs = [
            nixVersions.latest
            nixpkgs-fmt
            nil
            nix-output-monitor
            nushell

          ];
        };
      });

      packages = {
        x86_64-linux.vm = (virt-node ./nodes/portables/eris).config.system.build.vm;
      };

      nodeMeta = builtins.mapAttrs (_: h: (hostAttrs h)) nodes;
    };

}
