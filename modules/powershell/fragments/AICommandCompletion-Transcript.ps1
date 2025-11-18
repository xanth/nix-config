# AICommandCompletion Transcript Management
# Manages transcripts for AI command completion with session isolation and cleanup

# Script-scoped variables
$script:Transcript = $null
$script:TranscriptSuspended = $false
$script:TranscriptActive = $false

function AICommandCompletionTranscript-Name {
    param([int]$SessionId)
    
    $unixTimeMs = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $tempDir = [System.IO.Path]::GetTempPath().TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    
    $name = "AICommandCompletion_Transcript_${unixTimeMs}_${SessionId}"
    
    return @{
        Path = Join-Path $tempDir "${name}"
        Name = $name
    }
}

function Start-AICommandCompletionTranscript {
    if ($script:TranscriptActive) {
        Write-Debug "Transcript already active"
        return
    }
    
    $maxAttempts = 100
    
    for ($sessionId = 0; $sessionId -lt $maxAttempts; $sessionId++) {
        $names = AICommandCompletionTranscript-Name -SessionId $sessionId
        
        try {
            # Use -NoClobber to ensure we don't overwrite existing files
            Start-Transcript -Path $names.Path -UseMinimalHeader -NoClobber -ErrorAction Stop
            
            # Successfully started transcript
            $script:Transcript = $names
            $script:TranscriptActive = $true
            $script:TranscriptSuspended = $false
            Write-Debug "Transcript started: $($names.Path)"
            return
        }
        catch {
            # File likely exists, try next session ID
            Write-Debug "SessionId $sessionId already in use, trying next..."
            continue
        }
    }
    
    Write-Warning "Failed to create transcript after $maxAttempts attempts"
}

function Register-AICommandCompletionTranscript {
    # Register delayed start (after profile loads)
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        Start-AICommandCompletionTranscript
    } | Out-Null
    
    # Register exit handler
    Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
        Stop-AICommandCompletionTranscript
    } | Out-Null
    
    Write-Debug "AICommandCompletion transcript system initialized"
}

function Stop-AICommandCompletionTranscript {
    if ($script:TranscriptActive) {
        try {
            Stop-Transcript -ErrorAction SilentlyContinue
            $script:TranscriptActive = $false
        }
        catch {
            # Silently ignore if transcript wasn't running
        }
    }
    
    # Clean up transcript file
    if ($script:Transcript.Path -and (Test-Path $script:Transcript.Path)) {
        try {
            Remove-Item $script:Transcript.Path -Force -ErrorAction SilentlyContinue
        }
        catch {
            Write-Debug "Could not remove transcript file: $_"
        }
    }
    
    Write-Debug "Transcript stopped and cleaned up"
}

function Suspend-AICommandCompletionTranscript {
    if ($script:TranscriptActive -and -not $script:TranscriptSuspended) {
        try {
            Stop-Transcript -ErrorAction SilentlyContinue
            $script:TranscriptSuspended = $true
            Write-Debug "Transcript suspended"
        }
        catch {
            # Silently ignore errors
            Write-Debug "Error suspending transcript: $_"
        }
    }
}

function Resume-AICommandCompletionTranscript {
    if ($script:TranscriptSuspended -and $script:Transcript.Path) {
        try {
            Start-Transcript -Path $script:Transcript.Path -UseMinimalHeader -Append -ErrorAction Stop
            $script:TranscriptSuspended = $false
            Write-Debug "Transcript resumed"
        }
        catch {
            Write-Debug "Error resuming transcript: $_"
        }
    }
}

function Get-AICommandCompletionTranscript {
    param(
        [int]$Lines = 0
    )
    
    if (-not $script:Transcript.Path -or -not (Test-Path $script:Transcript.Path)) {
        Write-Debug "Transcript file not available"
        return ""
    }
    
    try {
        if ($Lines -gt 0) {
            # Get last N lines
            $content = Get-Content -Path $script:Transcript.Path -Tail $Lines -ErrorAction SilentlyContinue
            if ($content) {
                return ($content -join "`n")
            }
        }
        else {
            # Get all content
            $content = Get-Content -Path $script:Transcript.Path -Raw -ErrorAction SilentlyContinue
            return $content
        }
    }
    catch {
        Write-Debug "Could not read transcript: $_"
        return ""
    }
    
    return ""
}

function Get-AICommandCompletionTranscriptStatus {
    [PSCustomObject]@{
        Active = $script:TranscriptActive
        Suspended = $script:TranscriptSuspended
        TranscriptPath = $script:Transcript.Path
        TranscriptName = $script:Transcript.Name
        TranscriptExists = if ($script:Transcript.Path) { Test-Path $script:Transcript.Path } else { $false }
    }
}

function Cleanup-OrphanedTranscripts {
    $tempDir = [System.IO.Path]::GetTempPath().TrimEnd([System.IO.Path]::DirectorySeparatorChar)
    $pattern = "AICommandCompletion_Transcript_*_*"
    
    try {
        $files = Get-ChildItem -Path $tempDir -Filter $pattern -ErrorAction SilentlyContinue
        
        foreach ($file in $files) {
            # Check if file is old (more than 1 day) or from a dead process
            $fileAge = (Get-Date) - $file.LastWriteTime
            
            if ($fileAge.TotalHours -gt 24) {
                try {
                    Remove-Item $file.FullName -Force -ErrorAction Stop
                    Write-Debug "Cleaned up old transcript: $($file.Name) (age: $($fileAge.TotalHours) hours)"
                }
                catch {
                    Write-Debug "Could not remove old file: $($file.Name) - $_"
                }
            }
        }
    }
    catch {
        Write-Debug "Error during orphaned transcript cleanup: $_"
    }
}

# Initialize transcript system
Register-AICommandCompletionTranscript

# Schedule cleanup task (runs once after profile loads)
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    Cleanup-OrphanedTranscripts
} | Out-Null

