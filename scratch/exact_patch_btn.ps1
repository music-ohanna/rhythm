# exact_patch_btn.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

$oldCode = @"
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

$newCode = @"
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

# Replace using string IndexOf
$idx = $content.IndexOf('id="btn-stage-practice"')
if ($idx -ge 0) {
    $btnBlockStart = $content.LastIndexOf('<button', $idx)
    $endIdx = $content.IndexOf('</button>', $content.IndexOf('id="btn-help-tutorial"')) + 9
    $oldSub = $content.Substring($btnBlockStart, $endIdx - $btnBlockStart)
    $content = $content.Replace($oldSub, $newCode.Trim())
    Write-Host "Replaced buttons using IndexOf OK!" -ForegroundColor Green
} else {
    Write-Host "ERROR: btn-stage-practice not found" -ForegroundColor Red
}

$finalContent = $content -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
