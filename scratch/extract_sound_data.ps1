# extract_sound_data.ps1
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText('index.html', $utf8NoBom)
$contentLF = $content -replace "`r`n", "`n"

# AUDIO_SAMPLES_BASE64 검색
$startMarker = "const AUDIO_SAMPLES_BASE64 = {"
$endMarker = "};"

$startIdx = $contentLF.IndexOf($startMarker)
if ($startIdx -ge 0) {
    $endIdx = $contentLF.IndexOf($endMarker, $startIdx) + $endMarker.Length
    $soundCode = $contentLF.Substring($startIdx, $endIdx - $startIdx)

    # sound_data.js로 추출 저장
    [System.IO.File]::WriteAllText('sound_data.js', $soundCode, $utf8NoBom)
    Write-Host "Created sound_data.js (len: $($soundCode.Length))" -ForegroundColor Green

    # index.html에서 해당 대용량 변수를 <script src="sound_data.js"></script>로 대체
    $replacement = "// AUDIO_SAMPLES_BASE64 is loaded from sound_data.js"
    $contentLF = $contentLF.Replace($soundCode, $replacement)

    # head 영역에 <script src="sound_data.js"></script> 추가
    $headEndIdx = $contentLF.IndexOf("</head>")
    if ($headEndIdx -ge 0) {
        $scriptTag = "    <script src=`"sound_data.js``"></script>`n"
        $contentLF = $contentLF.Insert($headEndIdx, $scriptTag)
    }

    # 기본 악보 자동 생성 logic 적용 (초기 로딩 및 resetToHome 시 4분음표 4개 채움)
    $initLogicSearch = "notes = scoreMeasures[activeMeasureIndex];"
    $initLogicIdx = $contentLF.IndexOf($initLogicSearch)
    if ($initLogicIdx -ge 0) {
        $defaultNotesCode = @"
notes = scoreMeasures[activeMeasureIndex];
                if (getAuthoredMeasureNotes(notes).length === 0) {
                    notes.splice(0, notes.length,
                        { type: 'quarter', isRest: false, beatOffset: 0, dotted: false },
                        { type: 'quarter', isRest: false, beatOffset: 1, dotted: false },
                        { type: 'quarter', isRest: false, beatOffset: 2, dotted: false },
                        { type: 'quarter', isRest: false, beatOffset: 3, dotted: false }
                    );
                }
"@
        $contentLF = $contentLF.Replace($initLogicSearch, $defaultNotesCode)
    }

    # resetToHome()도 기본 4분음표 4개 채우도록 보완
    $resetSearch = "function resetToHome() {"
    $resetIdx = $contentLF.IndexOf($resetSearch)
    if ($resetIdx -ge 0) {
        $resetEnd = $contentLF.IndexOf("switchMeasure(0);", $resetIdx) + "switchMeasure(0);".Length
        $oldReset = $contentLF.Substring($resetIdx, $resetEnd - $resetIdx)
        $newReset = @"
function resetToHome() {
            stopPerformance();
            guidedPracticeTarget = null;
            hidePracticeStatus();
            closePracticePanel();
            if (timeSignature.top !== 4 || timeSignature.bottom !== 4) {
                setTimeSig(4, 4);
            }
            switchMeasure(0);
            notes.splice(0, notes.length,
                { type: 'quarter', isRest: false, beatOffset: 0, dotted: false },
                { type: 'quarter', isRest: false, beatOffset: 1, dotted: false },
                { type: 'quarter', isRest: false, beatOffset: 2, dotted: false },
                { type: 'quarter', isRest: false, beatOffset: 3, dotted: false }
            );
            drawAll();
            showToast('🎵 처음 메인 화면으로 돌아왔습니다.', true);
        }
"@
        $contentLF = $contentLF.Replace($oldReset, $newReset)
    }

    $finalContent = $contentLF -replace "`n", "`r`n"
    [System.IO.File]::WriteAllText('index.html', $finalContent, $utf8NoBom)
    Write-Host "Updated index.html! New size: $($finalContent.Length) bytes." -ForegroundColor Green
} else {
    Write-Host "AUDIO_SAMPLES_BASE64 not found!" -ForegroundColor Red
}
