$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

$newList = [System.Collections.Generic.List[string]]::new()
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($i -gt 2410 -and $i -lt 2420 -and $lines[$i].Trim() -eq "}" -and $lines[$i+1].Trim() -eq "}") {
        # Skip duplicate closing brackets
        continue
    }
    $newList.Add($lines[$i])
}

[System.IO.File]::WriteAllLines($indexPath, $newList.ToArray(), [System.Text.Encoding]::UTF8)
Write-Host "CLEAN_BRACKETS_SUCCESS"
