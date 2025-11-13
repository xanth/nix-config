# .NET module - .NET SDK installation and configuration
{ pkgs, hostConfig, ... }:
{
  environment.systemPackages = with pkgs; [
    # .NET SDKs combined for completions
    dotnetCorePackages.sdk_10_0
  ];

  home-manager.users.${hostConfig.userName} = {
    # .NET CLI completions for PowerShell
    home.file.".config/powershell/fragments/dotnet.ps1".text = ''
      # Enable .NET CLI completions
      Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
          [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
      }
    '';
  };
}
