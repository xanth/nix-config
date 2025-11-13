{ hostConfig, self, ... }:
{
  # Enabled TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  # System configuration
  system = {
    # Set Git commit hash for darwin-version
    configurationRevision = self.rev or self.dirtyRev or null;
    # Used for backwards compatibility, please read the changelog before changing
    # $ darwin-rebuild changelog
    stateVersion = 6;
    primaryUser = hostConfig.userName;
  };
}
