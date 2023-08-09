args@{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in {
  systemd.services.killbt = rec {
    description = "Stop BT before all kinds of sleep";
    before = [
      "sleep.target"
      "suspend.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    wantedBy = before;
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bluez}/bin/bluetoothctl power off";
      ExecStop = "${pkgs.bluez}/bin/bluetoothctl power on";
    };
  };
}
