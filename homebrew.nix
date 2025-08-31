# Homebrew configuration - package management and application installation
{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    global.autoUpdate = true;

    brews = [
    ];
    taps = [
    ];
    casks = [
      "github"
      "AlDente"
    ];
    masApps = {
      "Bitwarden" = 1352778147;
      "Yubico Authenticator" = 1497506650;
      "Kagi for Safari" = 1622835804;
    };
  };
}
