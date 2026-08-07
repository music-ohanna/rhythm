# safe_patch_all.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

$originalLength = $content.Length
Write-Host "Loaded index.html (len: $originalLength)" -ForegroundColor Cyan

# 1. Header Buttons Update
$h1Search = '<h1 class="text-xl md:text-2xl font-black text-slate-900'
$h1Idx = $content.IndexOf($h1Search)
if ($h1Idx -ge 0) {
    $h1EndIdx = $content.IndexOf('</header>', $h1Idx)
    $oldHeaderChunk = $content.Substring($h1Idx, $h1EndIdx - $h1Idx)

    $newHeaderChunk = @"
<h1 onclick="resetToHome()" class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center cursor-pointer hover:opacity-80 transition select-none" title="처음 메인 화면으로 돌아가기">
            🎵 리듬 창작 앱
        </h1>
        <div class="flex gap-2 items-center">
            <!-- 박자 선택 -->
            <div class="relative inline-block text-left">
                <button id="meterSelectBtn" onclick="toggleMeterMenu()" type="button" class="px-3 py-1.5 rounded-xl bg-white text-slate-900 font-extrabold border-2 border-slate-300 hover:bg-slate-50 text-xs md:text-sm flex items-center gap-1 shadow-sm">
                    <span id="currentMeterLabel">4/4</span>
                    <span class="text-xs text-slate-500">▾</span>
                </button>
                <div id="meterDropdown" class="hidden absolute right-0 mt-1 w-24 rounded-xl bg-white border-2 border-slate-300 shadow-xl z-50 overflow-hidden py-1">
                    <button onclick="selectMeter(4,4)" class="w-full px-3 py-1.5 text-left text-xs md:text-sm font-bold text-slate-800 hover:bg-blue-50 hover:text-blue-600">4/4</button>
                    <button onclick="selectMeter(3,4)" class="w-full px-3 py-1.5 text-left text-xs md:text-sm font-bold text-slate-800 hover:bg-blue-50 hover:text-blue-600">3/4</button>
                    <button onclick="selectMeter(2,4)" class="w-full px-3 py-1.5 text-left text-xs md:text-sm font-bold text-slate-800 hover:bg-blue-50 hover:text-blue-600">2/4</button>
                    <button onclick="selectMeter(6,8)" class="w-full px-3 py-1.5 text-left text-xs md:text-sm font-bold text-slate-800 hover:bg-blue-50 hover:text-blue-600">6/8</button>
                </div>
            </div>

            <!-- 주요 상단 기능 직관적 배치 -->
            <div class="flex gap-1.5 items-center">
                <button id="btn-undo" onclick="undoLastAction()" class="text-tool-btn text-xs md:text-sm" title="마지막 작업 되돌리기">
                    <span class="text-base">↩️</span> 되돌리기
                </button>
                <button id="btn-clear-all" onclick="confirmClear()" class="text-tool-btn text-xs md:text-sm" title="현재 마디의 모든 기호 삭제">
                    <span class="text-base">🗑️</span> 지우기
                </button>
                <button id="btn-delete-note" onclick="toggleDeleteMode()" class="text-tool-btn text-xs md:text-sm" title="선택한 기호 하나씩 삭제 모드">
                    <span class="text-base">🧽</span> 선택 삭제
                </button>
                <button id="btn-stage-practice" onclick="showPracticeExample()" class="text-tool-btn text-xs md:text-sm bg-amber-100 hover:bg-amber-200 text-amber-950 font-black border-2 border-amber-500 shadow-sm" title="4/4박자 예시 리듬 따라 만들기">
                    <span class="text-base">🎯</span> 예시 따라하기
                </button>
                <button id="btn-header-save" onclick="downloadPlayableScoreHtml()" class="text-tool-btn btn-save-score text-xs md:text-sm" title="만든 악보 파일로 저장하기">
                    <span class="text-base">📥</span> 악보 저장
                </button>
                <button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm font-black text-blue-900 border-2 border-blue-400 bg-blue-50 hover:bg-blue-100" title="앱 사용법 팝업 가이드 보기">
                    <span class="text-base">❓</span> 도움말
                </button>
            </div>
        </div>
"@
    $content = $content.Replace($oldHeaderChunk, $newHeaderChunk + "`n    ")
    Write-Host "1. Header buttons updated OK" -ForegroundColor Green
}

