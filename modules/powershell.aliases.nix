# PowerShell aliases fragment
''
  # Clipboard alias
  Set-Alias -Name clip -Value Set-Clipboard
  Set-Alias -Name pbcopy -Value Set-Clipboard
  Set-Alias -Name pbpaste -Value Get-Clipboard

  # File system
  Set-Alias -Name ls -Value Get-ChildItem
  Set-Alias -Name cp -Value Copy-Item
  Set-Alias -Name mv -Value Move-Item
  Set-Alias -Name rm -Value Remove-Item
  Set-Alias -Name mkdir -Value New-Item
''
