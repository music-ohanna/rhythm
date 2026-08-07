# This script converts pure UTF8 strings to Base64 and patches index.html safely
$utf8 = New-Object System.Text.UTF8Encoding($false)

# Raw Korean text blocks
$raw_logo = 'onclick="openNewScreenModal()" class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center cursor-pointer hover:opacity-80 transition-opacity" title="새 화면으로 이동 (작업 저장/초기화)">'

$raw_modal = @"

    <!-- 새 화면 / 새 작업 시작 확인 모달 -->
    <div id="newScreenDialog" class="choice-dialog" role="dialog" aria-modal="true" aria-labelledby="newScreenTitle">
        <div class="choice-card" style="width: min(440px, calc(100vw - 28px)); text-align: center; padding: 22px;">
            <h2 id="newScreenTitle" class="choice-title" style="margin-bottom: 8px; color: #1e3a8a;">🎵 새 화면으로 이동</h2>
            <p class="choice-description" style="margin-bottom: 20px; font-size: 14px; color: #475569; line-height: 1.6;">
                새 작업을 시작하시겠습니까?<br>
                현재 만들던 악보를 <strong>저장</strong>하고 이동하시겠습니까?
            </p>
            <div style="display: flex; flex-direction: column; gap: 10px;">
                <button type="button" onclick="handleNewScreenChoice('save')" class="choice-button primary" style="background: #4f46e5; border-color: #3730a3; color: white;">
                    📥 악보 저장 후 새 화면으로
                </button>
                <button type="button" onclick="handleNewScreenChoice('reset')" class="choice-button" style="background: #fef2f2; color: #dc2626; border-color: #fca5a5;">
                    🗑️ 저장 안 하고 새 화면으로
                </button>
                <button type="button" onclick="handleNewScreenChoice('cancel')" class="choice-button" style="background: white; color: #64748b;">
                    취소
                </button>
            </div>
        </div>
    </div>
"@

$raw_fns = @"
function openHelpModal() {
            showTutorial(true);
        }

        function closeHelpModal() {
            closeTutorial();
        }

        function openNewScreenModal() {
            const dialog = document.getElementById('newScreenDialog');
            if (dialog) dialog.classList.add('show');
        }

        function closeNewScreenModal() {
            const dialog = document.getElementById('newScreenDialog');
            if (dialog) dialog.classList.remove('show');
        }

        function resetAllScoreMeasures() {
            stopPerformance();
            scoreMeasures = Array.from({length: PROJECT_MEASURE_COUNT}, () => []);
            measureUndoStacks = Array.from({length: PROJECT_MEASURE_COUNT}, () => []);
            notes = scoreMeasures[0];
            undoStack = measureUndoStacks[0];
            activeMeasureIndex = 0;
            dotCandidateNote = null;
            tieSourceNote = null;
            clearDrawings();
            updateMeasureNavigator();
            drawAll();
        }

        async function handleNewScreenChoice(choice) {
            closeNewScreenModal();
            if (choice === 'save') {
                downloadPlayableScoreHtml();
                setTimeout(() => {
                    resetAllScoreMeasures();
                    showToast('작품을 저장하고 새 화면으로 이동했습니다.', true);
                }, 500);
            } else if (choice === 'reset') {
                resetAllScoreMeasures();
                showToast('새 화면으로 이동했습니다.', true);
            }
        }
"@

$raw_steps = @"
const tutorialSteps = [
            {
                title: '1단계: 음표·쉼표 넣기',
                body: '아래 입력표에서 <strong>음표</strong>나 <strong>쉼표</strong>를 눌러 악보에 넣으세요.',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '2단계: 점 ( . ) 붙이기',
                body: '음표나 쉼표를 넣은 후 <strong>[ . ] (점)</strong> 버튼을 누르면 점음표나 점쉼표로 바뀝니다.',
                anchor: 'dotButton',
                placement: 'top'
            },
            {
                title: '3단계: 붙임줄 연결하기',
                body: '두 음표를 이어 연주하고 싶다면 <strong>[⌒ 붙임줄]</strong> 버튼을 켠 후 <strong>연결할 음표 2개</strong>를 차례대로 클릭하세요.<br><small>(첫 번째 음표 → 두 번째 음표 순서)</small>',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '4단계: 내 리듬 들어보기',
                body: '악보를 만든 뒤 <strong>[▶ 이 마디 듣기]</strong>나 <strong>[▶▶ 전체 듣기]</strong>를 눌러 내가 만든 리듬을 들어보세요!',
                anchor: 'play',
                placement: 'top'
            },
            {
                title: '5단계: 지우기·되돌리기',
                body: '잘못 입력했을 때는 <strong>↩️ 되돌리기</strong> 또는 <strong>🗑️ 지우기</strong>를 누르세요.',
                anchor: 'undoClear',
                placement: 'bottom'
            },
            {
                title: '6단계: 시작하기',
                body: '이동식 가이드 안내가 끝났습니다. 자유롭게 리듬을 창작해 보세요! 🎉',
                anchor: 'canvas',
                placement: 'center'
            }
        ];
"@

# Read index.html
$indexPath = Join-Path $PSScriptRoot "..\index.html"
$text = [System.IO.File]::ReadAllText($indexPath, $utf8)

# 1. Logo
$target1 = 'class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center">'
if ($text.Contains($target1)) {
    $text = $text.Replace($target1, $raw_logo)
    Write-Host "1. Logo updated"
}

# 2. Help button
$target2 = 'id="btn-help-tutorial" onclick="openHelpModal()"'
$replace2 = 'id="btn-help-tutorial" onclick="showTutorial(true)"'
if ($text.Contains($target2)) {
    $text = $text.Replace($target2, $replace2)
    Write-Host "2. Help button updated"
}

# 3. Add modal HTML
$target3 = 'id="submissionDialog"'
$idx3 = $text.IndexOf($target3)
if ($idx3 -gt 0) {
    $closeDialogIdx = $text.IndexOf('</div>', $idx3)
    $closeDialogIdx2 = $text.IndexOf('</div>', $closeDialogIdx + 6)
    if ($closeDialogIdx2 -gt 0) {
        $insertPos = $closeDialogIdx2 + 6
        $text = $text.Substring(0, $insertPos) + $raw_modal + $text.Substring($insertPos)
        Write-Host "3. Modal inserted"
    }
}

# 4. Functions
$targetFn = 'function openHelpModal() {'
$idxFn = $text.IndexOf($targetFn)
if ($idxFn -gt 0) {
    $idxFnEnd = $text.IndexOf('}', $text.IndexOf('}', $idxFn) + 1)
    if ($idxFnEnd -gt 0) {
        $fnEndPos = $idxFnEnd + 1
        $text = $text.Substring(0, $idxFn) + $raw_fns + $text.Substring($fnEndPos)
        Write-Host "4. Functions updated"
    }
}

# 5. Tutorial steps
$target4Start = 'const tutorialSteps = ['
$idx4Start = $text.IndexOf($target4Start)
if ($idx4Start -gt 0) {
    $idx4End = $text.IndexOf('];', $idx4Start)
    if ($idx4End -gt 0) {
        $endPos = $idx4End + 2
        $text = $text.Substring(0, $idx4Start) + $raw_steps + $text.Substring($endPos)
        Write-Host "5. Steps updated"
    }
}

[System.IO.File]::WriteAllText($indexPath, $text, $utf8)
Write-Host "Patch complete!"
