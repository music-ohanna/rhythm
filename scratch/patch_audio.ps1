$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Length -gt 10 -and $lines[$i] -match "showValidationAlert.*audio") {
        $lines[$i] = "                console.warn('Audio fallback warning');"
        $lines[$i+1] = "                // proceed saving without return"
    }
    if ($lines[$i] -match "showValidationAlert\(" -and $lines[$i+1] -match "return;") {
        # Check if line 3509
        if ($i -gt 3500 -and $i -lt 3520) {
            $lines[$i] = "                console.warn('Audio fallback warning');"
            $lines[$i+1] = "                // proceed saving without return"
        }
    }
}
[System.IO.File]::WriteAllLines($indexPath, $lines, [System.Text.Encoding]::UTF8)
Write-Host "SUCCESS_AUDIO_PATCH"
