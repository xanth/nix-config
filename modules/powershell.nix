# PowerShell module - PowerShell installation and configuration
{ pkgs, hostConfig, ... }:
let
  # Import profile fragments
  aliasesFragment = import ./powershell.aliases.nix;

  # Compose profile content for different host locations
  composeProfile = fragments: builtins.concatStringsSep "\n\n" fragments;
  
  currentUserAllHostsContent = composeProfile [
    ''
    # User-specific configurations that apply across all hosts
    ''
  ];
  
  currentUserCurrentHostContent = composeProfile [
    ''
    # Add nix-darwin paths to PATH
    $env:PATH = "/run/current-system/sw/bin:$env:PATH"
    
    # run all files in fragments
    Get-ChildItem -Path ~/.config/powershell/fragments -Filter *.ps1 `
      | ForEach-Object { . $_.FullName }
    ''
    aliasesFragment
  ];
in
{
  environment.systemPackages = with pkgs; [
    powershell
  ];

  home-manager.users.${hostConfig.userName} = {
    # Create the fragments directory structure
    home.file.".config/powershell/fragments/.keep".text = "";
    
    # CurrentUserAllHosts: ~/.config/powershell/profile.ps1
    home.file.".config/powershell/profile.ps1".text = currentUserAllHostsContent;
    
    # CurrentUserCurrentHost: ~/.config/powershell/Microsoft.PowerShell_profile.ps1
    home.file.".config/powershell/Microsoft.PowerShell_profile.ps1".text = currentUserCurrentHostContent;
  };
}
