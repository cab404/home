args@{ config, lib, pkgs, ... }:
with import ../lib.nix args; {

  services = {

    udev.packages = with pkgs; [
      android-udev-rules
      stlink
      libsigrok
      openocd
      (writeTextDir "/etc/udev/rules.d/42-user-devices.rules" ''
        # Saleae Logic thing
        ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", GROUP+="dialout"
        # USBTiny
        ATTR{idVendor}=="1781", ATTR{idProduct}=="0c9f", GROUP+="dialout"
        # DSO-2090
        ATTR{idVendor}=="04b4", ATTR{idProduct}=="2090", GROUP+="dialout"

        SUBSYSTEM=="usb", ACTION=="add", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="04b5", ATTRS{idProduct}=="6021", TAG+="uaccess", TAG+="udev-acl", GROUP="plugdev"
      '')
      ledger-udev-rules
    ];

  };
}