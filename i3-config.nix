{ pkgs, lib, ... }:
{
    xsession.enable = true;
    xsession.pointerCursor = {
      package = pkgs.paper-icon-theme;
      name = "Paper";
      size = 16;
    };
    xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        config = rec {
            modifier = "Mod4";
            modes = {};
            startup = [
              { command = "nitrogen --restore"; notification = false; }
            ];
            window.border = 1;
            keybindings =
            let
                mod = modifier;
                workspaces = with lib; listToAttrs (
                (map (i: nameValuePair "${mod}+${i}" "workspace number ${i}") (map toString (range 0 9))) ++
                (map (i: nameValuePair "${mod}+Shift+${i}" "move container to workspace number ${i}") (map toString (range 0 9)))
                );
            in lib.mkDefault ({

                "${mod}+Tab" = "workspace back_and_forth";
                "${mod}+Shift+q" = "kill";
                "${mod}+Return" = "exec alacritty";
                "${mod}+d" = "exec rofi -matching fuzzy -show drun";
                "${mod}+Ctrl+p" = "exec rofi-pass";
                "${mod}+Escape" = "exec xautolock -locknow";
                "${mod}+Ctrl+Return" = "exec emacsclient -c";
                "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

                "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume 0 +5%";
                "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume 0 -5%";
                "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute 0 toggle";
                "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute 1 toggle";

                # Display key is bound to Win+P in Dell 5400
                "Mod4+p" = "exec arandr";
                #"XF86Display" = "exec arandr";

                # Floating
                "${mod}+space" = "focus mode_toggle";
                "${mod}+Shift+space" = "floating toggle";

                # Gaps
                "${mod}+Shift+plus" = "gaps inner current plus 6";
                "${mod}+Shift+minus" = "gaps inner current minus 6";

                # Tiling modes
                "${mod}+s" = "layout stacking";
                "${mod}+w" = "layout tabbed";
                "${mod}+e" = "layout toggle split";
                "${mod}+v" = "split v";

                # Focus windows
                "${mod}+h" = "focus left";
                "${mod}+j" = "focus down";
                "${mod}+k" = "focus up";
                "${mod}+l" = "focus right";
                "${mod}+u" = "focus parent";
                "${mod}+n" = "focus child";

                # Move windows
                "${mod}+Shift+h" = "move left";
                "${mod}+Shift+j" = "move down";
                "${mod}+Shift+k" = "move up";
                "${mod}+Shift+l" = "move right";

                # Resize windows
                "${mod}+Ctrl+Shift+h" = "resize shrink width 8 px or 8 ppt";
                "${mod}+Ctrl+Shift+j" = "resize grow height 8 px or 8 ppt";
                "${mod}+Ctrl+Shift+k" = "resize shrink height 8 px or 8 ppt";
                "${mod}+Ctrl+Shift+l" = "resize grow width 8 px or 8 ppt";

                # Window states
                "${mod}+f" = "fullscreen toggle";

            } // workspaces);

        };
    };
}

