# patch_help_button.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

# 1. btn-stage-practice 및 btn-help-tutorial 헤더 버튼 수정
$oldBtns = @"
                <button id="btn-stage-practice" onclick="showPracticeExample()" class="text-tool-btn text-xs md:text-sm bg-amber-500 hover:bg-amber-600 text-white font-extrabold border-amber-600 shadow" title="4/4박자 예시 리듬 따라 만들기">
                    <span class="text-base">🎯</span> 예시 따라하기
                </button>
                <button id="btn-header-save" onclick="downloadPlayableScoreHtml()" class="text-tool-btn btn-save-score text-xs md:text-sm" title="만든 악보 파일로 저장하기">
                    <span class="text-base">📥</span> 악보 저장
                </button>
                <button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm" title="투어 가이드 다시 보기">
                    <span class="text-base">📖</span> 가이드
                </button>
"@

$newBtns = @"
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

if ($content.Contains($oldBtns)) {
    $content = $content.Replace($oldBtns, $newBtns)
    Write-Host "1. Updated header buttons OK" -ForegroundColor Green
} else {
    Write-Host "WARNING: oldBtns not found!" -ForegroundColor Red
}

# 2. 첫 진입 안내 토스트 추가
$searchLoad = "showTutorial(true);"
$searchLoadTarget = "window.addEventListener('load', () => {"
$idxLoad = $content.IndexOf($searchLoadTarget)
if ($idxLoad -ge 0) {
    $toastNotice = "window.addEventListener('load', () => {`n            setTimeout(() => { showToast('💡 처음이라 앱 사용방법이 궁금하면 상단 [❓ 도움말]을 눌러주세요!', true); }, 1200);`n"
    $content = $content.Replace($searchLoadTarget, $toastNotice)
    Write-Host "2. Added first-time help notice toast!" -ForegroundColor Green
}

# 3. 튜토리얼 단계에서 "도움말" 텍스트 업데이트
$content = $content.Replace("상단의 <strong>[🎯 예시 따라하기]</strong>", "상단의 <strong>[🎯 예시 따라하기]</strong>")
$content = $content.Replace("투어 가이드를 마쳤습니다.", "도움말 가이드를 마쳤습니다.")

$finalContent = $content -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
