{
  pkgs,
  lib,
  ...
}:
{
  # Matter server 
  services.matter-server = {
    enable = true;
  };
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
      "automation lights" = {
         alias = "Zapnutie svetla pri pohybe v noci";
         description = "Zapne svetlo na 30% pri detekcii pohybu medzi 21:00 a 06:00 a po 3 minútach ho vypne";
         trigger = [
           {
             platform = "state";
             entity_id = "binary_sensor.myggspray_wrlss_mtn_sensor_occupancy";
             to = "on";
           }
         ];
         condition = [
           {
             condition = "time";
             after = "21:00:00";
             before = "06:00:00";
           }
         ];
         action = [
           {
             service = "light.turn_on";
             target = {
               entity_id = "light.kajplats_e14_ws_globe_806lm";
             };
             data = {
               brightness_pct = 50;
             };
            }
            {
              delay = "00:00:30";
            }
            {
              service = "light.turn_off";
              target = {
                entity_id = "light.kajplats_e14_ws_globe_806lm";
              };
            }
          ];
      };
      default_config = {};
    };
  };
}
