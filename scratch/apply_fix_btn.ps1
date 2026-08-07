# apply_fix_btn.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$btnContent = [System.IO.File]::ReadAllText('scratch/fix_btn_utf8.txt', $utf8) -replace "`r`n", "`n"
$htmlContent = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

$idx = $htmlContent.IndexOf('id="btn-stage-practice"')
if ($idx -ge 0) {
    $btnBlockStart = $htmlContent.LastIndexOf('<button', $idx)
    $endIdx = $htmlContent.IndexOf('</button>', $htmlContent.IndexOf('id="btn-help-tutorial"')) + 9
    $oldSub = $htmlContent.Substring($btnBlockStart, $endIdx - $btnBlockStart)
    $htmlContent = $htmlContent.Replace($oldSub, $btnContent)
    Write-Host "Replaced buttons cleanly from fix_btn_utf8.txt!" -ForegroundColor Green
} else {
    Write-Host "ERROR: btn-stage-practice not found" -ForegroundColor Red
}

# Add initial toast notice
$searchLoadTarget = "window.addEventListener('load', () => {"
$idxLoad = $htmlContent.IndexOf($searchLoadTarget)
if ($idxLoad -ge 0) {
    $toastNotice = "window.addEventListener('load', () => {`n            setTimeout(() => { showToast('💡 처음이라 앱 사용방법이 궁금하면 상단 [❓ 도움말]을 눌러주세요!', true); }, 1200);`n"
    $htmlContent = $htmlContent.Replace($searchLoadTarget, $toastNotice)
    Write-Host "Added first-time help notice toast!" -ForegroundColor Green
}

$finalContent = $htmlContent -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
