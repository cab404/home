{ pkgs, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "621c98f15a31e7f0c1389f69aaacd0ac267ce29e";
  };
  evalHomeConfig = import "${home-manager}/modules";
in
{
  # imports = [ "${home-manager}/nixos" ];
  # home-manager.useUserPackages = true;
  # home-manager.users.cab = builtins.removeAttrs (evalHomeConfig {
  #     configuration = ./home.nix;
  #     inherit pkgs;
  # }).config [ "_module" "assertions" "home" "submoduleSupport"];
}
