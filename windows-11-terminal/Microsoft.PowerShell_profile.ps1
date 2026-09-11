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
