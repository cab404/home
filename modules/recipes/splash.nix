{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  boot = {

    plymouth = on // {
      theme = "evil-nixos";
      font = "${pkgs.fira-code}/share/fonts/truetype/FiraCode-VF.ttf";
      themePackages = [ (pkgs.callPackage inputs.plymouth-is-underrated.outPath {}) ];
    };

    kernelParams = [
      "quiet"
      "splash"
    ];

  };

}
