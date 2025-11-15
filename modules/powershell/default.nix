# PowerShell module - PowerShell installation and configuration
{ pkgs, hostConfig, ... }:
let
  # Import PowerShell fragments
  psFragments = import ./fragments;

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
  ];
in
{
  environment.systemPackages = with pkgs; [
    powershell
  ];

  home-manager.users.${hostConfig.userName} = {
    # Copy PowerShell fragments dynamically
    home.file = pkgs.lib.mkMerge [
      # Map all fragments to their destination paths
      (pkgs.lib.mapAttrs' (
        name: source: pkgs.lib.nameValuePair ".config/powershell/fragments/${name}" { inherit source; }
      ) psFragments)

      # Profile files
      {
        ".config/powershell/profile.ps1".text = currentUserAllHostsContent;
        ".config/powershell/Microsoft.PowerShell_profile.ps1".text = currentUserCurrentHostContent;
      }
    ];
  };
}
