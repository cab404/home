{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in# %%MODULE_HEADER%%
{

  home-manager.users.${config._.user}.imports = [
    ./home.nix
  ];

  imports = [
    ../graphical.nix
    ../gnome-services.nix
  ];

  programs.firefox.nativeMessagingHosts.packages = with pkgs; [
    gnomeExtensions.gsconnect
  ];

  # qt = on // {
  #   platformTheme = "gnome";
  # };

  security.rtkit = on;

  services.xserver.desktopManager.gnome = on // {
    sessionPath = with pkgs.gnomeExtensions; [

      vertical-workspaces # So PaperWM doesn't look dumb and vertical
      paperwm # So I get infinite space to clutter
      hide-top-bar # So there's even more space to clutter
      just-perfection # To move clock to the right obvs

      cronomix # Ultra-cool time tools
      caffeine # Don't leave home without
      easyeffects-preset-selector # Easyeffects is hungry

      gsconnect # KDE connect on GSteroids
      # tailscale-status # Tailscale status
      tailscale-qs # Better tailscale status
      window-calls-extended # For tracking and querying window changes
      compact-top-bar # Well, since we don't have split top bars...

      browser-tabs # maybe it works?

      expandable-notifications # YESS YESS
      
    ] ++ (with pkgs; [
      wl-clipboard
      easyeffects
      gnome.gnome-tweaks
      gnome.gnome-calculator
    ]);
  };

  environment.sessionVariables = {
    # woo wrappers
    # NIXOS_OZONE_WL = "1";
  };

  services.dbus = {
    packages = with pkgs; [
      flatpak
    ];
    implementation = "broker";
  };

  systemd.packages = [
    (pkgs.writeTextFile {
      name = "flatpak-dbus-overrides";
      destination = "/etc/systemd/user/dbus-.service.d/flatpak.conf";
      text = ''
        [Service]
        ExecSearchPath=${pkgs.flatpak}/bin
      '';
    })
  ];

  services.gnome = { };

  programs.dconf = on;

  services.xserver.enable = true;
  # services.xserver.autorun = false;
  services.xserver.displayManager.gdm = on // {
    # wayland = false;
  };
  hardware.pulseaudio = off;

}
