_: {

  imports = [
    ./hw/dell-latitude-5400.nix
    ./core.nix
    ./desktop.nix
    ./secret/system.nix
    # ./home-manager.nix
  ];

  hardware.opengl = let
    opencl_pr = import (builtins.fetchTarball {
      name = "opencl_pr";
      url = "https://github.com/athas/nixpkgs/archive/f92a2a9b69eba9909d25ffaab6ded4d6f0f4efad.tar.gz";
    }) { };
  in {
    enable = true;
    driSupport32Bit = true;
    package = opencl_pr.mesa.drivers;
    extraPackages = [ opencl_pr.mesa ];
  };
}
