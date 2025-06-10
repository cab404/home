args@{ sysconfig
, config
, pkgs # inputs.nixpkgs
, lib # inputs.nixpkgs.lib
, inputs
, prelude
, ...
}:
with prelude; let __findFile = prelude.__findFile; in
{
    virtualisation.podman = on;
    services.ollama.enable = true;

    fonts.packages = with pkgs; [
      # Fonts
      source-code-pro
      noto-fonts
      fira-code
      fira
      font-awesome
      gohufont
      monaspace
      source-code-pro
      source-sans
      ubuntu_font_family
    ];
    # boot.extraModulePackages = with config.boot.kernelPackages; [ rtl8814au ];
}
