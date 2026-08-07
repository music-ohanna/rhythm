# patch_all_features.ps1
# 리듬 창작 앱 통합 패치
param(
    [string]$FilePath = "index.html"
)

$ErrorActionPreference = "Stop"

Write-Host "Reading file..." -ForegroundColor Cyan
$content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
$originalLen = $content.Length
Write-Host "File size: $originalLen bytes"

# =============================================================
# PATCH 1: tutorialSteps 배열 교체 (4단계 → 7단계)
# =============================================================
Write-Host "`n[1/7] Patching tutorialSteps..." -ForegroundColor Yellow

$oldSteps = @'
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
'@

$newSteps = @'
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
'@

if ($content.Contains($oldSteps)) {
    $content = $content.Replace($oldSteps, $newSteps)
    Write-Host "  tutorialSteps replaced OK" -ForegroundColor Green
} else {
    Write-Host "  WARNING: tutorialSteps old text not found" -ForegroundColor Red
}

# =============================================================
# PATCH 2: 도움말 버튼 → 가이드 버튼으로 교체 및 클릭 시 showTutorial(true)
# =============================================================
Write-Host "`n[2/7] Replacing help button with guide button..." -ForegroundColor Yellow

$oldHelpBtn = @'
                <button id="btn-help-tutorial" onclick="openHelpModal()" class="text-tool-btn text-xs md:text-sm" title="도움말 보기">
                    <span class="text-base">❓</span> 도움말
                </button>
'@

$newGuideBtn = @'
                <button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm" title="투어 가이드 다시 보기">
                    <span class="text-base">📖</span> 가이드
                </button>
'@

if ($content.Contains($oldHelpBtn)) {
    $content = $content.Replace($oldHelpBtn, $newGuideBtn)
    Write-Host "  Help button replaced OK" -ForegroundColor Green
} else {
    Write-Host "  WARNING: old help button not found" -ForegroundColor Red
}

# =============================================================
# PATCH 3: helpSimpleModal 제거
# =============================================================
Write-Host "`n[3/7] Removing helpSimpleModal..." -ForegroundColor Yellow

$oldModal = @'
    <!-- ❓ 도움말 팝업 모달 (3문장 간소화) -->
    <div id="helpSimpleModal" class="choice-dialog" role="dialog" aria-modal="true" aria-labelledby="helpSimpleTitle">
        <div class="choice-card" style="width: min(460px, calc(100vw - 28px)); text-align: left; padding: 22px;">
            <div class="flex justify-between items-center mb-3">
                <h2 id="helpSimpleTitle" class="choice-title" style="margin: 0; font-size: 20px; color: #1e3a8a;">❓ 리듬 창작 앱 사용법</h2>
                <button type="button" onclick="closeHelpModal()" class="text-slate-400 hover:text-slate-700 font-extrabold text-lg px-2">✕</button>
            </div>
            
            <div class="bg-blue-50 border border-blue-200 rounded-2xl p-4 mb-4">
                <ol class="space-y-2 text-xs md:text-sm font-bold text-slate-800 pl-4 list-decimal leading-relaxed">
                    <li>아래 음표나 쉼표를 눌러 악보에 넣어요.</li>
                    <li>듣기 버튼을 눌러 만든 리듬을 들어요.</li>
                    <li>바꾸고 싶으면 지우거나 되돌리기를 눌러요.</li>
                </ol>
            </div>

            <!-- 더 알아보기 펼침 영역 -->
            <div id="helpDetailArea" class="hidden space-y-3 max-h-[260px] overflow-y-auto pr-1 text-xs md:text-sm text-slate-700">
                <div class="p-3 bg-slate-50 rounded-xl border border-slate-200">
                    <strong class="block text-slate-900 font-bold mb-1">🥁 악기 특징</strong>
                    <p class="mb-1">• <strong>장구</strong>: 부드럽고 다양한 장단을 들려줘요.</p>
                    <p class="mb-1">• <strong>꽹과리</strong>: 밝고 힘찬 소리로 강한 박을 느끼기 좋아요.</p>
                    <p class="mb-1">• <strong>우드블록</strong>: 짧고 맑은 나무 소리예요.</p>
                    <p class="mb-1">• <strong>드럼</strong>: 또렷하고 단단한 타격 소리예요.</p>
                </div>
                <div class="p-3 bg-slate-50 rounded-xl border border-slate-200">
                    <strong class="block text-slate-900 font-bold mb-1">🎵 박자 및 표기법</strong>
                    <p>4/4, 3/4, 2/4, 6/8 박자를 상단 박자 버튼으로 바꿀 수 있습니다. V자 리듬과 정간보 표기는 '보기·설정' 메뉴에서 켜거나 끌 수 있습니다.</p>
                </div>
            </div>

            <div class="flex justify-between items-center mt-4 pt-3 border-t border-slate-200">
                <button type="button" id="btnToggleHelpDetail" onclick="toggleHelpDetail()" class="text-xs font-bold text-blue-600 hover:underline">
                    📖 더 알아보기 (악기/박자 설명)
                </button>
                <button type="button" onclick="closeHelpModal()" class="px-4 py-2 bg-blue-600 text-white font-bold rounded-xl text-xs hover:bg-blue-700">확인</button>
            </div>
        </div>
    </div>
'@

if ($content.Contains($oldModal)) {
    $content = $content.Replace($oldModal, '')
    Write-Host "  helpSimpleModal removed OK" -ForegroundColor Green
} else {
    Write-Host "  WARNING: helpSimpleModal not found" -ForegroundColor Red
}

# =============================================================
# PATCH 4: drawTieCurve - 붙임줄 더 볼록하게 (아래로 볼록)
# =============================================================
Write-Host "`n[4/7] Making tie curve more rounded..." -ForegroundColor Yellow

