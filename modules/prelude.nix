{ lib, ... }: rec {
  enableThings = with builtins;
    things: overrides:
    if length things == 0
    then overrides
    else lib.recursiveUpdate (enableThings (tail things) overrides) {
      "${head things}".enable = true;
  };
  __findFile = f: s: ../${s};
  on = { enable = true; };
  off = { enable = false; };
  forgiveMeStallman = package: package.overrideAttrs(a: { meta = {}; });
}
