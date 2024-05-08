args@{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in 
let 
  fqdn = "cab.moe";
in {

  systemd.services.mail-htpasswd-update = {
    script = ''
      {
      ${with lib; let
          mailAccounts = config.mailserver.loginAccounts;
        in concatStrings (flip mapAttrsToList mailAccounts (mail: user:
        ''
          echo -n ${mail}:
          ${ if user.hashedPasswordFile != null then ''         
            cat ${user.hashedPasswordFile}
          '' else ''
            echo ${user.hashedPassword}
          '' }
          echo
        ''
      ))}
      } >> /run/radicale-htpasswd
    '';
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "radicale.service"
    ];
  };

  services.radicale = {
    enable = true;
    settings.auth = {
      type = "htpasswd";
      htpasswd_filename = "/run/radicale-htpasswd";
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
    
    enableManageSieve = true;
    # Eeeh. It's not really that useful, as by default this mailbox is not being subscribed to,
    # and I can't move them to a subdirectory, so they don't clutter the space.
    # All it achieves in the end is a total useless fragmentation of mailbox.
    # I guess I'll need a proper mail proxy.
    lmtpSaveToDetailMailbox = "no";

    # Well, let's move to a newer hierarchy separator
    hierarchySeparator = "/";
    
    loginAccounts = {
      "cab@${fqdn}" = {
        aliases = [
          "me"
          "resume"
          "webmaster"
          "admin"
          "cab404@mailbox.org"
          "@cab404.ru"
        ];
        hashedPasswordFile = "/secrets/cab-mail-pw";
      };
    };

    indexDir = "/var/lib/dovecot/indices";
    fullTextSearch = on // {
      autoIndex = true;
      enforced = "body";
    };
  };

  services.dovecot2.sieve.extensions = [ "fileinto" ];

}
