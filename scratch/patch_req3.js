const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. Header Toolbar: Group deletion tools (Undo, Select Delete, Clear All) together cleanly
const targetHeaderButtons = `<div class="flex gap-1.5">
                <button id="btn-undo" onclick="undoLastAction()" class="text-tool-btn text-xs md:text-sm" title="마지막 작업 되돌리기">
                    <span class="text-base">↩️</span> 되돌리기
                </button>
                <button id="btn-clear-all" onclick="confirmClear()" class="text-tool-btn text-xs md:text-sm" title="현재 마디의 모든 기호 삭제">
                    <span class="text-base">🗑️</span> 지우기
                </button>
                <button id="btn-header-save" onclick="downloadPlayableScoreHtml()" class="text-tool-btn btn-save-score text-xs md:text-sm" title="만든 악보 파일로 저장하기">
                    <span class="text-base">📥</span> 악보 저장
                </button>
                <button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm" title="도움말 보기">
                    <span class="text-base">❓</span> 도움말
                </button>
                <button id="btn-view-settings" onclick="openViewSettings()" class="text-tool-btn text-xs md:text-sm" title="보기 및 세부 설정 메뉴 열기">
                    <span class="text-base">⚙️</span> 보기·설정
                </button>
            </div>`;

const newHeaderButtons = `<div class="flex gap-1.5 items-center">
            <!-- 지우기/수정 도구 통합 그룹 -->
            <div class="flex gap-1 bg-slate-100/90 p-0.5 rounded-xl border border-slate-200 shadow-sm">
                <button id="btn-undo" onclick="undoLastAction()" class="text-tool-btn text-xs md:text-sm" title="방금 입력한 마지막 기호 취소">
                    <span class="text-base">↩️</span> 되돌리기
                </button>
                <button id="btn-delete-note" onclick="toggleDeleteMode()" class="text-tool-btn text-xs md:text-sm" title="특정 음표만 선택하여 지우기 (더블클릭 가능)">
                    <span class="text-base">🏷️</span> <span id="delete-label">선택 삭제</span>
                </button>
                <button id="btn-clear-all" onclick="confirmClear()" class="text-tool-btn text-xs md:text-sm" title="현재 마디의 모든 기호 지우기">
                    <span class="text-base">🗑️</span> 전체 지우기
                </button>
            </div>

            <button id="btn-header-save" onclick="downloadPlayableScoreHtml()" class="text-tool-btn btn-save-score text-xs md:text-sm" title="만든 악보 파일로 저장하기">
                <span class="text-base">📥</span> 악보 저장
            </button>
            <button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm" title="도움말 보기">
                <span class="text-base">❓</span> 도움말
            </button>
            <button id="btn-view-settings" onclick="openViewSettings()" class="text-tool-btn text-xs md:text-sm" title="보기 및 세부 설정 메뉴 열기">
                <span class="text-base">⚙️</span> 보기·설정
            </button>
        </div>`;

if (text.includes(targetHeaderButtons)) {
    text = text.replace(targetHeaderButtons, newHeaderButtons);
    console.log('1. Header toolbar deletion tools grouped successfully');
} else {
    console.warn('1. targetHeaderButtons not found');
}

// 2. Bottom Control Bar: Move select-delete button away and add revealed View Options Checkbox bar
const targetBottomControls = `<div class="playback-controls flex justify-between items-center gap-2 shrink-0">
            <div class="flex items-center gap-1.5">
                <button id="btn-tie-note" onclick="toggleTieMode()" class="text-tool-btn text-xs" title="붙임줄 만들기">
                    <span class="text-sm">⌒</span> 붙임줄
                </button>
                <button id="btn-delete-note" onclick="toggleDeleteMode()" class="text-tool-btn text-xs" title="선택 삭제 모드">
                    <span class="text-sm">🧽</span> <span id="delete-label">선택 삭제</span>
                </button>
            </div>`;

