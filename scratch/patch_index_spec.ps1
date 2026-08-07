$filePath = Join-Path $PSScriptRoot "..\index.html"
$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

# 1. Insert newScreenDialog modal
$oldDialog = @"
    <div id="submissionDialog" class="choice-dialog" role="dialog" aria-modal="true" aria-labelledby="submissionTitle">
        <div class="choice-card">
            <h2 id="submissionTitle" class="choice-title">작품 제출 파일 만들기</h2>
            <p class="choice-description">교사가 파일을 구분할 수 있도록 학생 이름과 작품명을 입력하세요.</p>
            <input id="submissionNameInput" class="submission-name-input" type="text" maxlength="60" value="이름 - 작품명" aria-label="학생 이름과 작품명">
            <div class="choice-actions">
                <button id="submissionCancel" type="button" class="choice-button">취소</button>
                <button id="submissionSave" type="button" class="choice-button primary">HTML 저장</button>
            </div>
        </div>
    </div>
"@

$newDialog = @"
    <div id="submissionDialog" class="choice-dialog" role="dialog" aria-modal="true" aria-labelledby="submissionTitle">
        <div class="choice-card">
            <h2 id="submissionTitle" class="choice-title">작품 제출 파일 만들기</h2>
            <p class="choice-description">교사가 파일을 구분할 수 있도록 학생 이름과 작품명을 입력하세요.</p>
            <input id="submissionNameInput" class="submission-name-input" type="text" maxlength="60" value="이름 - 작품명" aria-label="학생 이름과 작품명">
            <div class="choice-actions">
                <button id="submissionCancel" type="button" class="choice-button">취소</button>
                <button id="submissionSave" type="button" class="choice-button primary">HTML 저장</button>
            </div>
        </div>
    </div>

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

if ($content.Contains($oldDialog)) {
    $content = $content.Replace($oldDialog, $newDialog)
    Write-Host "Successfully added newScreenDialog modal"
} else {
    Write-Warning "Could not find oldDialog block"
}

# 2. Header logo clickable
$oldLogo = @"
        <h1 class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center">
            🎵 리듬 창작 앱
        </h1>
"@

$newLogo = @"
        <h1 onclick="openNewScreenModal()" class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center cursor-pointer hover:opacity-80 transition-opacity" title="새 화면으로 이동 (작업 저장/초기화)">
            🎵 리듬 창작 앱
        </h1>
"@

if ($content.Contains($oldLogo)) {
    $content = $content.Replace($oldLogo, $newLogo)
    Write-Host "Successfully made logo clickable"
} else {
    Write-Warning "Could not find oldLogo block"
}

# 3. Help button in header
$oldHelpBtn = @"
                <button id="btn-help-tutorial" onclick="openHelpModal()" class="text-tool-btn text-xs md:text-sm" title="도움말 보기">
                    <span class="text-base">❓</span> 도움말
                </button>
"@

$newHelpBtn = @"
                <button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm" title="이동식 도움말 투어 시작">
                    <span class="text-base">❓</span> 도움말
                </button>
"@

if ($content.Contains($oldHelpBtn)) {
    $content = $content.Replace($oldHelpBtn, $newHelpBtn)
    Write-Host "Successfully updated help button"
} else {
    Write-Warning "Could not find oldHelpBtn block"
}

# 4. openHelpModal and openNewScreenModal functions
$oldHelpFn = @"
        function openHelpModal() {
            const modal = document.getElementById('helpSimpleModal');
            if (modal) modal.classList.add('show');
        }

        function closeHelpModal() {
            const modal = document.getElementById('helpSimpleModal');
            if (modal) modal.classList.remove('show');
        }
"@

$newHelpFn = @"
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

if ($content.Contains($oldHelpFn)) {
    $content = $content.Replace($oldHelpFn, $newHelpFn)
    Write-Host "Successfully replaced openHelpModal and added openNewScreenModal"
} else {
    Write-Warning "Could not find oldHelpFn block"
}

# 5. tutorialSteps array
$oldSteps = @"
        const tutorialSteps = [
            {
                title: '음표·쉼표 넣기',
                body: '아래 표에서 음표나 쉼표를 눌러 악보에 넣어요.',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '만든 리듬 듣기',
                body: '듣기 버튼을 눌러 만든 리듬을 소리로 들어요.',
                anchor: 'play',
                placement: 'top'
            },
            {
                title: '지우기·되돌리기',
                body: '잘못 입력했을 때는 지우거나 되돌리기를 눌러요.',
                anchor: 'undo',
                placement: 'bottom'
            },
            {
                title: '보기·설정과 도움말',
                body: '보기·설정에서 표기를 바꾸고, 자세한 설명은 도움말에서 확인해요.',
                anchor: 'help',
                placement: 'bottom'
            }
        ];
"@

$newSteps = @"
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

if ($content.Contains($oldSteps)) {
    $content = $content.Replace($oldSteps, $newSteps)
    Write-Host "Successfully updated tutorialSteps array"
} else {
    Write-Warning "Could not find oldSteps block"
}

# Write patched index.html back with UTF-8 without BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
Write-Host "Patched index.html successfully!"
