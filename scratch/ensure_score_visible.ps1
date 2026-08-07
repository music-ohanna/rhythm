# ensure_score_visible.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

# 1. scoreMeasures 초기화 시 1마디에 기본 4분음표 4개 넣기
$search1 = "let scoreMeasures = Array.from({length: PROJECT_MEASURE_COUNT}, () => []);"
$replace1 = @"
        function getInitialDefaultMeasureNotes() {
            return [
                { type: 'quarter', isRest: false, beatOffset: 0, dotted: false },
                { type: 'quarter', isRest: false, beatOffset: 1, dotted: false },
                { type: 'quarter', isRest: false, beatOffset: 2, dotted: false },
                { type: 'quarter', isRest: false, beatOffset: 3, dotted: false }
            ];
        }
        let scoreMeasures = Array.from({length: PROJECT_MEASURE_COUNT}, (_, i) => i === 0 ? getInitialDefaultMeasureNotes() : []);
"@

if ($content.Contains($search1)) {
    $content = $content.Replace($search1, $replace1)
    Write-Host "1. Initial scoreMeasures updated with default 4 quarter notes!" -ForegroundColor Green
} else {
    Write-Host "WARNING: search1 not found!" -ForegroundColor Red
}

# 2. window load 시 무조건 4분음표 보장 및 drawAll() 호출
$search2 = "window.addEventListener('DOMContentLoaded', initTutorial);"
$replace2 = @"
        window.addEventListener('DOMContentLoaded', () => {
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
            setTimeout(() => {
                if (getAuthoredMeasureNotes(notes).length === 0) {
                    notes.splice(0, notes.length, ...getInitialDefaultMeasureNotes());
                }
                drawAll();
            }, 50);
        });
"@

if ($content.Contains($search2)) {
    $content = $content.Replace($search2, $replace2)
    Write-Host "2. Added DOMContentLoaded and load handlers to guarantee drawAll()!" -ForegroundColor Green
} else {
    Write-Host "WARNING: search2 not found!" -ForegroundColor Red
}

$finalContent = $content -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved index.html cleanly!" -ForegroundColor Green
