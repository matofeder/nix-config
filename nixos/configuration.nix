# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  boot.kernel.sysctl = {
    # Enable ipv4 and ipv6 forwarding
    ###  IPv4 forwarding
    "net.ipv4.ip_forward" = 1;
    ###  IPv6 forwarding
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.default.forwarding" = 1;
    "net.ipv6.conf.enp3s0f0.forwarding" = 1;

    ### IPv6 Router Advertisements (RA)
    # 2 = allow RA
    "net.ipv6.conf.all.accept_ra" = 2;
    "net.ipv6.conf.default.accept_ra" = 2;
    "net.ipv6.conf.enp3s0f0.accept_ra" = 2;

    ###  RA route info 
    "net.ipv6.conf.all.accept_ra_rt_info_max_plen" = 128;
    "net.ipv6.conf.default.accept_ra_rt_info_max_plen" = 128;
    "net.ipv6.conf.enp3s0f0.accept_ra_rt_info_max_plen" = 128;     
  };
  boot.kernelModules = [ "ip_tables" "ip6_tables" "nf_nat" "nf_conntrack" "xt_conntrack" ];
  networking.hostName = "tc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp3s0f0.ipv4.addresses = [
    {
      address = "192.168.0.100";
      prefixLength = 24;
    }
  ];
  networking.nameservers = [ "217.23.254.124" "217.23.254.125" ];

  networking.defaultGateway = "192.168.0.1";
  services.duckdns = {
    enable = true;
    tokenFile = "/secrets/duckdns.token";
    domains = [ "mfeder.duckdns.org" ];
  };
  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "Europe/Bratislava";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sk_SK.UTF-8";
    LC_IDENTIFICATION = "sk_SK.UTF-8";
    LC_MEASUREMENT = "sk_SK.UTF-8";
    LC_MONETARY = "sk_SK.UTF-8";
    LC_NAME = "sk_SK.UTF-8";
    LC_NUMERIC = "sk_SK.UTF-8";
    LC_PAPER = "sk_SK.UTF-8";
    LC_TELEPHONE = "sk_SK.UTF-8";
    LC_TIME = "sk_SK.UTF-8";
  };
  
  # Disable suspend
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mato = {
    isNormalUser = true;
    description = "mato";
    extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
    ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1vVtRkK2mB3C6PqCBkmoc/GUBTYI+EySqr/NhNHc2S feder.mato@gmail.com"
    ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  # Docker
  virtualisation.docker.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    htop
    tmux
    certbot
    dig
    docker-compose
    tcpdump
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
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
        server_host = [
          "::"
          "0.0.0.0"
        ];
        server_port = 8123;
        ssl_certificate = "/etc/letsencrypt/live/mfeder.duckdns.org/fullchain.pem";
        ssl_key = "/etc/letsencrypt/live/mfeder.duckdns.org/privkey.pem";
      };
      homeassistant = {
        unit_system = "metric";
        latitude = 48.2343;   # Pezinok latitude
        longitude = 17.2267;  # Pezinok longitude
        internal_url = "https://mfeder.duckdns.org:8123";
        external_url = "https://mfeder.duckdns.org:8123";
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
  # DATA mount 500G HDD
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/7bdaac85-aaab-4ba9-ada1-435eb0769432";
    fsType = "ext4";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  # networking.firewall.allowedTCPPorts = [ 80 443 8123 ];
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
