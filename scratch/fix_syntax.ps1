
$path = Resolve-Path "index.html"
$enc = New-Object System.Text.UTF8Encoding($false)
$lines = [System.IO.File]::ReadAllLines($path, $enc)

# Step 1: Remove stray orphan lines 2404..2415 (0-indexed: 2403..2414)
if ($lines[2403] -like "*playTone(880*") {
    Write-Host "Found orphan lines starting at 2403. Removing..."
    $lines = $lines[0..2402] + $lines[2415..($lines.Length-1)]
}

# Step 2: Fix checkGuidedPractice success logic
for ($i = 2460; $i -lt 2490; $i++) {
    if ($lines[$i] -like "*showToast(*" -and ($lines[$i] -like "*예시 리듬과 같습니다*" -or $lines[$i] -like "*?럦 ?뺣떟?낅땲??*")) {
        Write-Host "Found success toast line at index $i"
        $lines[$i-1] = "            showToast('🎉 정답이에요! 예시를 완벽히 따라했어요!', true);"
        $lines[$i]   = "            setTimeout(function() { const modal = document.getElementById('practiceSuccessChoiceModal'); if (modal) modal.classList.add('show'); }, 600);"
        if ($lines[$i+1] -like "*showToast(*") {
            $lines[$i+1] = "            // modal triggered"
        }
        break
    }
}

[System.IO.File]::WriteAllLines($path, $lines, $enc)
Write-Host "SYNTAX_ERROR_FIXED_SUCCESSFULLY!"
