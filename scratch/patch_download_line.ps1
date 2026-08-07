$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "showValidationAlert.*악기 실음") {
        $lines[$i] = "                console.warn('실음 내장 스크립트 경고 무시 및 저장 지속');"
        if ($lines[$i+1] -match "return;") {
            $lines[$i+1] = "                // return 스크립트 제거"
        }
        Write-Host "Patched line $($i+1)"
    }
}

[System.IO.File]::WriteAllLines($indexPath, $lines, [System.Text.Encoding]::UTF8)
Write-Host "PATCH_COMPLETE"
