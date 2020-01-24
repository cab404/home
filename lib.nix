{ pkgs }: let
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else pkgs.lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
    };
in {
  inherit enableThings;
}
