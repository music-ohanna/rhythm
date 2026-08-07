# apply_clean_header.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)

$btnBlock = [System.IO.File]::ReadAllText('scratch/fix_btn_utf8.txt', $utf8) -replace "`r`n", "`n"
$htmlContent = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

$oldBtnPart = '<button id="btn-stage-practice"'
$idxPrac = $htmlContent.IndexOf($oldBtnPart)
if ($idxPrac -ge 0) {
    $btnEnd = $htmlContent.IndexOf('</button>', $htmlContent.IndexOf('id="btn-help-tutorial"')) + 9
    $oldChunk = $htmlContent.Substring($idxPrac, $btnEnd - $idxPrac)
    $htmlContent = $htmlContent.Replace($oldChunk, $btnBlock)
    Write-Host "Replaced buttons using fix_btn_utf8.txt cleanly!" -ForegroundColor Green
} else {
    Write-Host "ERROR: btn-stage-practice not found" -ForegroundColor Red
}

$finalContent = $htmlContent -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved clean index.html!" -ForegroundColor Green
