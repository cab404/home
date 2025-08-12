{
  systemd.settings.Manager.WatchdogDevice = "/dev/watchdog0";
  systemd.settings.Manager.RuntimeWatchdogSec = "5s";
  systemd.settings.Manager.RebootWatchdogSec = "30s";
}
