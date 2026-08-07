$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

# Search for bezier, quadratic, tie-related drawing
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "bezier|quadratic|tie|slur|arc.*Math.PI" -and $lines[$i].Length -lt 300) {
        Write-Host "Line $($i+1): $($lines[$i])"
    }
}
