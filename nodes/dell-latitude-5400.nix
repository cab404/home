{ pkgs, lib, ... }: {
  # Trackpoint scroll fix. Injection!
#  services.xserver.libinput.touchpad.additionalOptions = ''
#EndSection
#Section "InputClass"
#  Identifier "libinput pointer catchall"
#  MatchIsPointer "on"
#  MatchDevicePath "/dev/input/event*"
#  Driver "libinput"
#  Option "ScrollMethod" "button"
#  Option "ScrollButton" "2"
#  '';

  services.tlp.enable = true;
  services.blueman.enable = true;

  boot.kernelParams = [
    #"amdgpu.runpm=0" # disable power manager
    #"amdgpu.gpu_recovery=1" # mowmow, hang in there
    #"amdgpu.job_hang_limit=100" # trying to get it not to hang
    #"amdgpu.deep_color=1" # y not?
    #"amdgpu.exp_hw_support=1" # mow

    "i915.enable_gvt=1" # virtual graphics
    "i915.enable_guc=3" # something something offload to gpu
    # "i915.error_capture=1" # they die sometimes

    "intel_pstate=no_hwp"

    #"iwlwifi.power_level=5" # ITS OVER 4!
  ];
#  boot.blacklistedKernelModules = [ "amdgpu" ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  powerManagement.enable = true;

  hardware.opengl = with pkgs; {
    enable = true;
    driSupport = true;
    extraPackages = [
      amdvlk
      vulkan-loader
      intel-compute-runtime
    ];
    extraPackages32 = [
      driversi686Linux.amdvlk
    ];
  };


  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  # For amdvlk
  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json";

  environment.systemPackages = with pkgs; [ clinfo ];

}
