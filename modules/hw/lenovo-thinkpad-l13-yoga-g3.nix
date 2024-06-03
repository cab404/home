{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    inputs.nixos-hw.nixosModules.lenovo-thinkpad-l13-yoga
  ];
  
  hardware.sensor.iio.enable = true;
  services.fprintd = on;
  services.acpid.enable = true;

boot.kernelParams = [
    "quiet"
    "splash"
    
    "mitigations=off"

    "i915.enable_fbc=1"
    "i915.enable_psr=2"
    "i915.fastboot=1"
    "i915.enable_gvt=1"
    "mem_sleep_default=s2idle" # faster faster
  ];

}
