# patch_base64.ps1
$FilePath = "index.html"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText($FilePath, $utf8)
$contentLF = $content -replace "`r`n", "`n"

function FromB64([string]$b64) {
    $bytes = [System.Convert]::FromBase64String($b64)
    return [System.Text.Encoding]::UTF8.GetString($bytes)
}

# Base64 strings for new blocks

# 1. newSteps
# Base64 for tutorialSteps replacement
$b64Steps = "Y29uc3QgdHV0b3JpYWxTdGVwcyA9IFsKICAgICAgICAgICAgewogICAgICAgICAgICAgICAgdGl0bGU6ICcxZGFuZ2llOiBub3RlJywKICAgICAgICAgICAgICAgIGJvZHk6ICdhcmFlIHB5bycsCiAgICAgICAgICAgICAgICBhbmNob3I6ICdub3RlUmVzdEJ1dHRvbnMnLAogICAgICAgICAgICAgICAgcGxhY2VtZW50OiAndG9wJwogICAgICAgICAgICB9CiAgICAgICAgXTs="

# Let's write the exact text using PowerShell [char[]] array or UTF8 byte arrays directly!

# Byte arrays for Korean strings:
$b64StepsText = @"
const tutorialSteps = [
            {
                title: '1단계: 음표 넣기',
                body: '아래 표에서 <strong>4분음표</strong>, <strong>8분음표</strong> 등 음표를 눌러 악보에 넣어요.<br><small>음표 = 소리가 나는 기호예요.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '2단계: 쉼표 넣기',
                body: '쉼표 줄의 <strong>4분쉼표</strong>, <strong>8분쉼표</strong>를 눌러 조용한 박을 만들어요.<br><small>쉼표 = 소리 없이 쉬는 기호예요.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '3단계: 점( . ) 붙이기',
                body: '음표나 쉼표를 넣은 다음 <strong>[ . ] (점)</strong> 버튼을 눌러보세요.<br>점을 붙이면 그 기호의 길이가 1.5배 늘어나요!',
                anchor: 'dotButton',
                placement: 'top'
            },
            {
                title: '4단계: 붙임줄 연결하기',
                body: '음표를 늘려 연결하고 싶다면 <strong>[⌒ 붙임줄]</strong> 버튼을 눌러요.<br>눌러 활성화한 뒤 <strong>앞 음표 → 뒤 음표 순서</strong>로 차례로 클릭하세요.',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '5단계: 내 리듬 들어보기',
                body: '표를 채웠으면 <strong>[▶ 이 마디 듣기]</strong> 버튼을 눌러 내 리듬을 들어봐요!<br><small>반복 재생되니 마음에 들면 설정에서 멈출 수 있어요.</small>',
                anchor: 'play',
                placement: 'top'
            },
            {
                title: '6단계: 되돌리기·지우기',
                body: '잘못 입력했을 때는 <strong>↩️ 되돌리기</strong> 또는 <strong>🗑️ 지우기</strong>를 눌러요.',
                anchor: 'undoClear',
                placement: 'bottom'
            },
            {
                title: '예시 따라 만들기 도전!',
                body: '투어를 마쳤어요 🎉<br>이제 <strong>[🎯 예시 따라하기]</strong> 버튼으로 선생님이 준비한 4/4박자 리듬을 따라 만들어 보세요!',
                anchor: 'practice',
                placement: 'bottom'
            }
        ];
"@

$b64GuideBtnText = @"
<button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm" title="투어 가이드 다시 보기">
                    <span class="text-base">📖</span> 가이드
                </button>
"@

$b64TieCurveText = @"
function drawTieCurve(fromNote, toNote, staffY, color = '#0f172a', alpha = 1) {
            if (!fromNote || !toNote) return;
            const fromX = fromNote.x + 10.5;
            const toX = toNote.x - 10.5;
            if (toX <= fromX + 4) return;

            const y = staffY + 12;
            const width = toX - fromX;
            // 더 볼록하고 깊게 (최소 24px, 너비 비례 0.32, 최대 52px)
            const depth = Math.max(24, Math.min(52, width * 0.32));

            rhythmCtx.save();
            rhythmCtx.strokeStyle = color;
            rhythmCtx.globalAlpha = alpha;
            rhythmCtx.lineWidth = 3.2;
            rhythmCtx.lineCap = 'round';
            rhythmCtx.lineJoin = 'round';

            // 베지어 곡선으로 풍성하게 곡률 형성
            rhythmCtx.beginPath();
            rhythmCtx.moveTo(fromX, y);
            rhythmCtx.bezierCurveTo(
                fromX + width * 0.22, y + depth,
                toX - width * 0.22, y + depth,
                toX, y
            );
            rhythmCtx.stroke();

            // 이중 선 효과로 음악적 붙임줄 미감 증대
            rhythmCtx.lineWidth = 1.8;
            rhythmCtx.globalAlpha = alpha * 0.7;
            rhythmCtx.beginPath();
            rhythmCtx.moveTo(fromX + 2, y + 1.5);
            rhythmCtx.bezierCurveTo(
                fromX + width * 0.24, y + depth * 0.88,
                toX - width * 0.24, y + depth * 0.88,
                toX - 2, y + 1.5
            );
            rhythmCtx.stroke();

            rhythmCtx.restore();
        }

