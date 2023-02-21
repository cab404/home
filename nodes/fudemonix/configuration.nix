{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in {

  imports = [
    <modules/core.nix>
    <modules/home-manager>
    <modules/recipes/known-keys.nix>
    <modules/recipes/klipper.nix>
    <modules/recipes/ssh.nix>
  ];

  networking.hostName = "fudemonix";
  _.user = "cab";

  printing.klipper = on // {
    printer = {
      fwBuildConfig = ./buildconfig.ini;
      configFile = ./printer.cfg;
      serial = "/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0";
    };
  };

  services.rtsp-simple-server = on // {
    settings = {
      hlsDisable = true;
      rtmpDisable = true;
      paths = {
        cam = {
          runOnInit = "ffmpeg -f v4l2 -i /dev/video0 -f rtsp rtsp://localhost:$RTSP_PORT/$RTSP_PATH";
          runOnInitRestart = true;
        };
        # cam2 = {
        #   runOnInit = "ffmpeg -f v4l2 -i /dev/v4l/by-id/usb-046d_09c1-video-index1 -pix_fmt yuv420p -preset ultrafast -b:v 600k -f rtsp rtsp://localhost:$RTSP_PORT/$RTSP_PATH";
        #   runOnInitRestart = true;
        # };
      };
    };
  };
  networking.firewall.enable = false;

}
