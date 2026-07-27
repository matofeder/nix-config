{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/base.nix
    ../../modules/gnome.nix
    ../../modules/haas/homeassistant.nix
    ./caddy.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
    };
  };

  # Sysctl /HA/
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
  networking = {
    networkmanager.enable = true;
    useDHCP = false;

    defaultGateway = "192.168.0.1";  
    interfaces.enp3s0f0.ipv4.addresses = [
      {
        address = "192.168.0.100";
        prefixLength = 24;
      }
    ];
    nameservers = [ "217.23.254.124" "217.23.254.125" ];
  };


  # 500G HDD
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/7bdaac85-aaab-4ba9-ada1-435eb0769432";
    fsType = "ext4";
  };

  services.duckdns = {
    enable = true;
    tokenFile = "/secrets/duckdns.token";
    domains = [ "mfeder.duckdns.org" ];
  };

  # Disable suspend
  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowSuspendThenHibernate = false;
    AllowHybridSleep = false;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
