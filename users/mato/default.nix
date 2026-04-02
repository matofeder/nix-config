{
  ##################################################################################################################
  #
  # NixOS Configuration
  #
  ##################################################################################################################

  users.users.mato = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1vVtRkK2mB3C6PqCBkmoc/GUBTYI+EySqr/NhNHc2S feder.mato@gmail.com"
    ];
  };
}