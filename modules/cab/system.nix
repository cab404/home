args@{ sysconfig
, config
, pkgs # inputs.nixpkgs
, lib # inputs.nixpkgs.lib
, inputs
, prelude
, ...
}:
with prelude; let __findFile = prelude.__findFile; in
{
    virtualisation.podman = on;
    services.ollama.enable = true;
    # boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8814au ];
}
