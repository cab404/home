{ ... }: {
  fileSystems."/var/log" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=200M" "mode=777" ];
  };
}
