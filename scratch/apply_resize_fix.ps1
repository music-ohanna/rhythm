# apply_resize_fix.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$resizeBlock = [System.IO.File]::ReadAllText('scratch/fix_resize_clean.txt', $utf8) -replace "`r`n", "`n"
$htmlContent = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

$idx = $htmlContent.IndexOf('function resize() {')
if ($idx -ge 0) {
    $endIdx = $htmlContent.IndexOf('redrawAnalog();', $idx) + 'redrawAnalog();'.Length + 10
    # find closing brace of resize
    $closeBrace = $htmlContent.IndexOf('}', $endIdx - 15) + 1
    $oldChunk = $htmlContent.Substring($idx, $closeBrace - $idx)
    $htmlContent = $htmlContent.Replace($oldChunk, $resizeBlock)
    Write-Host "Replaced resize() function cleanly!" -ForegroundColor Green
} else {
    Write-Host "ERROR: function resize() not found!" -ForegroundColor Red
}

$finalContent = $htmlContent -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved clean index.html!" -ForegroundColor Green
