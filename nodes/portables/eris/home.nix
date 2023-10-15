args@{ sysconfig, config, pkgs # inputs.nixpkgs
, lib # inputs.nixpkgs.lib
, inputs, prelude, ... }:
let __findFile = prelude.__findFile; in {

  imports = [
    <modules/cab/home.nix>
    <modules/home-dumpster.nix>
  ];

  wayland.windowManager.sway.config = {
    input."2362:628:PIXA3854:00_093A:0274_Touchpad" = {
      # dwt = "disabled";
      tap = "enabled";
      pointer_accel = "0.5";
    };
    output."eDP-1" = {
      scale = "1";
    };
  };

}