const newBottomControls = `<div class="playback-controls flex justify-between items-center gap-2 shrink-0 flex-wrap">
            <div class="flex items-center gap-2">
                <button id="btn-tie-note" onclick="toggleTieMode()" class="text-tool-btn text-xs" title="두 음표 연결 연주">
                    <span class="text-sm">⌒</span> 붙임줄
                </button>

                <!-- 하단에 드러난 보기 옵션 체크리스트 -->
                <div id="notationOptionsGroup" class="flex items-center gap-2.5 bg-white border-2 border-slate-200 rounded-xl px-2.5 py-1 text-xs font-bold text-slate-800 shadow-sm">
                    <span class="text-slate-400 font-black text-[11px]">👁️ 보기:</span>
                    <label class="flex items-center gap-1 cursor-pointer hover:text-blue-600">
                        <input type="checkbox" id="bottomVStyleToggle" onchange="setDisplayLayer('v', this.checked)" checked class="w-3.5 h-3.5 accent-blue-600 rounded">
                        <span>V자 리듬</span>
                    </label>
                    <label class="flex items-center gap-1 cursor-pointer hover:text-blue-600">
                        <input type="checkbox" id="bottomJeongganboToggle" onchange="setDisplayLayer('blocks', this.checked)" checked class="w-3.5 h-3.5 accent-blue-600 rounded">
                        <span>정간보</span>
                    </label>
                    <label class="flex items-center gap-1 cursor-pointer hover:text-blue-600">
                        <input type="checkbox" id="bottomAccentToggle" onchange="setDisplayLayer('accents', this.checked)" checked class="w-3.5 h-3.5 accent-blue-600 rounded">
                        <span>강약</span>
                    </label>
                </div>
            </div>`;

if (text.includes(targetBottomControls)) {
    text = text.replace(targetBottomControls, newBottomControls);
    console.log('2. Bottom control bar revealed view options added successfully');
} else {
    console.warn('2. targetBottomControls not found');
}

// 3. Settings Modal: Remove redundant HTML save button from activities section
const targetActivityBtns = `<div class="flex flex-col gap-2">
                    <button id="btn-stage-practice" type="button" onclick="closeViewSettings(); openPracticePanel();" class="w-full py-2.5 px-3 bg-white border border-slate-300 rounded-xl font-bold text-xs md:text-sm text-slate-800 hover:bg-blue-50 hover:border-blue-400 flex items-center gap-2 shadow-sm transition">
                        <span class="text-base">🎯</span> 단계별 연습 모드
                    </button>
                    <button id="btn-export-score" type="button" onclick="closeViewSettings(); downloadPlayableScoreHtml();" class="submission-download-btn transition" style="background:#4f46e5 !important; color:#ffffff !important;">
                        <span class="flex items-center gap-2 font-black text-sm text-white"><span class="text-base">📥</span> 완성 작품 제출하기 (파일 저장)</span>
                        <span class="text-xs bg-indigo-900 text-white px-2 py-1 rounded-md font-bold">HTML 저장</span>
                    </button>
                </div>`;

const newActivityBtns = `<div class="flex flex-col gap-2">
                    <button id="btn-stage-practice" type="button" onclick="closeViewSettings(); openPracticePanel();" class="w-full py-3 px-4 bg-gradient-to-r from-blue-600 to-indigo-600 text-white rounded-xl font-bold text-sm hover:from-blue-700 hover:to-indigo-700 flex items-center justify-between shadow-md transition">
                        <span class="flex items-center gap-2"><span class="text-base">🎯</span> 단계별 연습 모드 시작하기</span>
                        <span class="text-xs bg-white/20 px-2 py-0.5 rounded">시작 ▶</span>
                    </button>
                </div>`;

if (text.includes(targetActivityBtns)) {
    text = text.replace(targetActivityBtns, newActivityBtns);
    console.log('3. Redundant save button removed from settings modal');
} else {
    console.warn('3. targetActivityBtns not found');
}

// 4. setDisplayLayer function: Sync checkboxes bi-directionally
const targetSetDisplayLayer = `function setDisplayLayer(layer, enabled) {
            if (!(layer in displayLayers)) return;
            displayLayers[layer] = !!enabled;
            drawAll();
        }`;

