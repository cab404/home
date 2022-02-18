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

    # neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    # neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, emacs-overlay, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      buildConfig = modules: { inherit modules system specialArgs; };
      buildSystem = modules: lib.nixosSystem (buildConfig modules);
    in
    {

    nixosConfigurations =
      {
        # My notebook
        yuna = buildSystem [
          # inputs.dwarffs.nixosModules.dwarffs
          ./hw/dell-latitude-5400.nix
          ./modules/sway/system.nix
          ./modules/home-manager
          ./secret/system.nix
          ./secret/hardware-configuration.nix
          ./secret/serokell.nix
          ({ config, pkgs, ... }: {
            boot.tmpOnTmpfs = true;
            boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

            system.name = "yuna";
            networking.hostName = "yuna";

            # systemd.coredump.enable = true;

            # Young streamer's kit (don't mistake with adolescent kit, that would be tiktok)
            programs.gphoto2.enable = true;
            users.users.cab.extraGroups = [ "camera" ];
            boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

            # I guess if I have dwarffs in this system, might as well.
            # environment.defaultPackages = [ pkgs.gdb ];

            services.pcscd.enable = true;

            _.user = "cab";

            nix.registry = let
              lock = (with builtins; fromJSON (readFile ./flake.lock));
            in {
              nixpkgs = with lock.nodes.nixpkgs; {
                from = { id = "nixpkgs"; type = "indirect"; };
                to = locked;
              };
            };

            nixpkgs.overlays = [
              # inputs.nix.overlay
              # inputs.neovim-nightly.overlay
              # inputs.emacs-overlay.overlay
            ];

            i18n.defaultLocale = "en_US.UTF-8";
          })
        ];

        tifa = buildSystem [
          ./hw/acer-es1-111.nix
          ./modules/i3/system.nix
          ./modules/home-manager
          ./secret/system.nix
          ./secret/hardware-configuration.nix
          {
            systemd.coredump.enable = true;
            system.name = "tifa";
            networking.hostName = "tifa";
            _.user = "cab";
            time.timeZone = "Europe/Moscow";
            i18n.defaultLocale = "en_US.UTF-8";
          }
        ];

        container = buildSystem [
          ./modules
          ./modules/kde/system.nix
          {
            boot.isContainer = true;
            _.user = "cab";
            time.timeZone = "Europe/Berlin";
            i18n.defaultLocale = "en_US.UTF-8";
            users.users.root.password = "foobar";
          }
        ];

      };

    devShell.x86_64-linux = with (import nixpkgs { system = "x86_64-linux"; }); mkShell {
      buildInputs = [ nixfmt rnix-lsp ];
    };

    packages = {

      vm.x86_64-linux =
        let
          cfg = import "${nixpkgs}/nixos/lib/eval-config.nix" (buildConfig [
              ./modules
              ./modules/kde/system.nix
              "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
              {
                boot.isContainer = true;
                _.user = "cab";
                time.timeZone = "Europe/Berlin";
                i18n.defaultLocale = "en_US.UTF-8";
                users.users.root.password = "foobar";
              }
            ]);
        in
          cfg.config.system.build.vm;
    };

  };

}
