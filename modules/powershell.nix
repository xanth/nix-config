# PowerShell module - PowerShell installation and configuration
{ pkgs, hostConfig, ... }:
let
  # Import profile fragments
  coreFragment = import ./powershell.core.nix;
  aliasesFragment = import ./powershell.aliases.nix;

  # Compose profile content for different host locations
  composeProfile = fragments: builtins.concatStringsSep "\n\n" fragments;
  
  # Profile content for different locations based on PowerShell's profile hierarchy
  allUsersAllHostsContent = composeProfile [
    coreFragment
  ];
  
  allUsersCurrentHostContent = composeProfile [
    aliasesFragment
  ];
  
  currentUserAllHostsContent = composeProfile [
    ''
    # User-specific configurations that apply across all hosts
    ''
  ];
  
  currentUserCurrentHostContent = composeProfile [
    ''
    # run all files in fragments
    Get-ChildItem -Path ~/.config/powershell/fragments -Filter *.ps1 `
      | ForEach-Object { . $_.FullName }
    ''
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
