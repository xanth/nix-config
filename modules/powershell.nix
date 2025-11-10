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
      # Add nix-darwin paths to PATH (only if not already present)
      if (-not $env:PATH.Contains("/run/current-system/sw/bin")) {
        $env:PATH = "/run/current-system/sw/bin:$env:PATH"
      }

      # run all files in fragments (if directory exists)
      $fragmentsPath = Join-Path $HOME ".config/powershell/fragments"
      if (Test-Path $fragmentsPath) {
        Get-ChildItem -Path $fragmentsPath -Filter *.ps1 -ErrorAction SilentlyContinue `
          | ForEach-Object { 
            try { . $_.FullName } catch { Write-Warning "Failed to load fragment: $($_.Name)" }
          }
      }
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
    home.file.".config/powershell/Microsoft.PowerShell_profile.ps1".text =
      currentUserCurrentHostContent;
  };
}
