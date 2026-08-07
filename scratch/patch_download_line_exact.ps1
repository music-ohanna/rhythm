$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Contains("악기 실음을 포함하지 못했습니다")) {
        $lines[$i] = "                console.warn('실음 내장 실패 시에도 계속 저장 진행');"
        $lines[$i+1] = "                // return 중단 방지"
        Write-Host "Patched exact line $($i+1)"
    }
}

[System.IO.File]::WriteAllLines($indexPath, $lines, [System.Text.Encoding]::UTF8)
Write-Host "PATCH_EXACT_COMPLETE"
