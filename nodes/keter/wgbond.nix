{
  defaults = {
    networking.extraHosts = ''
      # Hosts for Wireguard network "keter"
      # Generated by wgbond
      10.0.10.1	tiferet.keter
      10.0.10.2	c1.keter
      10.0.10.3	c2.keter
      10.0.10.4	yuna.keter
      10.0.10.5	recvme.keter
      10.0.10.6	works-printer.keter
      10.0.10.7	mi-a3.keter
      10.0.10.8	undef.keter
      10.0.10.9	pixel3-tutturu.keter
    '';
  };
  "tiferet".networking.wg-quick.interfaces."keter" = {
    privateKeyFile = "/secrets/wg-keter.ed25519.base64";
    listenPort = 61111;
    address = [ "10.0.10.1" "fd80:c4b4::1" ];
    # preUp =
    #   "iptables -A POSTROUTING -t nat -j MASQUERADE -s 10.0.10.0/24 -o ens2;ip6tables -A POSTROUTING -t nat -j MASQUERADE -s fd80:c4b4::/48 -o ens2";
    # preDown =
    #   "iptables -D POSTROUTING -t nat -j MASQUERADE -s 10.0.10.0/24 -o ens2;ip6tables -D POSTROUTING -t nat -j MASQUERADE -s fd80:c4b4::/48 -o ens2";
    peers = [
      {
        publicKey = "JR36+8Btz6610PEOR2sRAVVT1gTrv17HMgKYsu8g0ik=";
        allowedIPs = [ "10.0.10.2/32" "fd80:c4b4::2/128" ];
        persistentKeepalive = 30;
      }
      {
        publicKey = "SmCDe1jqEFEjbwrpM7Be4et41Y+W3aXD+1tHqLuQsi8=";
        allowedIPs = [ "10.0.10.3/32" "fd80:c4b4::3/128" ];
      }
      {
        publicKey = "XJQy7gtxvoy3vqe1Lf6rBHud9t/3SgQQx9NV5o06L1Y=";
        allowedIPs = [ "10.0.10.4/32" "fd80:c4b4::4/128" ];
      }
      {
        publicKey = "c0M7Klm4eo2nyuzeg9gSihRJdRJqn/xh74fZmEHC8nI=";
        allowedIPs = [ "10.0.10.5/32" "fd80:c4b4::5/128" ];
      }
      {
        publicKey = "12npjtZIV8V2HaTDOsr55D3IhOOAL4IfOqX94JT7V18=";
        allowedIPs = [ "10.0.10.6/32" "fd80:c4b4::6/128" ];
      }
      {
        publicKey = "Nt8Kqv4fdOD7CofOwRcRAz0oksAm5D9eeiti0MRpUBw=";
        allowedIPs = [ "10.0.10.7/32" "fd80:c4b4::7/128" ];
      }
      {
        publicKey = "0QiYvPknOMCzDe1WlGy2YQGhejzNvu2NX4ENK920vzQ=";
        allowedIPs = [ "10.0.10.8/32" "fd80:c4b4::8/128" ];
      }
      {
        publicKey = "me+ciaBJSLD0AXy3ddBqM92Rf6vM1TCnkC2vsIoVLD8=";
        allowedIPs = [ "10.0.10.9/32" "fd80:c4b4::9/128" ];
      }
    ];
  };
  "c1".networking.wg-quick.interfaces."keter" = {
    privateKeyFile = "/secrets/wg-keter.ed25519.base64";
    listenPort = 61111;
    address = [ "10.0.10.2" "fd80:c4b4::2" ];
    peers = [{
      publicKey = "AhOeGzMO2evGSkyI+IJVNoF9+POHGlnk+/XRWK4Jvhw=";
      allowedIPs = [
        # "::/0"
        # "0.0.0.0/0"
        "10.0.10.0/24"
        "fd80:c4b4::/48"
        "10.0.10.1/32"
        "fd80:c4b4::1/128"
      ];
      persistentKeepalive = 30;
      endpoint = "51.15.83.8:61111";
    }];
  };
  "c2".networking.wg-quick.interfaces."keter" = {
    privateKeyFile = "/secrets/wg-keter.ed25519.base64";
    address = [ "10.0.10.3" "fd80:c4b4::3" ];
    peers = [{
      publicKey = "AhOeGzMO2evGSkyI+IJVNoF9+POHGlnk+/XRWK4Jvhw=";
      allowedIPs = [
        "::/0"
        "0.0.0.0/0"
        "10.0.10.0/24"
        "fd80:c4b4::/48"
        "10.0.10.1/32"
        "fd80:c4b4::1/128"
      ];
      persistentKeepalive = 30;
      endpoint = "51.15.83.8:61111";
    }];
  };
}
