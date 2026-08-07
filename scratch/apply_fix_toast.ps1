# apply_fix_toast.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)

$toastText = [System.IO.File]::ReadAllText('scratch/fix_toast_utf8.txt', $utf8).Trim()
$htmlContent = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

$targetSearch = "showToast("
$targetIdx = $htmlContent.IndexOf("showToast('", $htmlContent.IndexOf("window.addEventListener('load'"))
if ($targetIdx -ge 0) {
    $targetEnd = $htmlContent.IndexOf(");", $targetIdx) + 2
    $oldToastLine = $htmlContent.Substring($targetIdx, $targetEnd - $targetIdx)
    $htmlContent = $htmlContent.Replace($oldToastLine, $toastText)
    Write-Host "Replaced toast text cleanly!" -ForegroundColor Green
}

$finalContent = $htmlContent -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved clean index.html!" -ForegroundColor Green
