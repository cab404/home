let
  getMachineModules = name: [
    (import ./${name})
    (import ./wgbond.nix).defaults
    (import ./wgbond.nix).${name}
    {
      _.user = "cab";
    }
  ];
  machines = [ "c1" "tiferet" ];
in
with builtins;
listToAttrs
  (map
    (name: { inherit name; value = getMachineModules name; })
    machines
  )
