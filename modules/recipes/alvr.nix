{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; 
in
{
  programs.alvr = on // {
    openFirewall = true;
  };
}