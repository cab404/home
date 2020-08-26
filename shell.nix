let
  s = import ./nix/sources.nix;
in with import s.nixpkgs {}; mkShell {
  buildInputs = [ nixfmt niv nixUnstable ];
}
