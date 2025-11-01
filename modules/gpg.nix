# GPG module - GnuPG installation and configuration
{ pkgs, hostConfig, ... }:
{
  environment.systemPackages = with pkgs; [
    gnupg
    pinentry_mac
  ];

  home-manager.users.${hostConfig.userName} = {
    programs.gpg = {
      enable = true;
      settings = {
        # Default key settings
        default-key-server = "hkps://keys.openpgp.org";
        # Use GPG Agent for passphrase management
        use-agent = true;
      };
    };

    services.gpg-agent = {
      enable = true;
      # Enable SSH support if needed
      enableSshSupport = false;
      # Use pinentry-mac for macOS integration
      pinentry.package = pkgs.pinentry_mac;
      # Default cache TTL (1 hour)
      defaultCacheTtl = 3600;
      # Maximum cache TTL (2 hours)
      maxCacheTtl = 7200;
    };

    # Create GPG configuration directory
    home.file.".gnupg/.keep".text = "";
  };
}

