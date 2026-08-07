
$p = Join-Path (Get-Location) "index.html"
$lines = [System.IO.File]::ReadAllLines($p)

Write-Host "Total lines:" $lines.Length
for ($i=4970; $i -lt 5010; $i++) {
    if ($lines[$i] -like "*title:*") {
        Write-Host "Line $i:" $lines[$i]
    }
}
