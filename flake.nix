{
  description = "cab's system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
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
          ./hw/dell-latitude-5400.nix
          ./modules/sway/system.nix
          ./modules/home-manager
          ./secret/system.nix
          ./secret/hardware-configuration.nix
          {
            systemd.coredump.enable = true;
            boot.tmpOnTmpfs = true;
            system.name = "yuna";
            networking.hostName = "yuna";
            _.user = "cab";
            time.timeZone = "Europe/Moscow";
            nixpkgs.overlays = [
              (self: sup: {
                rofi-pass = sup.rofi-pass.overrideAttrs (s: {
                  # latest in the field!
                  src = self.fetchFromGitHub { repo = "rofi-pass"; owner = "carnager"; rev = "916ac3bf5f50d0140a9839f523621c5d77bccf0e"; hash = "sha256-TFPhUt4vvm4Uhp3wys5ZoVoxdbGHdpfnV34CKADiG8Y="; };
                });
              })
              inputs.neovim-nightly.overlay
            ];

            i18n.defaultLocale = "en_US.UTF-8";
          }
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
