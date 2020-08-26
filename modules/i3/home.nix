{ pkgs, lib, ... }:
with import ../../lib.nix { inherit pkgs; }; {

  home.packages = with pkgs; [
    nitrogen arandr
    redshift redshift-plasma-applet
    plasma-desktop
  ];

  home.file = {
      ".bg.png".source = ../../bg.png;
  };

  services = enableThings [
    "flameshot"
    "picom"
  ] {

    # == Compositor
    picom = {
      blur = true;
      fade = true;
      shadow = true;
      vSync = true;
      fadeDelta = 5;
      inactiveOpacity = "0.96";
    };

  };

  # == That fixes qtkeychain
  home.sessionVariables = {
    DESKTOP_SESSION = "kde";
    KDE_SESSION_VERSION = "5";
  };

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
      bars = [];
      modifier = "Mod4";
      modes = {};
      terminal = "alacritty";
      startup = [
        { command = "nitrogen --restore"; notification = false; }
        { command = "startplasma-x11"; notification = false; }
      ];
      window = {
        border = 1;
        hideEdgeBorders = "both";
        commands = [
          { criteria = { class = "plasmashell"; }; command = "floating enable"; }
          { criteria = { title = "Desktop — Plasma"; }; command = "kill, floating enable, border none"; }
        ];
      };
      focus = {
        newWindow = "focus";
      };
      colors = {
        focused = {
          border = "#4cff99";
          background = "#285577";
          childBorder = "#28aa77";
          indicator = "#2e9ef4";
          text = "#ffffff";
        };
      };
      keybindings =
        let
          mod = modifier;
          intMod = a: b: a - (a / b) * b;
          numkey = i: toString (intMod i 10);
          workspaceList = (lib.range 1 10);
          workspaces = with lib;
            listToAttrs (
              (map (i: nameValuePair "${mod}+${numkey i}" "workspace number ${toString i}") workspaceList) ++
              (map (i: nameValuePair "${mod}+Shift+${numkey i}" "move container to workspace number ${toString i}") workspaceList)
            );
        in lib.mkDefault ({

          "${mod}+Tab" = "workspace back_and_forth";
          "${mod}+Shift+q" = "kill";
          "${mod}+Return" = "exec DRI_PRIME=1 alacritty";
          "${mod}+d" = "exec rofi -matching fuzzy -show drun";
          "${mod}+Ctrl+p" = "exec rofi-pass";
          "${mod}+Ctrl+Return" = "exec emacsclient -c";
          "${mod}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
          "Print" = "exec flameshot gui";

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
          "${mod}+Ctrl+Shift+j" = "resize shrink height 8 px or 8 ppt";
          "${mod}+Ctrl+Shift+k" = "resize grow height 8 px or 8 ppt";
          "${mod}+Ctrl+Shift+l" = "resize grow width 8 px or 8 ppt";

          # Window states
          "${mod}+f" = "fullscreen toggle";

        } // workspaces);

    };

    extraConfig = ''
    # For unfocusing notifications
    no_focus [class="plasmashell" window_type="notification"]
    no_focus [class="plasmashell" window_type="on_screen_display"]
    '';

  };
}