# 2. Controls Footer Update (Expose V자 리듬 & 정간보 checkboxes)
$ctrlSearch = '<div class="playback-controls'
$ctrlIdx = $content.IndexOf($ctrlSearch)
if ($ctrlIdx -ge 0) {
    $playBtnIdx = $content.IndexOf('<div class="play-buttons', $ctrlIdx)
    if ($playBtnIdx -gt $ctrlIdx) {
        $oldCtrlChunk = $content.Substring($ctrlIdx, $playBtnIdx - $ctrlIdx)
        $newCtrlChunk = @"
<div class="playback-controls flex justify-between items-center gap-2 shrink-0">
            <div class="flex items-center gap-1.5">
                <button id="btn-tie-note" onclick="toggleTieMode()" class="text-tool-btn text-xs" title="붙임줄 만들기">
                    <span class="text-sm">⌒</span> 붙임줄
                </button>
            </div>
            <label class="flex items-center gap-2 text-xs md:text-sm">
                <span>빠르기</span>
                <input id="tempoSlider" class="tempo-range" type="range" min="40" max="160" step="1" value="60" oninput="setTempo(this.value)" aria-label="빠르기 조절">
                <span id="tempoValue" class="tempo-value">♩ = 60</span>
            </label>
            <!-- 밖으로 노출된 직관적인 메트로놈 / V자 리듬 / 정간보 토글 -->
            <div class="flex items-center gap-3 text-xs md:text-sm font-bold text-slate-800">
                <label class="flex items-center gap-1 cursor-pointer" title="메트로놈 소리 켜기/끄기">
                    <input id="metronomeToggle" class="metronome-toggle" type="checkbox" checked onchange="setMetronomeEnabled(this.checked)" aria-label="짧은 틱 소리 메트로놈">
                    <span>메트로놈</span>
                </label>
                <label class="flex items-center gap-1 cursor-pointer" title="악보 아래 V자 리듬 표기 보이기">
                    <input id="vRhythmToggle" type="checkbox" checked onchange="toggleVRhythmDisplay(this.checked)" aria-label="V자 리듬 표기">
                    <span>V자 리듬</span>
                </label>
                <label class="flex items-center gap-1 cursor-pointer" title="악보 아래 정간보 표기 보이기">
                    <input id="jeongganboToggle" type="checkbox" checked onchange="toggleJeongganboDisplay(this.checked)" aria-label="정간보 표기">
                    <span>정간보</span>
                </label>
            </div>
            <label class="instrument-label text-xs md:text-sm">
                <span>악기</span>
                <select id="rhythmInstrument" class="instrument-select" onchange="setRhythmInstrument(this.value)" aria-label="리듬 악기 선택">
                    <option value="synth">기본음</option>
                    <option value="janggu">장구</option>
                    <option value="kkwaenggwari">꽹과리</option>
                    <option value="woodblock">우드블록</option>
                    <option value="drum">드럼</option>
                </select>
            </label>
        </div>
"@
        $content = $content.Replace($oldCtrlChunk, $newCtrlChunk + "`n`n        ")
        Write-Host "2. Controls footer updated OK" -ForegroundColor Green
    }
}

# 3. drawTieCurve Single Clean Bezier Line Update
$tieSearch = "function drawTieCurve("
$tieIdx = $content.IndexOf($tieSearch)
if ($tieIdx -ge 0) {
    $tieEndIdx = $content.IndexOf("function drawAllTies(", $tieIdx)
    $oldTieChunk = $content.Substring($tieIdx, $tieEndIdx - $tieIdx)
    $newTieChunk = @"
function drawTieCurve(fromNote, toNote, staffY, color = '#0f172a', alpha = 1) {
            if (!fromNote || !toNote) return;
            const fromX = fromNote.x + 10.5;
            const toX = toNote.x - 10.5;
            if (toX <= fromX + 4) return;

            const y = staffY + 12;
            const width = toX - fromX;
            // 깔끔하고 볼록한 깊은 곡률 (최소 22px, 너비 비례 0.30, 최대 48px)
            const depth = Math.max(22, Math.min(48, width * 0.30));

            rhythmCtx.save();
            rhythmCtx.strokeStyle = color;
            rhythmCtx.globalAlpha = alpha;
            rhythmCtx.lineWidth = 3.5;
            rhythmCtx.lineCap = 'round';
            rhythmCtx.lineJoin = 'round';

            // 깔끔한 단일 베지어 곡선 (잔향 이중선 제거)
            rhythmCtx.beginPath();
            rhythmCtx.moveTo(fromX, y);
            rhythmCtx.bezierCurveTo(
                fromX + width * 0.22, y + depth,
                toX - width * 0.22, y + depth,
                toX, y
            );
            rhythmCtx.stroke();
            rhythmCtx.restore();
        }

"@
    $content = $content.Replace($oldTieChunk, $newTieChunk)
    Write-Host "3. drawTieCurve clean single line updated OK" -ForegroundColor Green
}

