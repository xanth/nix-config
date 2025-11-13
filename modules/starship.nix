# Starship prompt configuration
{ hostConfig, ... }:
let
  starshipConfig = import ./starship.configuration.nix;
in
{
  home-manager.users.${hostConfig.userName} = {
    # Use home-manager's native starship module
    programs.starship = {
      enable = true;
      # Configuration written to ~/.config/starship.toml
      settings = starshipConfig;
    };

    # PowerShell starship integration fragment
    home.file.".config/powershell/fragments/starship.ps1".text = ''
      # Initialize Starship prompt for PowerShell
      if (Get-Command starship -ErrorAction SilentlyContinue) {
        Invoke-Expression (&starship init powershell)
      }
    '';
  };
}
