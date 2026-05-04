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

    "iwlwifi.amsdu_size=3"

    # "intel_pstate=no_hwp"
    # "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "i915.enable_psr2_sel_fetch=1"
    "i915.enable_psr=2"
    "i915.enable_dc=4"
    "i915.fastboot=1"
    # "i915.enable_gvt=1"
    "mem_sleep_default=s2idle" # faster faster
  ];

  boot.kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;

        "vm.dirty_ratio" = 10;
        "vm.dirty_background_ratio" = 5;
        "vm.dirty_writeback_centisecs" = 6000;
        "vm.dirty_expire_centisecs" = 6000;
        "vm.swappiness" = 5;
    };

}
