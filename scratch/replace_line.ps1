# replace_line.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines('index.html', $utf8)

# Line 1306 index is 1305 (0-based)
$toastText = [System.IO.File]::ReadAllText('scratch/fix_toast_line.txt', $utf8).Trim()

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Contains("showToast") -and $i -gt 1200) {
        $lines[$i] = "                " + $toastText
        Write-Host "Replaced line $($i + 1) cleanly!" -ForegroundColor Green
    }
}

[System.IO.File]::WriteAllLines('index.html', $lines, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
