{ pkgs, ... }: {

  programs.sway = {
    enable = true;
    extraSessionCommands = ''
    export SDL_VIDEODRIVER=wayland
    # needs qt5.qtwayland in systemPackages
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    # Fix for some Java AWT applications (e.g. Android Studio)
    # use this if they aren't displayed properly:
    export _JAVA_AWT_WM_NONREPARENTING=1
    export MOZ_ENABLE_WAYLAND=1
    '';
    extraPackages = with pkgs; [
      xwayland qt5.qtwayland swaylock
    ];
  };

  services.xserver.displayManager.session = [
    {
      manage = "desktop";
      name = "Sway";
      start = "exec ${pkgs.sway}/bin/sway";
    }
  ];

}
