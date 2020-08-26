{ pkgs, ... }: {
  # Trackpoint scroll fix. Injection!
  services.xserver.libinput.additionalOptions = ''
EndSection
Section "InputClass"
  Identifier "libinput pointer catchall"
  MatchIsPointer "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
  Option "ScrollMethod" "button"
  Option "ScrollButton" "2"
  '';

  boot.kernelParams = [
    #"amdgpu.runpm=0" # disable power manager
    "amdgpu.gpu_recovery=1" # mowmow, hang in there
    "amdgpu.job_hang_limit=100" # trying to get it not to hang
    "amdgpu.deep_color=1" # y not?
    "amdgpu.exp_hw_support=1" # mow

    "i915.enable_gvt=1" # virtal graphics
    "i915.error_capture=1" # they dies sometimes

    #"iwlwifi.power_level=5" # ITS OVER 4!
  ];


  # OpenCL from [this](https://github.com/NixOS/nixpkgs/pull/82729) PR
  hardware.opengl = let
    # opencl_pr = import (builtins.fetchTarball {
    #   name = "opencl_pr";
    #   url = "https://github.com/athas/nixpkgs/archive/f92a2a9b69eba9909d25ffaab6ded4d6f0f4efad.tar.gz";
    #   sha256 = "1yf3w0k5iqslimnir5zznjn8rpzq9nb51nrab75kklklsmrnlx8h";
    # }) { inherit currentSystem };
  in {
    enable = true;
    driSupport32Bit = true;
    # package = opencl_pr.mesa.drivers;
    extraPackages = with pkgs; [
      beignet
      # opencl_pr.mesa
      clblas
    ];
  };

}