$oldTieCurve = @'
        function drawTieCurve(fromNote, toNote, staffY, color = '#0f172a', alpha = 1) {
            if (!fromNote || !toNote) return;
            const fromX = fromNote.x + 10.5;
            const toX = toNote.x - 10.5;
            if (toX <= fromX + 4) return;

            const y = staffY + 8.5;
            const width = toX - fromX;
            const depth = Math.max(8, Math.min(17, width * 0.13));

            rhythmCtx.save();
            rhythmCtx.strokeStyle = color;
            rhythmCtx.globalAlpha = alpha;
            rhythmCtx.lineWidth = 2.35;
            rhythmCtx.lineCap = 'round';
            rhythmCtx.lineJoin = 'round';
            rhythmCtx.beginPath();
            rhythmCtx.moveTo(fromX, y);
            rhythmCtx.quadraticCurveTo((fromX + toX) / 2, y + depth, toX, y);
            rhythmCtx.stroke();
            rhythmCtx.restore();
        }
'@

$newTieCurve = @'
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
'@

if ($content.Contains($oldTieCurve)) {
    $content = $content.Replace($oldTieCurve, $newTieCurve)
    Write-Host "  drawTieCurve updated OK" -ForegroundColor Green
} else {
    Write-Host "  WARNING: drawTieCurve old text not found" -ForegroundColor Red
}

# =============================================================
# PATCH 5: setTempo - 재생 중 실시간 반응
# =============================================================
Write-Host "`n[5/7] Adding real-time tempo response during playback..." -ForegroundColor Yellow

$oldSetTempo = @'
        function setTempo(value) {
            tempo = Math.max(40, Math.min(160, Number(value) || 60));
            const tempoValue = document.getElementById('tempoValue');
            if (tempoValue) tempoValue.textContent = `♩ = ${tempo}`;
            updatePlayButtonLabel();
        }
'@

$newSetTempo = @'
        let _tempoRestartTimer = null;
        function setTempo(value) {
            tempo = Math.max(40, Math.min(160, Number(value) || 60));
            const tempoValue = document.getElementById('tempoValue');
            if (tempoValue) tempoValue.textContent = `♩ = ${tempo}`;
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
'@

if ($content.Contains($oldSetTempo)) {
    $content = $content.Replace($oldSetTempo, $newSetTempo)
    Write-Host "  setTempo updated OK" -ForegroundColor Green
} else {
    Write-Host "  WARNING: setTempo old text not found" -ForegroundColor Red
}

# =============================================================
# PATCH 6: showPracticeExample - 4/4박자 강제 전환 + 사용자가 원하는 예시 악보 생성
# =============================================================
Write-Host "`n[6/7] Updating showPracticeExample for 4/4 forced mode with exact example rhythm..." -ForegroundColor Yellow

$oldPracticeExample = @'
        async function showPracticeExample() {
            stopPerformance();
            pushUndoState();
            const example = getPracticeTarget();
            notes.splice(0, notes.length, ...example.map(note => ({...note})));
            guidedPracticeTarget = example.map(note => ({...note}));
            dotCandidateNote = null;
            syncActiveMeasureState();
            closePracticePanel();
            showPracticeStatus('example');
            drawAll();
            showToast(`예시: ${getPracticeTargetLabel()}`, true);
            await startPerformance();
        }
'@

$newPracticeExample = @'
        // 이미지(사진)에 표시된 4/4박자 풍부한 예시 리듬:
        // 1박: 4분음표 (1박)
        // 2박: 점8분음표(0.75박) + 16분음표(0.25박)
        // 3박: 셋잇단음표 3개 (1박)
        // 4박: 8분음표(0.5박) + 8분쉼표(0.5박)
        function getFourFourPracticeExample() {
            return [
                { type: 'quarter',   isRest: false, beatOffset: 0,           dotted: false },
                { type: 'eighth',    isRest: false, beatOffset: 1,           dotted: true  }, // 점8분음표
                { type: 'sixteenth', isRest: false, beatOffset: 1.75,        dotted: false }, // 16분음표
                { type: 'triplet',   isRest: false, beatOffset: 2,           dotted: false }, // 셋잇단 1
                { type: 'triplet',   isRest: false, beatOffset: 2 + 1/3,     dotted: false }, // 셋잇단 2
                { type: 'triplet',   isRest: false, beatOffset: 2 + 2/3,     dotted: false }, // 셋잇단 3
                { type: 'eighth',    isRest: false, beatOffset: 3,           dotted: false }, // 8분음표
                { type: 'eighth',    isRest: true,  beatOffset: 3.5,         dotted: false }  // 8분쉼표
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
            showToast('예시: 4분음표 · 점8분음표+16분음표 · 셋잇단음표 3개 · 8분음표+8분쉼표', true);
            await startPerformance();
        }
'@

if ($content.Contains($oldPracticeExample)) {
    $content = $content.Replace($oldPracticeExample, $newPracticeExample)
    Write-Host "  showPracticeExample updated OK" -ForegroundColor Green
} else {
    Write-Host "  WARNING: showPracticeExample old text not found" -ForegroundColor Red
}

# =============================================================
# 저장
# =============================================================
Write-Host "`nSaving file..." -ForegroundColor Cyan
[System.IO.File]::WriteAllText($FilePath, $content, [System.Text.Encoding]::UTF8)
$newLen = (Get-Item $FilePath).Length
Write-Host "Saved! New size: $newLen bytes (delta: $($newLen - $originalLen))" -ForegroundColor Green
Write-Host "All patches applied successfully!" -ForegroundColor Cyan
