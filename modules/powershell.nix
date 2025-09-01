# PowerShell module - PowerShell installation and configuration
{ pkgs, hostConfig, ... }:
let
  # Import profile fragments
  coreFragment = import ./powershell-fragments/core.nix;
  aliasesFragment = import ./powershell-fragments/aliases.nix;
  zoxideFragment = import ./powershell-fragments/zoxide.nix;
  
  # Compose profile content for different host locations
  composeProfile = fragments: builtins.concatStringsSep "\n\n" fragments;
  
  # Profile content for different locations based on PowerShell's profile hierarchy
  allUsersAllHostsContent = composeProfile [
    coreFragment
  ];
  
  allUsersCurrentHostContent = composeProfile [
    aliasesFragment
    zoxideFragment
  ];
  
  currentUserAllHostsContent = composeProfile [
    "# User-specific configurations that apply across all hosts"
  ];
  
  currentUserCurrentHostContent = composeProfile [
    "# User and host-specific configurations"
    "# Source dotnet completions if available"
    "if (Test-Path ~/.config/powershell/fragments/dotnet.ps1) {"
    "  . ~/.config/powershell/fragments/dotnet.ps1"
    "}"
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
