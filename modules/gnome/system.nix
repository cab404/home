{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in# %%MODULE_HEADER%%
{


  home-manager.users.${config._.user}.imports = [
    ./home.nix
  ];

  imports = [
    ../graphical.nix
  ];

  qt = on // {
    platformTheme = "gnome";
  };

  services.xserver.desktopManager.gnome = on // {
    sessionPath = with pkgs.gnomeExtensions; [
      pano
      caffeine
      gsconnect
      tailscale-status
      # vertical-overview # not compatible with 44

      # (paperwm.overrideAttrs (s: s // {
      #   src = pkgs.fetchFromGitHub {
      #     owner = "paperwm";
      #     repo = "PaperWM";
      #     rev = "477d546e5a78280cb324379a365225b0f702ad8d";
      #     hash = "sha256-aCw7Tjng+c5ykga5mBPDMohZauhczzV6PWwydw4ymUQ=";
      #   };
      # }))
      paperwm
      # swap-finger-gestures-3-to-4
      # gnome-40-ui-improvements
      transparent-top-bar-adjustable-transparency

      easyeffects-preset-selector

    ] ++ (with pkgs; [
      wl-clipboard
      # kdeconnect
      easyeffects
      gnome.gnome-tweaks
    ]);
  };
  
  services.gnome.gnome-browser-connector = on;
  services.xserver.displayManager.gdm = on;
  hardware.pulseaudio = off;

}
