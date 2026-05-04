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

    "iwlwifi.amsdu_size=3"

    # --- i915 power saving (Tiger Lake / i5-1145G7) ---
    "i915.enable_fbc=1"            # framebuffer compression – saves memory bandwidth
    "i915.enable_psr=2"            # panel self-refresh level 2 (PSR2) – big display power win
    "i915.enable_psr2_sel_fetch=1" # selective fetch for PSR2 – reduces redrawn area
    "i915.enable_dc=4"             # deepest display C-state (DC5/DC6)
    "i915.fastboot=1"              # skip unnecessary mode-sets on boot
    "i915.enable_guc=3"            # GuC submission (1) + HuC auth (2) – offloads scheduling & enables power features
    "i915.disable_power_well=0"    # let the driver aggressively gate unused power wells
    "i915.enable_dpcd_backlight=1" # DPCD backlight control – more efficient on eDP panels

#    "thunderbolt.power_saving=1"
    "vm.swappiness=5"

    "mem_sleep_default=s2idle" # faster faster
  ];

}
