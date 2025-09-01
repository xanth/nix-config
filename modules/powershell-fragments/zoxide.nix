# PowerShell zoxide integration fragment
''
# Initialize zoxide for PowerShell
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  Invoke-Expression (& { (zoxide init powershell | Out-String) })
}
''
