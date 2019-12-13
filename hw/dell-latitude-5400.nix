{...}: {
  # Trackpoint scroll fix. Injection!
  services.xserver.libinput.additionalOptions = ''
EndSection
Section "InputClass"
  Identifier "libinput pointer catchall"
  MatchIsPointer "on"
  MatchDevicePath "/dev/input/event*"
  Driver "libinput"
  Option "ScrollMethod" "button"
  Option "ScrollButton" "2"
  '';
}
