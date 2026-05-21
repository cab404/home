{pkgs, config, lib, ...}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
    enableNvidia = lib.modules.mkDefault (builtins.elem "nvidia" config.boot.kernelModules);
  };
  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
