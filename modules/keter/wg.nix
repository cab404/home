{ config, ... }: let wgbondConf = import ./wgbond.nix; in {
} // wgbondConf.${config.system.name} // wgbondConf.defaults
