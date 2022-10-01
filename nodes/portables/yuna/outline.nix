{ config, lib, pkgs, ... }:

{
  services.minio = {
    enable = true;
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    rootCredentialsFile = "/secrets/minio_creds";
  };

  services.outline = {
    enable = true;
    forceHttps = false;
    debugOutput = "http";
    oidcAuthentication =
      let gitlabOpenID = with builtins; fromJSON (readFile ./oidc.json);
      in {
        clientId =
          "64686cd23b657f49742778de160c8728dfa98f8e329baa3559e8dbe3dc7f01b0";
        clientSecretFile = toString ./test;
        scopes = [ "openid" "email" ];
        usernameClaim = "username";

        authUrl = gitlabOpenID.authorization_endpoint;
        tokenUrl = gitlabOpenID.token_endpoint;
        userinfoUrl = gitlabOpenID.userinfo_endpoint;

      };

    storage = {
      region = "us-east-1";
      accessKey = "cSdqKKPYClRtdZVW";
      secretKeyFile = "/secrets/outline-keys"; # builtins.toFile "a" "zD541PvhrVaXyGuIyo7tNNKOpRQpJMbm";
      uploadBucketUrl = "http://127.0.0.1:9000";
      uploadBucketName = "outline";
      forcePathStyle = false;
    };
  };

  systemd.services.outline.environment = {
    SMTP_HOST = "mail.cock.li";
    SMTP_PORT = "465";
    SMTP_USERNAME = "fellatio@cock.li";
    SMTP_PASSWORD = "do>e3roojieN";
    SMTP_FROM_EMAIL = "fellatio@cock.li";

  };

  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    extraConfig = ''
      ui = true
    '';
    storageBackend = "file";
  };


  services.postgresql = {
    ensureDatabases = [ "dex" ];
    ensureUsers = [
      {
        name = "root";
        ensurePermissions = {
          "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
        };
      }
      # {
      #   name = "keycloak";
      #   ensurePermissions = { "DATABASE keycloak" = "ALL PRIVILEGES"; };
      # }
      {
        name = "dex";
        ensurePermissions = { "DATABASE dex" = "ALL PRIVILEGES"; };
      }
    ];
  };

#  documentation.nixos.enable = false;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "outline" ];

}
