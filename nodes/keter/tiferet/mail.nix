args@{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in 
let 
  fqdn = "cab.moe";
  mailAccounts = config.mailserver.loginAccounts;
  htpasswd = with lib; pkgs.writeText "radicale.users" (concatStrings
    (flip mapAttrsToList mailAccounts (mail: user:
      mail + ":" + user.hashedPassword + "\n"
    ))
  );
in {
  services.radicale = {
    enable = true;
    settings.auth = {
      type = "htpasswd";
      htpasswd_filename = toString htpasswd;
      htpasswd_encryption = "bcrypt";
    };
  };


  imports = [
    inputs.snm.nixosModule
  ];

  services.caddy = on // {
    virtualHosts = {
      "cal.${fqdn}".extraConfig = ''
         reverse_proxy localhost:5232
      '';
      ${fqdn}.extraConfig = ''
        @calcard path_regexp /.well-known/(cal|card)dav
        redir @calcard //cal.${fqdn}

        handle {
          respond "o hai!"
        }
      '';
    };
  };

  mailserver = on // {
    inherit fqdn;
    domains = [ fqdn "cab404.ru" ];
    certificateScheme = "manual";
    certificateFile = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${fqdn}/${fqdn}.crt";
    keyFile = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${fqdn}/${fqdn}.key";
    loginAccounts = {
      "cab@${fqdn}" = {
        aliases = [ 
          "me"
          "cab404@mailbox.org"
          "@cab404.ru"
        ];
        hashedPassword = "$2y$05$/7OpSkstC8yoFQmkFpE.puPPP.0CxY1JsRTKAutMHjLtH1CmMQJme";
      };
    };

    fullTextSearch = on // {
      autoIndex = true;
      # indexAttachments = true;
      enforced = "body";
    };
  };

}