"@

$b64TempoText = @"
let _tempoRestartTimer = null;
        function setTempo(value) {
            tempo = Math.max(40, Math.min(160, Number(value) || 60));
            const tempoValue = document.getElementById('tempoValue');
            if (tempoValue) tempoValue.textContent = `♩ = \${tempo}`;
            updatePlayButtonLabel();
            if (isPlaying && !isProjectPlaying) {
                clearTimeout(_tempoRestartTimer);
                _tempoRestartTimer = setTimeout(async () => {
                    if (isPlaying && !isProjectPlaying) {
                        stopPerformance();
                        await startPerformance();
                    }
                }, 200);
            }
        }

"@

$b64PracticeText = @"
// 사진 속 4/4박자 예시 리듬: 4분음표 · 점8분음표+16분음표 · 셋잇단 3개 · 8분음표+8분쉼표
        function getFourFourPracticeExample() {
            return [
                { type: 'quarter',   isRest: false, beatOffset: 0,           dotted: false },
                { type: 'eighth',    isRest: false, beatOffset: 1,           dotted: true  },
                { type: 'sixteenth', isRest: false, beatOffset: 1.75,        dotted: false },
                { type: 'triplet',   isRest: false, beatOffset: 2,           dotted: false },
                { type: 'triplet',   isRest: false, beatOffset: 2 + 1/3,     dotted: false },
                { type: 'triplet',   isRest: false, beatOffset: 2 + 2/3,     dotted: false },
                { type: 'eighth',    isRest: false, beatOffset: 3,           dotted: false },
                { type: 'eighth',    isRest: true,  beatOffset: 3.5,         dotted: false }
            ];
        }

        async function showPracticeExample() {
            stopPerformance();
            if (timeSignature.top !== 4 || timeSignature.bottom !== 4) {
                showToast('⚠️ 예시 창작은 4/4박자를 기준으로 합니다. 4/4박자로 자동 전환합니다!', true);
                await new Promise(r => setTimeout(r, 800));
                setTimeSig(4, 4);
                await new Promise(r => setTimeout(r, 100));
            } else {
                showToast('📌 예시 창작은 4/4박자를 기준으로 안내됩니다.', true);
                await new Promise(r => setTimeout(r, 500));
            }
            pushUndoState();
            const example = getFourFourPracticeExample();
            notes.splice(0, notes.length, ...example.map(note => ({...note})));
            guidedPracticeTarget = example.map(note => ({...note}));
            dotCandidateNote = null;
            syncActiveMeasureState();
            closePracticePanel();
            showPracticeStatus('example');
            drawAll();
            showToast('예시: 4분음표 · 점8분음표+16분음표 · 셋잇단 3개 · 8분음표+8분쉼표', true);
            await startPerformance();
        }

"@

# Convert to Base64 in script generator
$b64Steps = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($b64StepsText))
$b64GuideBtn = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($b64GuideBtnText))
$b64TieCurve = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($b64TieCurveText))
$b64Tempo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($b64TempoText))
$b64Practice = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($b64PracticeText))

# Now build the pure base64 patch script
$patchScript = @"
`$FilePath = "index.html"
`$utf8 = New-Object System.Text.UTF8Encoding(`$false)
`$content = [System.IO.File]::ReadAllText(`$FilePath, `$utf8)
`$contentLF = `$content -replace "`r`n", "`n"

function FromB64([string]`$b64) {
    `$bytes = [System.Convert]::FromBase64String(`$b64)
    return [System.Text.Encoding]::UTF8.GetString(`$bytes)
}

# 1. tutorialSteps
`$stepSearch = "const tutorialSteps = ["
`$stepIdx = `$contentLF.IndexOf(`$stepSearch)
if (`$stepIdx -ge 0) {
    `$stepEndIdx = `$contentLF.IndexOf("];", `$stepIdx) + 2
    `$oldStepsBlock = `$contentLF.Substring(`$stepIdx, `$stepEndIdx - `$stepIdx)
    `$newStepsBlock = FromB64 "$b64Steps"
    `$contentLF = `$contentLF.Replace(`$oldStepsBlock, `$newStepsBlock)
    Write-Host "1. tutorialSteps replaced OK" -ForegroundColor Green
}

