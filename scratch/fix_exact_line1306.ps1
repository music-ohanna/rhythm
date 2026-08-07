# fix_exact_line1306.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines('index.html', $utf8)

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Contains("showToast") -and $lines[$i].Contains("처음이라")) {
        # Already good
    } elseif ($lines[$i].Contains("showToast") -and ($lines[$i].Contains("?뮕") -or $lines[$i].Contains("?????"))) {
        $lines[$i] = "                showToast('💡 처음이라 앱 사용방법이 궁금하면 상단 [❓ 도움말]을 눌러주세요!', true);"
        Write-Host "Fixed corrupted toast at line $($i + 1)" -ForegroundColor Green
    }
}

[System.IO.File]::WriteAllLines('index.html', $lines, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