# 4. 8-Step Tutorial Steps Array Update
$stepSearch = "const tutorialSteps = ["
$stepIdx = $content.IndexOf($stepSearch)
if ($stepIdx -ge 0) {
    $stepEndIdx = $content.IndexOf("];", $stepIdx) + 2
    $oldStepChunk = $content.Substring($stepIdx, $stepEndIdx - $stepIdx)
    $newStepChunk = @"
const tutorialSteps = [
            {
                title: '1단계: 음표 넣기',
                body: '아래 표에서 <strong>4분음표</strong>, <strong>8분음표</strong> 등 음표를 눌러 악보에 넣어요.',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '2단계: 쉼표 넣기',
                body: '쉼표 줄의 <strong>4분쉼표</strong>, <strong>8분쉼표</strong>를 눌러 악보에 쉼표를 넣어요.',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '3단계: 점( . ) 붙이기',
                body: '음표나 쉼표를 넣은 다음 <strong>[ . ] (점)</strong> 버튼을 눌러 점음표나 점쉼표로 만드세요.',
                anchor: 'dotButton',
                placement: 'top'
            },
            {
                title: '4단계: 붙임줄 연결하기',
                body: '음표를 이어 연결하고 싶다면 <strong>[⌒ 붙임줄]</strong> 버튼을 활성화한 뒤 <strong>앞 음표 → 뒤 음표 순서</strong>로 클릭하세요.',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '5단계: 내 리듬 들어보기',
                body: '악보를 완성한 후 <strong>[▶ 이 마디 듣기]</strong> 버튼을 눌러 내가 만든 리듬을 들어보세요!',
                anchor: 'play',
                placement: 'top'
            },
            {
                title: '6단계: 지우기·되돌리기·선택 삭제',
                body: '잘못 입력했을 때는 <strong>↩️ 되돌리기</strong>, <strong>🗑️ 전체 지우기</strong> 또는 <strong>🧽 선택 삭제</strong>를 누르세요.<br><small>선택 삭제를 누른 후 지우고 싶은 음표를 클릭하면 하나씩 삭제됩니다.</small>',
                anchor: 'undoClear',
                placement: 'bottom'
            },
            {
                title: '7단계: 가이드 완료!',
                body: '기본 사용법 안내가 끝났습니다! 자유롭게 나만의 리듬을 창작해 보세요 🎉',
                anchor: 'canvas',
                placement: 'center'
            },
            {
                title: '8단계: 예시 따라 만들기 도전!',
                body: '선생님이 준비한 예시 리듬을 따라서 만들고 싶다면 상단의 <strong>[🎯 예시 따라하기]</strong> 버튼을 클릭하세요!',
                anchor: 'practice',
                placement: 'bottom'
            }
        ];
"@
    $content = $content.Replace($oldStepChunk, $newStepChunk)
    Write-Host "4. 8-step tutorialSteps updated OK" -ForegroundColor Green
}

# 5. getTutorialAnchor Update
$ancSearch = "function getTutorialAnchor(anchor) {"
$ancIdx = $content.IndexOf($ancSearch)
if ($ancIdx -ge 0) {
    $ancEndIdx = $content.IndexOf("function normalizeTutorialTargets(", $ancIdx)
    $oldAncChunk = $content.Substring($ancIdx, $ancEndIdx - $ancIdx)
    $newAncChunk = @"
function getTutorialAnchor(anchor) {
            if (!anchor) return null;
            if (anchor === 'canvas') return document.getElementById('canvasArea');
            if (anchor === 'measureNavigator') return document.getElementById('measureNavigator');
            if (anchor === 'play') return document.getElementById('playBtn');
            if (anchor === 'playbackControls') return document.querySelector('.playback-controls');
            if (anchor === 'delete') return document.getElementById('btn-delete-note');
            if (anchor === 'undo') return document.getElementById('btn-undo');
            if (anchor === 'tie') return document.getElementById('btn-tie-note');
            if (anchor === 'help') return document.getElementById('btn-help-tutorial');
            if (anchor === 'practice') return document.getElementById('btn-stage-practice');
            if (anchor === 'clear') return document.getElementById('btn-clear-all');
            if (anchor === 'undoClear') {
                return [document.getElementById('btn-undo'), document.getElementById('btn-clear-all'), document.getElementById('btn-delete-note')].filter(Boolean);
            }
            if (anchor === 'noteRestButtons') {
                return Array.from(document.querySelectorAll('.guide-cell[onclick]')).filter(el => (el.getAttribute('onclick') || '').includes('addNoteSmart'));
            }
            if (anchor === 'dotButton') {
                return Array.from(document.querySelectorAll('.guide-cell[onclick]')).find(el => (el.getAttribute('onclick') || '').includes('toggleLastDot'));
            }
            return document.querySelector(anchor);
        }

"@
    $content = $content.Replace($oldAncChunk, $newAncChunk)
    Write-Host "5. getTutorialAnchor updated OK" -ForegroundColor Green
}

