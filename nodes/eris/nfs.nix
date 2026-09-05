{
  # nfs
  services.nfs.server = {
    enable = true;
    # hostName = "eris.lan";
    exports = {
      "/home/cab" = {
        "*.keter" = [
          "rw"
        ];
        # "baba.keter" = [
        #   "rw"
        # ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
