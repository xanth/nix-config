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

    sops.defaultSopsFile = ../secrets/secrets.yaml;

    sops.secrets."ssh_private_key" = {
      path = "${hostConfig.homeDirectory}/.ssh/id_ed25519";
      mode = "0600"; # Important: correct permissions for SSH keys
    };
  };
}