const newSetDisplayLayer = `function setDisplayLayer(layer, enabled) {
            if (!(layer in displayLayers)) return;
            const val = !!enabled;
            displayLayers[layer] = val;

            const map = {
                v: ['viewToggleV', 'bottomVStyleToggle'],
                blocks: ['viewToggleBlocks', 'bottomJeongganboToggle'],
                accents: ['viewToggleAccents', 'bottomAccentToggle']
            };

            if (map[layer]) {
                map[layer].forEach(id => {
                    const el = document.getElementById(id);
                    if (el) el.checked = val;
                });
            }

            drawAll();
        }`;

if (text.includes(targetSetDisplayLayer)) {
    text = text.replace(targetSetDisplayLayer, newSetDisplayLayer);
    console.log('4. setDisplayLayer updated for bi-directional checkbox sync');
} else {
    console.warn('4. targetSetDisplayLayer not found');
}

// 5. Update tutorialSteps array to have clean, icon-by-icon steps
const targetTutorialSteps = `const tutorialSteps = [`;
const idxStepsStart = text.indexOf(targetTutorialSteps);
if (idxStepsStart > 0) {
    const idxStepsEnd = text.indexOf('];', idxStepsStart);
    if (idxStepsEnd > 0) {
        const endPos = idxStepsEnd + 2;
        const newTutorialSteps = `const tutorialSteps = [
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
                body: '두 음표를 이어 연주하고 싶다면 <strong>[⌒ 붙임줄]</strong> 버튼을 켠 후 <strong>연결할 음표 2개</strong>를 차례대로 클릭하세요.<br><small style="color: #64748b;">(첫 번째 음표 → 두 번째 음표 순서)</small>',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '4단계: ↩️ 되돌리기',
                body: '실수로 기호를 잘못 넣었을 때는 <strong>[↩️ 되돌리기]</strong>를 눌러 방금 입력한 <strong>마지막 기호 1개만 취소</strong>할 수 있어요.',
                anchor: 'undo',
                placement: 'bottom'
            },
            {
                title: '5단계: 🏷️ 선택 삭제 (또는 더블클릭)',
                body: '마디 중간의 <strong>특정 음표만 골라서 지우고 싶다면</strong> <strong>[🏷️ 선택 삭제]</strong>를 누르거나, <strong>악보 위 음표를 직접 더블클릭</strong>하세요!',
                anchor: 'delete',
                placement: 'bottom'
            },
            {
                title: '6단계: 🗑️ 전체 지우기',
                body: '현재 마디의 <strong>모든 기호를 한 번에 지우고</strong> 처음부터 다시 만들고 싶을 때 사용하세요.',
                anchor: 'clear',
                placement: 'bottom'
            },
            {
                title: '7단계: 내 리듬 들어보기',
                body: '악보를 만든 뒤 <strong>[▶ 이 마디 듣기]</strong>나 <strong>[▶▶ 전체 듣기]</strong>를 눌러 내가 만든 리듬을 소리로 들어보세요!',
                anchor: 'play',
                placement: 'top'
            },
            {
                title: '8단계: 👁️ 보기 옵션 조절',
                body: '하단 바의 체크박스에서 <strong>V자 리듬, 정간보, 강약(센박/여린박)</strong> 표기를 언제든지 켜고 끌 수 있어요!',
                anchor: '#notationOptionsGroup',
                placement: 'top'
            },
            {
                title: '9단계: 시작하기',
                body: '가이드 안내가 끝났습니다. 자유롭게 멋진 리듬을 창작해 보세요! 🎉',
                anchor: 'canvas',
                placement: 'center'
            }
        ];`;
        text = text.slice(0, idxStepsStart) + newTutorialSteps + text.slice(endPos);
        console.log('5. tutorialSteps updated with 9 clean icon-by-icon steps');
    }
}

fs.writeFileSync(filePath, text, 'utf8');
console.log('Patch req 3 finished successfully!');