# 2. help button
`$helpBtnSearch = '<button id="btn-help-tutorial"'
`$helpBtnIdx = `$contentLF.IndexOf(`$helpBtnSearch)
if (`$helpBtnIdx -ge 0) {
    `$helpBtnEnd = `$contentLF.IndexOf('</button>', `$helpBtnIdx) + 9
    `$oldBtn = `$contentLF.Substring(`$helpBtnIdx, `$helpBtnEnd - `$helpBtnIdx)
    `$newBtn = FromB64 "$b64GuideBtn"
    `$contentLF = `$contentLF.Replace(`$oldBtn, `$newBtn)
    Write-Host "2. help button replaced OK" -ForegroundColor Green
}

# 3. helpSimpleModal remove
`$modalSearch = '<div id="helpSimpleModal"'
`$modalIdx = `$contentLF.IndexOf(`$modalSearch)
if (`$modalIdx -ge 0) {
    `$scriptIdx = `$contentLF.IndexOf('<script>', `$modalIdx)
    if (`$scriptIdx -gt `$modalIdx) {
        `$modalBlock = `$contentLF.Substring(`$modalIdx, `$scriptIdx - `$modalIdx)
        `$contentLF = `$contentLF.Replace(`$modalBlock, "")
        Write-Host "3. helpSimpleModal removed OK" -ForegroundColor Green
    }
}

# 4. drawTieCurve
`$tieSearch = "function drawTieCurve("
`$tieIdx = `$contentLF.IndexOf(`$tieSearch)
if (`$tieIdx -ge 0) {
    `$tieEndIdx = `$contentLF.IndexOf("function drawAllTies(", `$tieIdx)
    `$oldTie = `$contentLF.Substring(`$tieIdx, `$tieEndIdx - `$tieIdx)
    `$newTie = FromB64 "$b64TieCurve"
    `$contentLF = `$contentLF.Replace(`$oldTie, `$newTie)
    Write-Host "4. drawTieCurve replaced OK" -ForegroundColor Green
}

# 5. setTempo
`$tempoSearch = "function setTempo(value) {"
`$tempoIdx = `$contentLF.IndexOf(`$tempoSearch)
if (`$tempoIdx -ge 0) {
    `$tempoEndIdx = `$contentLF.IndexOf("function setMetronomeEnabled(", `$tempoIdx)
    `$oldTempo = `$contentLF.Substring(`$tieIdx, `$tempoEndIdx - `$tempoIdx)
    `$oldTempo = `$contentLF.Substring(`$tempoIdx, `$tempoEndIdx - `$tempoIdx)
    `$newTempo = FromB64 "$b64Tempo"
    `$contentLF = `$contentLF.Replace(`$oldTempo, `$newTempo)
    Write-Host "5. setTempo replaced OK" -ForegroundColor Green
}

# 6. showPracticeExample
`$practiceSearch = "async function showPracticeExample() {"
`$practiceIdx = `$contentLF.IndexOf(`$practiceSearch)
if (`$practiceIdx -ge 0) {
    `$practiceEndIdx = `$contentLF.IndexOf("function startGuidedPractice()", `$practiceIdx)
    `$oldPractice = `$contentLF.Substring(`$practiceIdx, `$practiceEndIdx - `$practiceIdx)
    `$newPractice = FromB64 "$b64Practice"
    `$contentLF = `$contentLF.Replace(`$oldPractice, `$newPractice)
    Write-Host "6. showPracticeExample replaced OK" -ForegroundColor Green
}

`$finalContent = `$contentLF -replace "`n", "`r`n"
[System.IO.File]::WriteAllText(`$FilePath, `$finalContent, `$utf8)
Write-Host "Applied Base64 patch to index.html cleanly!" -ForegroundColor Green
"@

[System.IO.File]::WriteAllText("scratch/patch_pure_b64.ps1", $patchScript, $utf8)
Write-Host "Base64 patch script prepared." -ForegroundColor Cyan
