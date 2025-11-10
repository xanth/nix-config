# SOPS module - Secret management with SOPS
{ pkgs, hostConfig, ... }:
{
  environment.systemPackages = with pkgs; [
    sops
    age
  ];

  home-manager.users.${hostConfig.userName} = {
    # Enable sops for home-manager with GPG
    sops.gnupg.home = "${hostConfig.homeDirectory}/.gnupg";
    sops.gnupg.sshKeyPaths = [ ];

    # Uncomment and configure when you have a secrets file:
    # sops.defaultSopsFile = ../secrets/secrets.yaml;

    # Example: Define individual secrets
    # sops.secrets.example_password = {};
    # sops.secrets.api_key = {};

    # For age instead of GPG, uncomment:
    # sops.age.keyFile = "${hostConfig.homeDirectory}/.config/sops/age/keys.txt";
  };
}
