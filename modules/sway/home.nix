{ pkgs, lib, ... }: {

  # In a sway bar sway bar sway bar!

  # needs ./system.nix in system configuration

  home = {

    packages = with pkgs; [
      swayidle waybar
      grim slurp   # screenshots
      kanshi       # autoconfigures screen outputs?
      wl-clipboard

      (pkgs.writeScriptBin "wl-shot" ''
      ${pkgs.grim}/bin/grim -g "$(${slurp}/bin/slurp)" - | wl-copy --type image/png
      '')

      (callPackage "${builtins.fetchGit {
        url = "https://git.sr.ht/~cab/swaycwd";
        rev = "aeb4ddcdd095b70f8cb2d350c84fb6647b917503";
      }}/swaycwd.nix" { enableShells = [ "zsh" "bash" ]; })

      # For waybar
      pavucontrol libappindicator mako

      (writeShellScriptBin "startsway" ''
          systemctl --user import-environment
          exec systemctl --user start sway.service
          '')

    ];

    file = {
      ".bg.png".source = ../../bg.png;
      ".config/kanshi/config".text = "";
      ".config/sway/config" = {
	      source = ./config;
  	    onChange = "sway reload";
      };
      ".config/waybar".source = ./waybar;
    };
  };

  systemd.user = {

    targets.graphical-session = {
      unit = {
        description = "sway compositor session";
        documentation = [ "man:systemd.special(7)" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };
    };

    targets.sway-session = {
      unit = {
        description = "sway compositor session";
        documentation = [ "man:systemd.special(7)" ];
        bindsto = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };
    };

    services.sway = {
      Unit = {
        Description = "Sway - Wayland window manager";
        Documentation = [ "man:sway(5)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
      # We explicitly unset PATH here, as we want it to be set by
      Service = {
        Type = "simple";
        ExecStart = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
      '';
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    services.kanshi = {
      Unit = {
        Description = "Kanshi output autoconfig ";
        WantedBy = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        # kanshi doesn't have an option to specifiy config file yet, so it looks
        # at .config/kanshi/config
        ExecStart = ''
        ${pkgs.kanshi}/bin/kanshi
      '';
        RestartSec = 5;
        Restart = "always";
      };
    };

  };

}
