{ config, pkgs, lib, ... }@args:
with import ../../lib.nix args; {

  # In a swaаааy bar swаааay bar sway bar!

  # needs ./system.nix in system configuration

  home = {

    pointerCursor = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita";
      size = 16;
    };

    packages = with pkgs; [
      flameshot
      wl-clipboard
      rofi-wayland
      swaycwd
      wlrctl

#      mate.mate-polkit
#      swayidle
#      kdeconnect
#      kwalletmanager
#      plasma-browser-integration

      # For waybar
      pavucontrol
      copyq

      qt5.qtwayland
      libsForQt5.qtstyleplugins
      xdg-utils
      swaylock-effects
    ];

    file = {
      ".bg.png".source = ../../bg.png;
      ".config/waybar".source = ./waybar;
    };

  };

  systemd.user.sessionVariables = config.home.sessionVariables;

  home.sessionVariables = {
    # for some reason it doesn't want to read anything else
    SDL_VIDEODRIVER = "wayland";

    # self-descriptive
    MOZ_ENABLE_WAYLAND = "1";

    # actually I'm sure it's set somewhere else too
    DESKTOP_SESSION = "sway";
    GTK_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "sway";
    # woo wrappers
    NIXOS_OZONE_WL = "1";

    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Fixing java apps (especially idea)
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # Some wlr variables, https://gitlab.freedesktop.org/wlroots/wlroots/-/blob/master/docs/env_vars.md
    # WLR_DRM_NO_MODIFIERS = "1";
    #
  };

  programs.waybar = on;
  programs.alacritty = on;

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

  services.swayidle =
    let
      swaylock = pkgs.swaylock-effects;
      lock = ''
        ${swaylock}/bin/swaylock \
          --clock \
          -i ~/.bg.png \
          --indicator \
          -fFLke \
          --effect-blur 6x6 \
          --effect-vignette 0.1:0.5
      '';
      #lock = "swaylock -i ~/.bg.png -s fill -F";
    in
    on // {
      timeouts = [
        { timeout = 60; command = lock; }
        # dpms kills everyone and everything I love
        # let's try it again!
        # 2022-04-30 it still slaughters
        (
          let
            lights-off = pkgs.writeShellScript "lights-off" ''
              light -O
              light -S 0
            '';
            lights-on = pkgs.writeShellScript "lights-on" ''
              light -I
            '';
          in
          { timeout = 30; command = toString lights-off; resumeCommand = toString lights-on; }
        )
      ];
      events = [
        { event = "lock"; command = lock; }
        { event = "before-sleep"; command = lock; }
      ];
    };

  wayland.windowManager.sway = on // {
    wrapperFeatures.gtk = true;
    extraConfig = ''
        bindsym --locked --to-code ISO_Level3_Shift input * xkb_switch_layout 0
        # bindsym --locked --to-code --release Mod4   input * xkb_switch_layout 0
    '';
    config = rec {

      modifier = "Mod4";

      bars = [
        {
          statusCommand = "${pkgs.i3status}/bin/i3status";
          trayOutput = "*";
        }
      ];
      modes = { };
      terminal = "alacritty";
      output = {
        "*" = {
          #bg = "~/.bg.png tile";
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
          # scroll_method = "on_button_down";
          natural_scroll = "enable";
          # I am good at not touching the thing.
          # Also, it interferes with me working in blender ;D
          dwt = "disable";
          # middle_emulation = "enabled";
          xkb_layout = config.home.keyboard.layout;
          xkb_options = pkgs.lib.concatStringsSep "," config.home.keyboard.options;
        };

        # let's make this clit useful
        "1160:4639:DELL08B8:00_0488:121F_Mouse" = {
          accel_profile = "flat";
          pointer_accel = "1";
        };

      };

      startup =
        [
          #{ command = "waybar"; }
          { command = "mako"; }
          { command = "telegram-desktop"; }
          { command = "element-desktop --hidden"; }
          { command = "nextcloud"; }
          { command = "flameshot"; }
          # hacky, yes. doesn't work otherwise -- also yes.
          { command = "copyq"; }


        ];

      window = {
        commands = [
          { criteria = { window_role = "pop-up"; }; command = "no_focus"; }
          { criteria = { window_type = "notification"; }; command = "no_focus"; }

          # Jitsi Window
          { criteria = { instance = "jitsi meet"; }; command = "floating enable"; }
          { criteria = { instance = "jitsi meet"; }; command = "no_focus"; }
          { criteria = { instance = "jitsi meet"; }; command = "resize set 0 0"; }
          { criteria = { instance = "jitsi meet"; }; command = "move absolute position 10 10"; }

          # Firefox video indicator
          { criteria = { title = "Firefox — Sharing Indicator"; }; command = "floating enable"; }
          { criteria = { title = "Firefox — Sharing Indicator"; }; command = "no_focus"; }
          { criteria = { title = "Firefox — Sharing Indicator"; }; command = "resize set 0 0"; }
          { criteria = { title = "Firefox — Sharing Indicator"; }; command = "move absolute position 10 10"; }

          # I freaking love this thing
          { criteria = { title = ".*CopyQ"; }; command = "floating enable"; }
          { criteria = { title = ".*CopyQ"; }; command = "move position mouse"; }

          { criteria = { app_id = "com.nextcloud.desktopclient.nextcloud"; }; command = "floating enable"; }
          { criteria = { app_id = "com.nextcloud.desktopclient.nextcloud"; }; command = "move position mouse"; }
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
        xcursor_theme = "Adwaita 16";
      };

      bindkeysToCode = true;
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
          conf = builtins.toFile "woficonf" ''
            dynamic_lines=true
            insensitive=true
            layer=overlay
          '';
          # This works a lot more reliably, at cost of not providing any options of saving
          flameshotWlCopy = pkgs.writeScript "sfwlcp" ''
            flameshot gui -c -r  | wl-copy
          '';
        in
        lib.mkDefault ({
          "${mod}+Tab" = "workspace back_and_forth";
          "${mod}+Shift+Tab" = "move container to workspace back_and_forth";
          "${mod}+Shift+q" = "kill";
          "${mod}+Return" = "exec alacritty --working-directory \"$(swaycwd)\"";
          "${mod}+d" = "exec rofi -show run";
          "${mod}+c" = "exec copyq show";
          "${mod}+Ctrl+p" = "exec wofi-pass";
          "${mod}+Ctrl+Return" = "exec emacsclient -c";
          "${mod}+Shift+Return" = "exec codium";
          "${mod}+Shift+e" = "exec swaynag -t warning -m 'Do you want to exit sway?' -b 'Yes' 'swaymsg exit'";
          "${mod}+Escape" = "exec loginctl lock-session";

          "XF86AudioLowerVolume" = "exec --no-startup-id amixer -D pipewire sset Master 5%-";
          "XF86AudioMicMute" = "exec --no-startup-id amixer -D pipewire sset Capture toggle";
          "XF86AudioMute" = "exec --no-startup-id amixer -D pipewire sset Master toggle";
          "XF86AudioRaiseVolume" = "exec --no-startup-id amixer -D pipewire sset Master 5%+";

          "Print" = "exec ${flameshotWlCopy}";

          # Display key is bound to Win+P in Dell 5400
          # "Mod4+p" = "exec arandr";
          #"XF86Display" = "exec arandr";

          # Floating
          # "${mod}+space" = "focus mode_toggle"; # yup it clashes with my layout changer
          "${mod}+Shift+space" = "floating toggle";

          # Gaps
          "${mod}+plus" = "gaps inner current plus 6";
          "${mod}+underscore" = "gaps inner current minus 6";

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
      gtk-cursor-theme-name=Adwaita
      gtk-menu-images=1
      gtk-button-images=1
    '';
    theme.package = pkgs.gnome-themes-extra;
    theme.name = "Adwaita-dark";
  };

  qt = on // {
    platformTheme = "gtk";
    style.name = "gtk2";
    # platformTheme = "gnome";
    # style.package = pkgs.adwaita-qt;
    # style.name = "adwaita";
  };

}
