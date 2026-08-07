const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. isPresetScore 선언
text = text.replace('let notes = scoreMeasures[0];', 'let notes = scoreMeasures[0];\n        let isPresetScore = false;');

// 2. loadPresetRhythm 에 isPresetScore = true
text = text.replace(
    'function loadPresetRhythm(type) {',
    'function loadPresetRhythm(type) {\n            isPresetScore = true;'
);

// 3. addNoteSmart 에 isPresetScore = false
text = text.replace(
    'function addNoteSmart(type, isRest) {',
    'function addNoteSmart(type, isRest) {\n            isPresetScore = false;'
);

// 4. downloadPlayableScoreHtml 시작에 예시 악보 저장 금지 & 저장 파일 튜토리얼 방지 처리
text = text.replace(
    'async function downloadPlayableScoreHtml() {',
    `async function downloadPlayableScoreHtml() {
            if (isPresetScore) {
                showValidationAlert('예시 악보는 저장할 수 없습니다. 새 악보를 만들어 보세요.');
                return;
            }
            localStorage.setItem(TUTORIAL_STORAGE_KEY, 'true');`
);

// 5. 헤더 "🎵 리듬 창작 앱" 클릭 시 새 악보 리셋 실행
text = text.replace(
    '<h1 onclick="openNewScreenModal()" class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center cursor-pointer hover:opacity-80 transition-opacity" title="새 화면으로 이동 (작업 저장/초기화)">',
    '<h1 onclick="resetScoreWithConfirmation()" class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center cursor-pointer hover:opacity-80 transition-opacity" title="새 악보 만들기">'
);

// resetScoreWithConfirmation 함수 추가
const insertPoint = 'function resetAllScoreMeasures() {';
const resetFuncCode = `function resetScoreWithConfirmation() {
            if (notes.length > 0 || scoreMeasures.some(m => m.length > 0)) {
                if (confirm('현재 악보를 초기화하고 새 악보를 만드시겠습니까?')) {
                    resetAllScoreMeasures();
                    isPresetScore = false;
                    showToast('새 악보가 준비되었습니다.', true);
                }
            } else {
                resetAllScoreMeasures();
                isPresetScore = false;
                showToast('새 악보가 준비되었습니다.', true);
            }
        }\n\n        `;
text = text.replace(insertPoint, resetFuncCode + insertPoint);

// 6. 캔버스 마디 이동 원형 화살표 버튼 (좌/우 양쪽 원형 테두리 파란 화살표)
const targetCanvasButtons = `<button id="canvasNextMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex + 1)" class="absolute right-3 top-1/2 -translate-y-1/2 z-30 bg-blue-600/90 hover:bg-blue-700 text-white font-extrabold w-9 h-12 rounded-xl shadow-lg transition-all text-xl flex items-center justify-center" title="다음 마디로 이동">›</button>`;

const newCanvasButtons = `<button id="canvasPrevMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex - 1)" class="absolute left-3 top-1/2 -translate-y-1/2 z-30 bg-white/90 hover:bg-blue-100 border-2 border-blue-400 text-blue-600 font-extrabold w-10 h-10 rounded-full shadow-md transition-all text-xl flex items-center justify-center cursor-pointer" title="이전 마디로 이동">‹</button>
        <button id="canvasNextMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex + 1)" class="absolute right-3 top-1/2 -translate-y-1/2 z-30 bg-white/90 hover:bg-blue-100 border-2 border-blue-400 text-blue-600 font-extrabold w-10 h-10 rounded-full shadow-md transition-all text-xl flex items-center justify-center cursor-pointer" title="다음 마디로 이동">›</button>`;

text = text.replace(targetCanvasButtons, newCanvasButtons);

// 7. updateMeasureNavigator 에서 원형 화살표 버튼 display 제어
const targetNavUpdate = `if (previousButton) previousButton.disabled = activeMeasureIndex <= 0;
            if (nextButton) nextButton.disabled = activeMeasureIndex >= PROJECT_MEASURE_COUNT - 1;
            drawNextMeasurePreview();`;
const targetNavUpdateCRLF = `if (previousButton) previousButton.disabled = activeMeasureIndex <= 0;\r\n            if (nextButton) nextButton.disabled = activeMeasureIndex >= PROJECT_MEASURE_COUNT - 1;\r\n            drawNextMeasurePreview();`;

const replacementNavUpdate = `if (previousButton) previousButton.disabled = activeMeasureIndex <= 0;
            if (nextButton) nextButton.disabled = activeMeasureIndex >= PROJECT_MEASURE_COUNT - 1;
            const canvasPrevBtn = document.getElementById('canvasPrevMeasureBtn');
            const canvasNextBtn = document.getElementById('canvasNextMeasureBtn');
            if (canvasPrevBtn) canvasPrevBtn.style.display = activeMeasureIndex > 0 ? 'flex' : 'none';
            if (canvasNextBtn) canvasNextBtn.style.display = activeMeasureIndex < PROJECT_MEASURE_COUNT - 1 ? 'flex' : 'none';
            drawNextMeasurePreview();`;

