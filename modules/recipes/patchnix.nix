{
  nixpkgs.overlays = [
    (prev: next: {
      nix = prev.nix.overrideAttrs {
        patches = [ ../../patches/nix-fuse.patch ];
      };
    })
  ];
  
}
