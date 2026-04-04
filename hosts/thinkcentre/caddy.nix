{
  pkgs,
  lib,
  ...
}: {
  services.caddy = {
    enable = true;
    virtualHosts."https://feder-home.duckdns.org".extraConfig = ''
      reverse_proxy http://127.0.0.1:8123
    '';
  };
}
