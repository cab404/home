{ config, pkgs, lib, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in {
  # needs ./system.nix in system configuration
  imports = [ ./core.nix ./pass.nix ];
  home = {
    packages = with pkgs; [ pavucontrol ];
  };

  services.gammastep = on // {
    latitude = "40.183333";
    longitude = "44.516667";
    tray = true;
  };

  wayland.windowManager.sway = on // {
    extraConfig = with pkgs; ''
      bindsym --locked --to-code ISO_Level3_Shift input * xkb_switch_layout 0
      # bindsym --locked --to-code --release Mod4   input * xkb_switch_layout 0

      # Mumble PTT keybindings
      bindsym --to-code --no-repeat           Control_R exec ${qt5.qttools.bin}/bin/qdbus --session net.sourceforge.mumble.mumble / startTalking
      bindsym --to-code --no-repeat --release Control_R exec ${qt5.qttools.bin}/bin/qdbus --session net.sourceforge.mumble.mumble / stopTalking
    '';
    config = rec {
      startup =
        [ 
        #{ command = "telegram-desktop"; } 
        #{ command = "nextcloud"; } 
        ];
    };
  };

}
