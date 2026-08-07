# fix_toast_unicode.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)

$toastLine = [System.IO.File]::ReadAllText('scratch/fix_toast_line.txt', $utf8).Trim()
$htmlContent = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

$idx = $htmlContent.IndexOf("showToast('?")
if ($idx -lt 0) { $idx = $htmlContent.IndexOf("showToast('") }
# Find the one inside window.addEventListener('load'
$loadIdx = $htmlContent.IndexOf("window.addEventListener('load'")
$targetIdx = $htmlContent.IndexOf("showToast(", $loadIdx)

if ($targetIdx -ge 0) {
    $targetEnd = $htmlContent.IndexOf(");", $targetIdx) + 2
    $oldLine = $htmlContent.Substring($targetIdx, $targetEnd - $targetIdx)
    $htmlContent = $htmlContent.Replace($oldLine, $toastLine)
    Write-Host "Replaced toast line successfully!" -ForegroundColor Green
}

$finalContent = $htmlContent -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
