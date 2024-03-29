args@{ config, lib, pkgs, ... }:
let
  on = { enable = lib.mkDefault true; };
in
{ services = {
    # That gets some services from cinnamon (I need) working

    # Stuff copied over or stuffed in from
    # cinnamon and commented on

    printing = on;

    dbus = {
      packages = with pkgs; [
        flatpak
        xdg-dbus-proxy
        zeitgeist
      ];
      # implementation = "broker";
    };

    gnome = {

      # Search and stuff
      tracker = on;

      # more miners!
      tracker-miners = on;

      # accesibility, if I ever loose my sight or smth
      at-spi2-core = on;

      # that's apparently part of GIO,
      # which in part is a replacement for gvfs
      # glib-networking = on;

      # something something
      gnome-online-accounts = on;

      # should make online stuff searchable - alas
      gnome-online-miners = on;

      # Maybe thiiis will enable it?
      # gnome-browser-connector = on;

      # gnome-remote-desktop = on;

      # gnome-user-share = on;

      evolution-data-server = on;

      core-utilities = on;
      core-os-services = on;
      core-shell = on;
      core-developer-tools = on;

      # this fella makes thumbnails!
      sushi = on;

      # UPnP video sharing
      # rygel = on;

    };

    # power stats and stuff
    # upower = on;

    # disk mounting, and... stuff
    # udisks2 = on;

    # display color management, if I ever need it (i don't)
    # colord = on;

    # yeah, accounts for gnome stuff I might use
    # accounts-daemon = on;

    # dbus for nice printer config UIs
    # system-config-printer = on;

    # not so gnome, eeh?

    # an event logger
    zeitgeist = on;

    # a program matcher
    # bamf = on;

  };

}
