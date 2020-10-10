{
  description = "cab's system config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
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
          ./modules/i3/system.nix
          ./modules/home-manager
          ./secret/system.nix
          ./secret/hardware-configuration.nix
          {
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
      buildInputs = [ nixfmt ];
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
