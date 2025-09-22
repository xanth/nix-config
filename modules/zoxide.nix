# zoxide
{ pkgs, hostConfig, ... }:
let
in
{
  environment.systemPackages = with pkgs; [
    zoxide
  ];

  home-manager.users.${hostConfig.userName} = {
    # PowerShell zoxide integration fragment
    home.file.".config/powershell/fragments/zoxide.ps1".text = ''
      # Initialize zoxide for PowerShell
      if (Get-Command zoxide -ErrorAction SilentlyContinue) {
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
      }
    '';
  };
}
