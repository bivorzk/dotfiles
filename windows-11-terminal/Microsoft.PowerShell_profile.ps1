function prompt {
    $path = $executionContext.SessionState.Path.CurrentLocation.Path
    $home_ = [System.Environment]::GetFolderPath('UserProfile')
    if ($path -eq $home_) {
        $path = "~"
    } elseif ($path.StartsWith($home_ + [System.IO.Path]::DirectorySeparatorChar)) {
        $path = "~" + $path.Substring($home_.Length)
    }

    Write-Host ([char]0xF07C) -NoNewline -ForegroundColor Cyan
    Write-Host " $path " -NoNewline -ForegroundColor Cyan
    Write-Host ([char]0x03BB) -NoNewline -ForegroundColor White
    return " "
}

Set-Alias -Name terminal -Value wezterm.exe
Set-Alias -Name cmd -Value wezterm.exe -Force

Import-Module Terminal-Icons

# built-in ls alias would shadow the function below
Remove-Item Alias:ls -Force -ErrorAction SilentlyContinue
function ls {
    $esc = [char]27
    $items = Get-ChildItem @args | Sort-Object { -not $_.PSIsContainer }, Name
    if (-not $items) { return }

    $cells = foreach ($item in $items) {
        $text = $item | Format-TerminalIcons
        [pscustomobject]@{
            Text  = $text
            Width = ($text -replace "$esc\[[0-9;]*m", '').Length
        }
    }

    $gap = 2
    $maxWidth = ($cells.Width | Measure-Object -Maximum).Maximum
    $consoleWidth = $Host.UI.RawUI.WindowSize.Width
    $columns = [Math]::Max(1, [Math]::Floor($consoleWidth / ($maxWidth + $gap)))
    $rows = [Math]::Ceiling($cells.Count / $columns)

    for ($r = 0; $r -lt $rows; $r++) {
        for ($c = 0; $c -lt $columns; $c++) {
            $i = $r + $c * $rows
            if ($i -ge $cells.Count) { continue }
            $cell = $cells[$i]
            Write-Host $cell.Text -NoNewline
            if (($i + $rows) -lt $cells.Count) {
                Write-Host (" " * ($maxWidth - $cell.Width + $gap)) -NoNewline
            }
        }
        Write-Host ""
    }
}

function touch {
    param([Parameter(Mandatory, ValueFromRemainingArguments)] [string[]] $Path)
    foreach ($p in $Path) {
        if (Test-Path $p) {
            (Get-Item $p).LastWriteTime = Get-Date
        } else {
            New-Item -ItemType File -Path $p | Out-Null
        }
    }
}
