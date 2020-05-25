rec {
  nixpkgs = import <nixpkgs> {};
  home-manager =
    let
      try = builtins.tryEval <home-manager>;
      hm = if try.success then
        try.value
      else
        nixpkgs.fetchFromGitHub {
          owner = "rycee";
          repo = "home-manager";
          rev = "cba7b6ee6e056421f862b008b45f1ff9cc2e7252";
          sha256 = "1q7diljdkj0q7d7k79rghx3yp683p6q8dg43h8h1bklzrywxir8a";
        };
    in
      hm;
}
