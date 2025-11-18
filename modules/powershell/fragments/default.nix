# PowerShell fragments - automatically exports all .ps1 files
# Returns an attribute set mapping fragment names to their source paths
{
  "aliases.ps1" = ./aliases.ps1;
  "AICommandCompletion-Transcript.ps1" = ./AICommandCompletion-Transcript.ps1;
  "PSReadLineKeyHandler-AICommandCompletion.ps1" = ./PSReadLineKeyHandler-AICommandCompletion.ps1;
  "PSReadLineOption-RetentionSuppressionHistoryHandler.ps1" =
    ./PSReadLineOption-RetentionSuppressionHistoryHandler.ps1;
}
