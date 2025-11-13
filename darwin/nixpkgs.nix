{ ... }:
{
  # Nixpkgs configuration
  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
  };
}
