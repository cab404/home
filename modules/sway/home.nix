{ config, pkgs, lib, ... }@args:
with import ../../lib.nix args; {

  # In a swaаааy bar swаааay bar sway bar!

  # needs ./system.nix in system configuration

  home = {

    packages = with pkgs; [
      swayidle
      flameshot
      wl-clipboard
      swaycwd

      kdeconnect kwalletmanager
      plasma-browser-integration

      # For waybar
      pavucontrol copyq

      qt5.qtwayland libsForQt5.qtstyleplugins
      swaylock xdg-utils
    ];

    file = {
      ".bg.png".source = ../../bg.png;
      ".config/waybar".source = ./waybar;
    };

  };

  systemd.user.sessionVariables = config.home.sessionVariables;

  home.sessionVariables = {
    DESKTOP_SESSION = "sway";
    SDL_VIDEODRIVER = "wayland";
    # QT_QPA_PLATFORM = "wayland";
    GTK_BACKEND = "wayland";
    # self-descriptive
    MOZ_ENABLE_WAYLAND = "1";
    # ..?
    WLR_DRM_NO_MODIFIERS = "1";

    # Fixing java apps (especially idea)
    _JAVA_AWT_WM_NONREPARENTING = "1";
    #
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "sway";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  services.kanshi = on;
  programs.waybar = on;

  services.gammastep = on // {
    latitude = "55.75222";
    longitude = "37.61556";
    tray = true;
  };

  programs.mako = on // {
    borderSize = 0;
    borderRadius = 5;
    backgroundColor = "#125522aa";
    font = "Noto Sans 10";
    # alllright, need sum recursive config definitions for that one
    extraConfig = ''
      [mode=do-not-disturb]
      invisible=1

      [urgency=critical]
      invisible=0
      background-color=#552222cc
      font=Orbitron 16
      width=500
      icon-location=top
      anchor=top-center
      layer=overlay
      border-color=#aa0000
      border-size=1
    '';
  };

  wayland.windowManager.sway = on // {

    wrapperFeatures.gtk = true;

    config = rec {

      modifier = "Mod4";

      bars = [ ];
      modes = { };
      terminal = "alacritty";
      output = {
        "*" = {
          bg = "~/.bg.png tile";
        };
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

      input = {
        "*" = {
          scroll_method = "on_button_down";
          natural_scroll = "enabled";
          middle_emulation = "enabled";
          xkb_layout = "us,ru";
          xkb_options = "ctrl:nocaps,grp:switch";
        };
      };

      startup =
        let
          lock = "swaylock -i ~/.bg.png -s fill -F";
        in
        [
          { command = "mako"; }
          { command = "waybar"; }
          { command = "flameshot"; }
          { command = "copyq"; }
          { command = "telegram-desktop"; }
          { command = "element-desktop --hidden"; }
          {
            command = ''swayidle \
              lock           '${lock}' \
              timeout     60 '${lock}' \
              timeout     30 'swaymsg "output * dpms off"' \
		                  resume 'swaymsg "output * dpms on"' \
	            before-sleep   '${lock}'
          '';
          }
        ];

      window = {
        commands = [
          { criteria = { window_role = "pop-up"; }; command = "no_focus" ; }
          { criteria = { window_type = "notification"; }; command = "no_focus"; }

          # Firefox video indicator
          { criteria = { title = "Firefox — Sharing Indicator"; }; command = "floating enable"; }
          { criteria = { title = "Firefox — Sharing Indicator"; }; command = "no_focus"; }
        ];

        hideEdgeBorders = "none";
        border = 1;
      };

      floating = {
        border = 1;
      };

      focus = {
        newWindow = "smart";
      };

      seat."*" = {
        xcursor_theme = "Paper 24";
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
        in
        lib.mkDefault ({
          "${mod}+Tab" = "workspace back_and_forth";
          "${mod}+Shift+Tab" = "move container to workspace back_and_forth";
          "${mod}+Shift+q" = "kill";
          "${mod}+Return" = "exec DRI_PRIME=1 alacritty --working-directory $(swaycwd)";
          "${mod}+d" = "exec rofi -show combi";
          "${mod}+Ctrl+p" = "exec rofi-pass";
          "${mod}+Ctrl+Return" = "exec emacsclient -c";
          "${mod}+Shift+e" = "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";
          "${mod}+Escape" = "exec loginctl lock-session";

          "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume 0 -5%";
          "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute 1 toggle";
          "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute 0 toggle";
          "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume 0 +5%";

          "Print" = "exec flameshot gui";

          # Display key is bound to Win+P in Dell 5400
          # "Mod4+p" = "exec arandr";
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

  };

  xsession.pointerCursor.package = pkgs.paper-icon-theme;
  xsession.pointerCursor.name = "Paper";
  fonts.fontconfig = on;

  systemd.user.targets = {
    # Copied from <home-manager/modules/xsession.nix>
    tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };

  };

  gtk = on // {
    iconTheme.package = pkgs.gnome3.adwaita-icon-theme;
    iconTheme.name = "Adwaita";

    font.name = "Noto Sans";
    font.size = 10;

    gtk2.extraConfig = ''
      gtk-enable-animations=1
      gtk-primary-button-warps-slider=0
      gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
      gtk-cursor-theme-name=Paper
      gtk-menu-images=1
      gtk-button-images=1
    '';
    theme.package = pkgs.adapta-gtk-theme;
    theme.name = "Adapta-Nokto-Eta";
  };

  qt = on // {
    platformTheme = "gtk";
    style.name = "gtk2";
  };

}
