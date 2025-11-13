{ ... }:
{
  # this is internal compatibility configuration
  # for home-manager, don't change this!
  home.stateVersion = "25.05";
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable font management
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "vscode";
  };
}
