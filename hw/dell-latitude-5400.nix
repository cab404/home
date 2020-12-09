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

  services.tlp.enable = true;
  services.blueman.enable = true;

  boot.kernelParams = [
    #"amdgpu.runpm=0" # disable power manager
    "amdgpu.gpu_recovery=1" # mowmow, hang in there
    "amdgpu.job_hang_limit=100" # trying to get it not to hang
    # "amdgpu.deep_color=1" # y not?
    "amdgpu.exp_hw_support=1" # mow

    "i915.enable_gvt=1" # virtal graphics
    "i915.error_capture=1" # they dies sometimes

    #"iwlwifi.power_level=5" # ITS OVER 4!
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  powerManagement.enable = true;

  hardware.opengl = with pkgs; {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = [
      rocm-opencl-icd
      intel-compute-runtime
      clblas
      amdvlk
      vulkan-loader
    ];
    extraPackages32 = [
      driversi686Linux.amdvlk
    ];
  };


  # For amdvlk
  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";

  environment.systemPackages = with pkgs; [ clinfo ];

}
