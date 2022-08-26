# Patched version of rofi-pass
# Basically does the same thing, except for wayland and works
# Also uses xkcdpass, cause why not
#
{ config, pkgs, lib, inputs, ... }@args:
with import "${inputs.self}/lib.nix" args;
let
  rofi-pass-wlr = pkgs.stdenv.mkDerivation {
    name = "rofi-pass-wlr";
    doBuild = false;
    doConfigure = false;
    unpackPhase = ":";
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -Dm 755 ${inputs.self}/deps/rofi-pass-wlr $out/bin/rofi-pass-wlr
      runHook postInstall
    '';
    meta = {
      maintainers = [pkgs.lib.maintainers.cab404];
    };
  };
in {

  home = { packages = with pkgs; [ rofi-pass-wlr xkcdpass ]; };

  wayland.windowManager.sway = {
    config = let mod = config.wayland.windowManager.sway.config.modifier;
    in { keybindings = { "${mod}+Ctrl+p" = "exec rofi-pass-wlr"; }; };
  };

}
