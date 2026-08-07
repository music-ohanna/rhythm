# fix_single_toast.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines('index.html', $utf8)

$toastLine = [System.IO.File]::ReadAllText('scratch/fix_toast_line.txt', $utf8).Trim()

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Contains("showToast(") -and ($lines[$i].Contains("?") -or $lines[$i].Contains("처음이라"))) {
        $lines[$i] = "                " + $toastLine
        Write-Host "Replaced toast line at line $($i + 1)" -ForegroundColor Green
        break
    }
}

[System.IO.File]::WriteAllLines('index.html', $lines, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
