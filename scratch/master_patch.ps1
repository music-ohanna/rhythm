# master_patch.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)

Write-Host "[1/4] Running apply_new_patch..." -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File "scratch/apply_new_patch.ps1"

Write-Host "[2/4] Running split_sound..." -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File "scratch/split_sound.ps1"

Write-Host "[3/4] Running ensure_score_visible..." -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File "scratch/ensure_score_visible.ps1"

Write-Host "[4/4] Updating button styles and text..." -ForegroundColor Cyan
$htmlContent = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

# Fix btn-stage-practice & btn-help-tutorial
$oldBtnPart = '<button id="btn-stage-practice"'
$idxPrac = $htmlContent.IndexOf($oldBtnPart)
if ($idxPrac -ge 0) {
    $btnEnd = $htmlContent.IndexOf('</button>', $htmlContent.IndexOf('id="btn-help-tutorial"')) + 9
    $oldChunk = $htmlContent.Substring($idxPrac, $btnEnd - $idxPrac)

    $newChunk = @"
<button id="btn-stage-practice" onclick="showPracticeExample()" class="text-tool-btn text-xs md:text-sm bg-amber-100 hover:bg-amber-200 text-amber-950 font-black border-2 border-amber-500 shadow-sm" title="4/4박자 예시 리듬 따라 만들기">
                    <span class="text-base">🎯</span> 예시 따라하기
                </button>
                <button id="btn-header-save" onclick="downloadPlayableScoreHtml()" class="text-tool-btn btn-save-score text-xs md:text-sm" title="만든 악보 파일로 저장하기">
                    <span class="text-base">📥</span> 악보 저장
                </button>
                <button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm font-black text-blue-900 border-2 border-blue-400 bg-blue-50 hover:bg-blue-100" title="앱 사용법 팝업 가이드 보기">
                    <span class="text-base">❓</span> 도움말
                </button>
"@
    $htmlContent = $htmlContent.Replace($oldChunk, $newChunk)
    Write-Host "Updated button colors and [❓ 도움말] label OK!" -ForegroundColor Green
}

# Add initial help toast
$loadSearch = "window.addEventListener('load', () => {"
$loadIdx = $htmlContent.IndexOf($loadSearch)
if ($loadIdx -ge 0) {
    $toastNotice = "window.addEventListener('load', () => {`n            setTimeout(() => { showToast('💡 처음이라 앱 사용방법이 궁금하면 상단 [❓ 도움말]을 눌러주세요!', true); }, 1200);`n"
    $htmlContent = $htmlContent.Replace($loadSearch, $toastNotice)
    Write-Host "Added initial help notice toast!" -ForegroundColor Green
}

$finalContent = $htmlContent -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "MASTER PATCH COMPLETED SUCCESSFULLY!" -ForegroundColor Green
