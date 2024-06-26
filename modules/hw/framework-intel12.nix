{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    inputs.nixos-hw.nixosModules.framework-12th-gen-intel
  ];

    boot.kernelParams = [
    "quiet"
    "splash"
    "mitigations=off"
    # "intel_pstate=no_hwp"
    # "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "iwlwifi.amsdu_size=3"
    "enable_psr2_sel_fetch=1"
    "i915.enable_psr=2"
    "i915.fastboot=1"
    "i915.enable_gvt=1"
    "mem_sleep_default=s2idle" # faster faster
  ];

}