# 6. Practice Example Logic & Toggle Helpers
$pracSearch = "function showPracticeExample()"
$pracIdx = $content.IndexOf($pracSearch)
if ($pracIdx -ge 0) {
    $pracEndIdx = $content.IndexOf("function startGuidedPractice()", $pracIdx)
    $oldPracChunk = $content.Substring($pracIdx, $pracEndIdx - $pracIdx)
    $newPracChunk = @"
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

        function getPracticeTarget() {
            return getFourFourPracticeExample();
        }

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

        function toggleVRhythmDisplay(enabled) {
            showVRhythm = !!enabled;
            const cb = document.getElementById('vRhythmToggle');
            if (cb) cb.checked = showVRhythm;
            drawAll();
        }

        function toggleJeongganboDisplay(enabled) {
            showJeongganbo = !!enabled;
            const cb = document.getElementById('jeongganboToggle');
            if (cb) cb.checked = showJeongganbo;
            drawAll();
        }

        async function showPracticeExample() {
            stopPerformance();
            if (timeSignature.top !== 4 || timeSignature.bottom !== 4) {
                showToast('⚠️ 예시 창작은 4/4박자를 기준으로 합니다. 4/4박자로 전환합니다!', true);
                await new Promise(r => setTimeout(r, 600));
                setTimeSig(4, 4);
                await new Promise(r => setTimeout(r, 100));
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
            showToast('🎯 예시 악보를 1회 연주합니다. 잘 들어보세요!', true);
            await startPerformance();
        }

"@
    $content = $content.Replace($oldPracChunk, $newPracChunk)
    Write-Host "6. Practice example & toggle logic updated OK" -ForegroundColor Green
}

# 7. Start Guided Practice 4/4 forced mode
$startPracSearch = "function startGuidedPractice() {"
$startPracIdx = $content.IndexOf($startPracSearch)
if ($startPracIdx -ge 0) {
    $startPracEnd = $content.IndexOf("function startIndependentCreation()", $startPracIdx)
    $oldStartPracChunk = $content.Substring($startPracIdx, $startPracEnd - $startPracIdx)
    $newStartPracChunk = @"
function startGuidedPractice() {
            stopPerformance();
            if (timeSignature.top !== 4 || timeSignature.bottom !== 4) {
                setTimeSig(4, 4);
            }
            pushUndoState();
            guidedPracticeTarget = getFourFourPracticeExample().map(note => ({...note}));
            notes.splice(0, notes.length);
            dotCandidateNote = null;
            syncActiveMeasureState();
            closePracticePanel();
            showPracticeStatus('guided');
            drawAll();
            showToast('연한 회색 악보 기호를 따라 입력하세요.', true);
        }

"@
    $content = $content.Replace($oldStartPracChunk, $newStartPracChunk)
    Write-Host "7. startGuidedPractice updated OK" -ForegroundColor Green
}

# 8. Initial Toast Notice on Load
$loadSearch = "window.addEventListener('load', () => {"
$loadIdx = $content.IndexOf($loadSearch)
if ($loadIdx -ge 0) {
    $oldLoad = $content.Substring($loadIdx, $content.IndexOf("});", $loadIdx) + 4 - $loadIdx)
    $newLoad = @"
window.addEventListener('load', () => {
            setTimeout(() => {
                showToast('💡 처음이라 앱 사용방법이 궁금하면 상단 [❓ 도움말]을 눌러주세요!', true);
            }, 1000);
        });
"@
    $content = $content.Replace($oldLoad, $newLoad)
    Write-Host "8. Initial toast notice updated OK" -ForegroundColor Green
}

$finalContent = $content -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
$newLength = $finalContent.Length
Write-Host "Saved index.html safely! (Original: $originalLength, New: $newLength, Delta: $($newLength - $originalLength))" -ForegroundColor Green
