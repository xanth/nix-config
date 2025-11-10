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
        # Keyserver for key lookups
        keyserver = "hkps://keys.openpgp.org";
        # Use GPG Agent for passphrase management
        use-agent = true;
        # Security and display settings
        charset = "utf-8";
        fixed-list-mode = true;
        keyid-format = "0xlong";
        with-fingerprint = true;
        # Privacy settings
        no-comments = true;
        no-emit-version = true;
        # Cipher preferences
        personal-cipher-preferences = "AES256 AES192 AES";
        personal-digest-preferences = "SHA512 SHA384 SHA256";
        personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
        default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
        # Algorithm settings
        cert-digest-algo = "SHA512";
        s2k-cipher-algo = "AES256";
        s2k-digest-algo = "SHA512";
        # Other settings
        require-cross-certification = true;
        no-symkey-cache = true;
        list-options = "show-uid-validity";
        verify-options = "show-uid-validity";
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
