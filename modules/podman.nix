{config, lib, ...}: ({
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };
} // lib.ifAttrs config.hardware.nvidia.enabled {
  virtualisation.podman.enableNvidia = true;
})
