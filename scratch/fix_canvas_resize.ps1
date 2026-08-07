# fix_canvas_resize.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

# 1. resize() 정의 직후 즉시 1회 실행 코드 추가
$resizeSearch = "window.addEventListener('resize', resize);"
$resizeReplace = @"
        window.addEventListener('resize', resize);
        // 초기 로딩 시 즉시 캔버스 크기 계산 및 렌더링 강제 실행
        setTimeout(resize, 0);
"@

if ($content.Contains($resizeSearch)) {
    $content = $content.Replace($resizeSearch, $resizeReplace)
    Write-Host "1. Added immediate resize() trigger after declaration OK!" -ForegroundColor Green
}

# 2. DOMContentLoaded 및 load 이벤트에서 resize() 강제 호출
$loadSearch = "window.addEventListener('DOMContentLoaded', () => {"
$loadReplace = @"
        window.addEventListener('DOMContentLoaded', () => {
            resize();
            initTutorial();
            if (!notes || notes.length === 0) {
                notes = scoreMeasures[0] || [];
            }
            if (getAuthoredMeasureNotes(notes).length === 0) {
                notes.splice(0, notes.length, ...getInitialDefaultMeasureNotes());
            }
            drawAll();
        });
        window.addEventListener('load', () => {
            resize();
            setTimeout(() => {
                resize();
                if (getAuthoredMeasureNotes(notes).length === 0) {
                    notes.splice(0, notes.length, ...getInitialDefaultMeasureNotes());
                }
                drawAll();
                showToast('💡 처음이라 앱 사용방법이 궁금하면 상단 [❓ 도움말]을 눌러주세요!', true);
            }, 80);
        });
"@

$oldLoadBlockIdx = $content.IndexOf("window.addEventListener('DOMContentLoaded', () => {")
if ($oldLoadBlockIdx -ge 0) {
    $scriptEndIdx = $content.IndexOf("</script>", $oldLoadBlockIdx)
    $oldLoadChunk = $content.Substring($oldLoadBlockIdx, $scriptEndIdx - $oldLoadBlockIdx)
    $content = $content.Replace($oldLoadChunk, $loadReplace.Trim() + "`n`n    ")
    Write-Host "2. Updated DOMContentLoaded & load with resize() OK!" -ForegroundColor Green
}

$finalContent = $content -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
