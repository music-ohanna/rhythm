
$path = Resolve-Path "index.html"
$enc = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines($path, $enc)

$lines[2474] = "            showToast('🎉 정답이에요! 예시를 완벽히 따라했어요!', true);"

[System.IO.File]::WriteAllLines($path, $lines, $enc)
Write-Host "TOAST_UTF8_FIXED"
