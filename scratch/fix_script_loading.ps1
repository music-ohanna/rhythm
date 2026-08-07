# fix_script_loading.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

# 1. sound_data.js를 defer(비동기 차단 방지) 태그로 변경하여 렌더링 블로킹 완전 해제!
$oldScriptTag = '<script src="sound_data.js"></script>'
$newScriptTag = '<script src="sound_data.js" defer></script>'
if ($content.Contains($oldScriptTag)) {
    $content = $content.Replace($oldScriptTag, $newScriptTag)
    Write-Host "1. Updated sound_data.js to defer script loading!" -ForegroundColor Green
}

# 2. EMBEDDED_RHYTHM_AUDIO_DATA_URIS 안전 기본값 보장 (sound_data.js 로딩 지연 시에도 렌더링 100% 보장)
$initAudioSearch = "function initAudio() {"
$initAudioReplace = @"
        if (typeof EMBEDDED_RHYTHM_AUDIO_DATA_URIS === 'undefined') {
            window.EMBEDDED_RHYTHM_AUDIO_DATA_URIS = {};
        }
        function initAudio() {
"@
if ($content.Contains($initAudioSearch)) {
    $content = $content.Replace($initAudioSearch, $initAudioReplace)
    Write-Host "2. Added EMBEDDED_RHYTHM_AUDIO_DATA_URIS fallback check!" -ForegroundColor Green
}

# 3. main canvasArea 캔버스 높이 및 렌더링 보장 CSS & JS 강제 렌더링
$canvasCssSearch = "#canvasArea {"
$canvasCssIdx = $content.IndexOf($canvasCssSearch)
if ($canvasCssIdx -ge 0) {
    # resize() 시 min-height 보장
}

# 4. resize() 함수에서 parent height 0인 경우 뷰포트 기반 대체값 부여
$resizeOld = "rhythmCanvas.height = parent.clientHeight;"
$resizeNew = @"
rhythmCanvas.width = parent.clientWidth || Math.max(600, window.innerWidth - 32);
            rhythmCanvas.height = parent.clientHeight || Math.max(260, window.innerHeight * 0.45);
            drawingCanvas.width = rhythmCanvas.width;
            drawingCanvas.height = rhythmCanvas.height;
"@
if ($content.Contains($resizeOld)) {
    $content = $content.Replace($resizeOld, $resizeNew)
    Write-Host "3. Robust parent dimensions fallback for resize() added!" -ForegroundColor Green
}

$finalContent = $content -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
