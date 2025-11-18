# Customized version of https://github.com/PowerShell/PSReadLine/issues/2698#issuecomment-1439942616

# Helper function to pause transcript for sensitive commands
function Invoke-PauseTranscript {
    Write-Debug "Invoking Suspend-AICommandCompletionTranscript";
    try {
        Suspend-AICommandCompletionTranscript
    }
    catch {
        Write-Debug "Error suspending transcript: $_"
    }
}

# Helper function to resume transcript after sensitive commands
function Invoke-ResumeTranscript {
    Write-Debug "Invoking Resume-AICommandCompletionTranscript";
    try {
        Resume-AICommandCompletionTranscript
    }
    catch {
        Write-Debug "Error resuming transcript: $_"
    }
}

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
        Invoke-PauseTranscript
        return $defaultHandlerResult;
    }
    
    # SkipAdding lines that start with double ;;
    if ($line.StartsWith(";;"))
    {
        Write-Debug "SkipAdding: $line";
        Invoke-PauseTranscript
        return "SkipAdding";
    }
    # MemoryOnly lines that start with single ;
    elseif ($line.StartsWith(";"))
    {
        Write-Debug "MemoryOnly: $line";
        Invoke-PauseTranscript
        return "MemoryOnly";
    }
    
    Write-Debug "Returning default handler result: $defaultHandlerResult";
    Invoke-ResumeTranscript
    return $defaultHandlerResult;    
}
