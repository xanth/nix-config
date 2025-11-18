# PowerShell key bindings

$basePromptFullCommand = "Return only a single PowerShell command with no explanations, no code blocks, no markdown formatting, and no additional text. The output should be immediately executable: {0}";

$basePromptPartialCommand = "Return only a single PowerShell snippet completing the current command line with no explanations, no code blocks, no markdown formatting, and no additional text, when combined with the current command line, should be immediately executable and {0}. The current command line is: '{1}'";

function AICommandCompletion {
  # Get the current command line
  $line = $null;
  $cursor = $null;
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor);

  if ($line -eq $null -or $line -eq "") {
    return;
  }

  # Check if line contains a comment
  if (-not ($line -match '#\s*(.+)$')) {
    return;
  }
  
  $commentText = $matches[1].Trim();
  
  # Check if comment starts with ^ (include transcript)
  $includeTranscript = $false;
  if ($commentText.StartsWith('^')) {
    $includeTranscript = $true;
    $commentText = $commentText.Substring(1).Trim();
  }
  
  # Find the position of the first # character
  $commentIndex = $line.IndexOf('#');
  
  # Get the text before the comment
  $textBeforeComment = $line.Substring(0, $commentIndex);
  
  # Read transcript if requested
  $transcriptContent = "";
  if ($includeTranscript) {
    $transcript = Get-AICommandCompletionTranscript -Lines 2000;
    if ($transcript) {
      $transcriptContent = "`n`nRecent session transcript:`n```n$transcript`n```n`n";
    }
  }
  
  # Build full prompt based on whether there's existing command text
  if ([string]::IsNullOrWhiteSpace($textBeforeComment)) {
    # Just a comment - use basePromptFullCommand
    $fullPrompt = $transcriptContent + ($basePromptFullCommand -f $commentText);
  }
  else {
    # Existing command with comment - use basePromptPartialCommand
    $fullPrompt = $transcriptContent + ($basePromptPartialCommand -f $commentText, $textBeforeComment.Trim());
  }
  
  # Call cursor-agent and get response
  try {
    # Start cursor-agent as a background job
    $job = Start-Job -ScriptBlock {
      param($prompt);
      cursor-agent -p $prompt --model composer-1 -f 2>$null;
    } -ArgumentList $fullPrompt;
    
    # Show spinner at comment position while job is running
    $symbols = @("⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷");
    $i = 0;
    
    while ($job.State -eq "Running") {
      $symbol = $symbols[$i];
      
      # Get current buffer state
      $currentLine = $null;
      $currentCursor = $null;
      [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$currentLine, [ref]$currentCursor);
      
      # Replace the # with spinner but keep the comment text
      $spinnerLine = $textBeforeComment + $symbol + " " + $commentText;
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $currentLine.Length, $spinnerLine);
      
      Start-Sleep -Milliseconds 70;
      $i++
      if ($i -eq $symbols.Count) {
        $i = 0;
      }
    }
    
    # Get the result
    $response = Receive-Job -Job $job -Wait;
    Remove-Job -Job $job;
    
    if ($response) {
      # Trim all whitespace from response (newlines, spaces, tabs, etc.)
      $cleanResponse = $response.Trim()
      
      # Build new line based on whether there was text before the comment
      if ([string]::IsNullOrWhiteSpace($textBeforeComment)) {
        # Just a comment - use response directly
        $newLine = $cleanResponse;
      }
      else {
        # Existing command - concatenate with proper spacing
        $newLine = $textBeforeComment.TrimEnd() + $cleanResponse;
      }
      
      # Get current buffer state for final replace
      $currentLine = $null;
      $currentCursor = $null;
      [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$currentLine, [ref]$currentCursor);
      
      # Replace with final result
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $currentLine.Length, $newLine);
    }
    else {
      # Get current buffer state before restoring
      $currentLine = $null;
      $currentCursor = $null
      [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$currentLine, [ref]$currentCursor);
      
      # No response - restore original line with comment
      [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $currentLine.Length, $line);
      Write-Host "`nError: No response from cursor-agent" -ForegroundColor Red;
    }
  }
  catch {
    # Get current buffer state before restoring
    $currentLine = $null;
    $currentCursor = $null;
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$currentLine, [ref]$currentCursor);
    
    # Error occurred - restore original line with comment
    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(0, $currentLine.Length, $line);
    Write-Host "`nError calling cursor-agent: $_" -ForegroundColor Red;
  }
}

# Key handler: Ctrl+A, I - AI command completion from comment
# Reads current line, extracts comment after #, sends to AI, replaces line with response
Set-PSReadLineKeyHandler -Chord "Ctrl+a,i" `
                         -BriefDescription "AICommandCompletion" `
                         -LongDescription "AI-powered command completion: Extracts comment text after # and uses cursor-agent with Composer 1 model to generate PowerShell commands. Shows animated spinner while processing." `
                         -ScriptBlock { AICommandCompletion };
