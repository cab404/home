args @ { sysconfig, config, pkgs, lib, ... }:
with import ../../lib.nix args;
{
  programs.starship = on // {
    enableNushellIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    settings = {
      character.success_symbol = "[δ](dimmed green)";
      character.error_symbol = "[δ](bold red)";
      time = {
        disabled = false;
        format = "[$time]($style)";
        time_format = "%H:%M";
      };
      # too many shells
      shell = {
        disabled = false;
      };
      battery = {
        full_symbol = "";
        charging_symbol = "+";
        discharging_symbol = "-";
        unknown_symbol = "?";
        empty_symbol = "X";
        format = "[$symbol$percentage]($style)";
        display = [
          { style = "red"; threshold = 15; }
          { style = "dimmed red"; threshold = 50; }
          { style = "dimmed green"; threshold = 99; }
          { style = "bold green"; threshold = 100; }
        ];
      };
    };
  };
}