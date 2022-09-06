{ config, lib, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    devices = {
      snailoftomorrow.id = "577E5I3-K7YDNAU-3BMDYKD-ASE2WAB-ZBBESU2-YGKP5V5-S5W4TGZ-RGHYBQL";
      snailoftomorrow_win.id = "EMYQZRC-FBCW7P2-MZNNK4H-TFQB43O-X5O6RN2-BE7SXEU-VGWGZF2-VRC77QS";
      cake64.id = "3SS3VYV-TA3MERZ-55ZDKB4-XB7CYZG-2SKBATX-LFDXSZB-SHNLQEX-DLMTBQA";
      kagisama.id = "A75AWU3-76RYUXS-PMG6PAV-J2V2COP-DX64SKF-KY5YBO5-LB7N2BR-OKVBHAN";
    };

    folders = {
      "/var/lib/klipper-files" = {
        id = "anette-files";
        devices = with builtins; attrNames (config.services.syncthing.devices);
      };
    };
  };

}