if (text.includes(targetNavUpdateCRLF)) {
    text = text.replace(targetNavUpdateCRLF, replacementNavUpdate);
} else if (text.includes(targetNavUpdate)) {
    text = text.replace(targetNavUpdate, replacementNavUpdate);
}

// 8. tutorialSteps 정밀 업데이트
const tutorialMarkerStart = 'const tutorialSteps = [';
const tutorialMarkerEnd = 'let tutorialIndex = 0;';

const tStart = text.indexOf(tutorialMarkerStart);
const tEnd = text.indexOf(tutorialMarkerEnd, tStart);

if (tStart > 0 && tEnd > tStart) {
    const updatedTutorialCode = `const tutorialSteps = [
            {
                title: '1단계: 4/4박자 시범 리듬 창작',
                body: '앱이 직접 음표를 입력하며 4/4박자 한 마디를 완성합니다.',
                anchor: 'canvas',
                placement: 'center',
                onEnter: () => {
                    notes = [];
                    scoreMeasures[activeMeasureIndex] = notes;
                    drawAll();
                }
            },
            {
                title: '2단계: ♩ 4분음표 (1박) 입력',
                body: '입력표에서 <strong>4분음표</strong>를 누르면 1박 길이 음표가 악보에 들어갑니다.',
                anchor: 'noteRestButtons',
                placement: 'top',
                onEnter: () => {
                    notes = [];
                    addNoteSmart('quarter', false);
                    drawAll();
                }
            },
            {
                title: '3단계: 점음표',
                body: '8분음표에 점을 추가하면 점8분음표(0.75박)가 됩니다. 원래 길이의 절반(0.5배)만큼 길이가 길어집니다.',
                anchor: 'dotButton',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 1);
                    addNoteSmart('eighth', false);
                    toggleLastDot();
                    drawAll();
                }
            },
            {
                title: '4단계: 16분음표 (1/4박) 입력',
                body: '16분음표(0.25박)를 추가하여 점8분음표와 합쳐 2박을 완성합니다.',
                anchor: 'noteRestButtons',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 2);
                    addNoteSmart('sixteenth', false);
                    drawAll();
                }
            },
            {
                title: '5단계: 셋잇단음표 (1박 3분할)',
                body: '<strong>셋잇단음표</strong>를 입력합니다. 1박을 3등분한 길이입니다.',
                anchor: 'noteRestButtons',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 3);
                    addNoteSmart('triplet', false);
                    drawAll();
                }
            },
            {
                title: '6단계: ⌒ 붙임줄 연결하기',
                body: '음표 2개를 연속으로 클릭하면 두 음표가 붙임줄로 연결되어 한 번에 이어서 연주됩니다.',
                anchor: 'tie',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 6);
                    addNoteSmart('eighth', false);
                    addNoteSmart('eighth', false);
                    const tieIdx = notes.length - 2;
                    if (tieIdx >= 0 && notes[tieIdx] && !notes[tieIdx].isRest) {
                        notes[tieIdx].tied = true;
                    }
                    drawAll();
                }
            },
            {
                title: '7단계: 쉼표 입력하기',
                body: '8분쉼표 등 쉼표도 선택하여 원하는 박자에 쉼표를 넣을 수 있습니다.',
                anchor: 'noteRestButtons',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 7);
                    addNoteSmart('eighth', true);
                    drawAll();
                }
            },
            {
                title: '8단계: ♩ = 80 빠르기 조절',
                body: '빠르기 슬라이더로 연주 속도를 조절합니다. 지금은 <strong>♩ = 80</strong>입니다. 다른 속도로도 변경해 보세요.',
                anchor: '#tempoSlider',
                placement: 'top',
                onEnter: () => {
                    setTempo(80);
                    const slider = document.getElementById('tempoSlider');
                    if (slider) slider.value = 80;
                }
            },
            {
                title: '9단계: ▶ 완성된 리듬 들어보기!',
                body: '<strong>[▶ 이 마디 듣기]</strong>를 눌러 입력한 리듬을 재생합니다.',
                anchor: 'play',
                placement: 'top',
                onEnter: () => {
                    if (!isPlaying) playCurrentMeasure();
                }
            },
            {
                title: '10단계: 직접 리듬 창작하기',
                body: '시범이 끝났습니다. 이제 직접 리듬을 만들어 보세요.',
                anchor: 'canvas',
                placement: 'center',
                onEnter: () => {
                    if (isPlaying) stopPerformance();
                }
            }
        ];
        `;

    text = text.slice(0, tStart) + updatedTutorialCode + text.slice(tEnd);
}

fs.writeFileSync(filePath, text, 'utf8');
console.log('Update script completed successfully!');
