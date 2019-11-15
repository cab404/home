{...}: {
  hardware = {
    trackpoint = {
      device = "DELL08B8:00 0488:121F Mouse";
      enable = true;
      emulateWheel = true;
    };
  };
  boot.kernelParams = [
    "i915.alpha_support=1"
    "i915.fastboot=1"
    "i915.enable_fbc=1"
    "i915.enable_psr=1"
  ];
}
