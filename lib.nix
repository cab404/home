{ lib, ... }: let
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
  };
  on = { enable = true; };
  forgiveMeStallman = package: package.overrideAttrs(a: { meta = {}; });
in {
  inherit enableThings on forgiveMeStallman;
}
