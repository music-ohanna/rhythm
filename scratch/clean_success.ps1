
$path = Resolve-Path "index.html"
$enc = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines($path, $enc)

for ($i = 2465; $i -lt 2480; $i++) {
    if ($lines[$i] -like "*startIndependentCreation();*") {
        Write-Host "Found startIndependentCreation at line index $i"
        $lines[$i]   = "            // modal will handle transition"
        $lines[$i+1] = "            showToast('🎉 정답이에요! 예시를 완벽히 따라했어요!', true);"
        $lines[$i+2] = "            setTimeout(function() { const modal = document.getElementById('practiceSuccessChoiceModal'); if (modal) modal.classList.add('show'); }, 600);"
        break
    }
}

[System.IO.File]::WriteAllLines($path, $lines, $enc)
Write-Host "SUCCESS_BLOCK_CLEANED!"
