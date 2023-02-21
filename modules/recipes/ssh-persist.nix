{ inputs, prelude, lib, config, pkgs, ... }: with prelude;
let __findFile = prelude.__findFile; in
{
  # %%MODULE_HEADER%%
  programs.ssh = {
    extraConfig = ''
      Host *
      ControlMaster auto
      ControlPath ~/.ssh/master-%r@%n:%p
      ControlPersist 2m
    '';
  };

}
