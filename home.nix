{ config, pkgs, lib, lists, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") { };
in
{
 
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  home.packages = with pkgs; [
    # Interweebs
    firefox tdesktop

    # Coding stuff
    vscodium
    
    # Window manager and looks stuff
    arandr rofi xsecurelock 
    redshift compton xautolock
    source-code-pro noto-fonts

    # Utilities
    st zsh zathura
    pulsemixer
    
    # Personal data and sync
    pass browserpass 
    gnupg nextcloud-client
  ];

  # == GPG
  services.gpg-agent = {
    enable = true;
  };

  # == SSH
  programs.ssh = {
    
    matchBlocks = {
      "cab404.ru" = {
        user = "cab";
        identityFile = "~/.ssh/id_rsa";
      };
    };

    compression = true;
    enable = true;
  };

  dconf.enable = true;

  # == Git
  programs.git = {
    enable = true;
    userName = "Vladimir Serov";
    userEmail = "me@cab404.ru";
    signing.key = "1BB96810926F4E715DEF567E6BA7C26C3FDF7BB3";
  };

  # == Pass and stuff
  programs.browserpass = {
    enable = true;
    browsers = [ "firefox" ];
  };

  # == Nextcloud
  services.nextcloud-client.enable = true;

  # == Gnome keyring (Nextcloud uses it)
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # == Rofi menu
  programs.rofi = {
    enable = true;
    theme = "sidebar";
  };

  # == Redshift
  services.redshift = {
    enable = true;
    tray = true;
    provider = "manual";
    latitude = "55";
    longitude = "34";
  };

  # == Oh My Zsh!
  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "nix" ];
      theme = "ys";
    };
  };
  
  # == Keyboard config 
  home.keyboard = {
    layout = "us,ru";
    options = [ "ctrl:nocaps" "grp:switch" "compose:prsc" ];
  }; 

  # == Compton window compositor
  services.compton = {
    enable = true;
    blur = true;
    fade = true;
    fadeDelta = 5;
    inactiveOpacity = "0.8";
  };

  # == Screen lock

  services.screen-locker = {
    enable = true;
    lockCmd = "xsecurelock";
    xautolockExtraOptions = [
      "-lockaftersleep"
      "-detectsleep"
    ];
  };

  # == Gtk and Qt
  gtk = {
    enable = true;
    iconTheme.package = pkgs.paper-icon-theme;
    iconTheme.name = "Paper";
    theme.package = pkgs.adapta-gtk-theme;
    theme.name = "Adapta-Nokto-Eta";
  };
  qt = { enable = true; platformTheme = "gtk"; };

  # == Mostly i3 config
  xsession = {
    enable = true;
    
    windowManager = {
      
      i3.enable = true;
      i3.package = pkgs.i3-gaps;
      i3.config =
      rec {
        modifier = "Mod4";
        modes = {};

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
          "${mod}+Return" = "exec st";
          "${mod}+d" = "exec rofi -show drun";
          "${mod}+Escape" = "exec xautolock -locknow";
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
  };

}
