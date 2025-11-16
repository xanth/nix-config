# Customized version of https://github.com/PowerShell/PSReadLine/issues/2698#issuecomment-1439942616

$defaultHistoryHandler = (Get-PSReadLineOption).AddToHistoryHandler;
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    
    Write-Debug "AddToHistoryHandler: $line";
    $defaultHandlerResult = $defaultHistoryHandler.Invoke($line)

    Write-Debug "DefaultHandlerResult: $defaultHandlerResult";

    # Early exit if the line is null or empty or 2 chars or less
    if ($line -eq $null -or $line -eq "" -or $line.Length -le 2)
    {
        Write-Debug "Early exit: $line";
        return $defaultHandlerResult;
    }

    # Early exit if history retention has already been suppressed
    if ($defaultHandlerResult -ne "MemoryAndFile")
    {
        Write-Debug "History retention has already been suppressed: $defaultHandlerResult";
        return $defaultHandlerResult;
    }
    
    # SkipAdding lines that start with double ;;
    if ($line.StartsWith(";;"))
    {
        Write-Debug "SkipAdding: $line";
        return "SkipAdding";
    }
    # MemoryOnly lines that start with single ;
    elseif ($line.StartsWith(";"))
    {
        Write-Debug "MemoryOnly: $line";
        return "MemoryOnly";
    }
    
    Write-Debug "Returning default handler result: $defaultHandlerResult";
    return $defaultHandlerResult;    
}
