{
  pkgs,
  lib,
  config,
  ...
}:
{
  # Matter server 
  services.matter-server = {
    enable = true;
  };
  # Add automation file
  # https://wiki.nixos.org/wiki/Home_Assistant
  systemd.tmpfiles.rules = [
    "L+ ${config.services.home-assistant.configDir}/automation_hallway_light.yaml - - - - ${./automation_hallway_light.yaml}"
    "L+ ${config.services.home-assistant.configDir}/automation_air_off_light.yaml - - - - ${./automation_air_off_light.yaml}"
    "L+ ${config.services.home-assistant.configDir}/automation_air_on_light.yaml - - - - ${./automation_air_on_light.yaml}"
  ];
  # HomeAssistant
  # https://smlight.tech/support/manuals/books/slzb-06xmrxmrxuultima-series/page/thread-setup-network-and-usb-connection#otbr
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    configDir = "/data/home-assistant";
    extraPackages = python3packages: with python3packages; [
      pychromecast
      pysmlight
      pydaikin
      androidtvremote2
      getmac
    ];
    extraComponents = [
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      
      "matter"
      "thread"
      "otbr"
      "mobile_app"
      # Components required to complete the onboarding
    ];
    config = {
      http = {
        base_url = "https://feder-home.duckdns.org";
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
        ];
        server_host = [
          "127.0.0.1"
        ];
        server_port = 8123;
        #ssl_certificate = "/etc/letsencrypt/live/mfeder.duckdns.org/fullchain.pem";
        #ssl_key = "/etc/letsencrypt/live/mfeder.duckdns.org/privkey.pem";
      };
      homeassistant = {
        unit_system = "metric";
        latitude = 48.2343;   # Pezinok latitude
        longitude = 17.2267;  # Pezinok longitude
        internal_url = "http://127.0.0.1:8123";
        external_url = "https://feder-home.duckdns.org";
      };
      recorder = {
        purge_keep_days = 60;
      };
      # Automations
      "automation hallway" = "!include automation_hallway_light.yaml"; 
      "automation air off" = "!include automation_air_off_light.yaml"; 
      "automation air on" = "!include automation_air_on_light.yaml"; 
      default_config = {};
    };
    lovelaceConfigFile = ./lovelace.yaml;
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      button-card
      card-mod
    ];
  };
}
