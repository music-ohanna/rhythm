# fix_line_1306.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines('index.html', $utf8)

$toastLine = [System.IO.File]::ReadAllText('scratch/fix_toast_line.txt', $utf8).Trim()
$lines[1305] = "                " + $toastLine

[System.IO.File]::WriteAllLines('index.html', $lines, $utf8)
Write-Host "Replaced line 1306 directly!" -ForegroundColor Green
