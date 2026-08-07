const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. 하단 옵션 구역 눈알 아이콘(👁️) 제거
text = text.replace(
    '<span class="text-slate-400 font-extrabold text-[11px] mr-0.5">👁️</span>',
    ''
);

// 2. 마디 탭 HTML (마디 1, 마디 2, 마디 3, 마디 4 글자 칩 형태 적용)
const oldNavHtml = `<button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디"><i class="measure-status" aria-hidden="true"></i></button>`;

const newNavHtml = `<button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디"><span class="measure-label-text">마디 1</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디"><span class="measure-label-text">마디 2</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디"><span class="measure-label-text">마디 3</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디"><span class="measure-label-text">마디 4</span></button>`;

text = text.replace(oldNavHtml, newNavHtml);

// 3. 마디 탭 CSS 개선 (.measure-tab 및 .measure-tabs)
const oldTabCss = `.measure-tabs { display:flex; align-items:center; justify-content:center; gap:16px; }
        .measure-tab {
            width:32px; height:32px; min-height:32px; padding:0; border:2px solid #94a3b8; border-radius:9999px;
            background:#ffffff; cursor:pointer; display:flex; align-items:center; justify-content:center;
            touch-action:manipulation; transition: all 0.18s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .measure-tab:hover { border-color:#2563eb; transform:scale(1.15); }
        .measure-tab.active { background:#2563eb; border-color:#1d4ed8; box-shadow:0 0 0 4px rgba(37,99,235,.25); transform:scale(1.25); }
        .measure-tab.complete:not(.active) { background:#22c55e; border-color:#16a34a; }
        .measure-tab.partial:not(.active) { background:#f59e0b; border-color:#d97706; }
        .measure-status { width:8px; height:8px; flex:0 0 8px; border-radius:9999px; background:transparent; }
        .measure-tab.active .measure-status { background:#ffffff; }`;

const newTabCss = `.measure-tabs { display:flex; align-items:center; justify-content:center; gap:8px; }
        .measure-tab {
            height:30px; padding:0 12px; border:1.5px solid #cbd5e1; border-radius:12px;
            background:#f8fafc; color:#475569; font-size:12px; font-weight:800; cursor:pointer;
            display:flex; align-items:center; justify-content:center; gap:4px;
            touch-action:manipulation; transition: all 0.18s ease;
        }
        .measure-tab:hover { border-color:#2563eb; color:#1d4ed8; background:#eff6ff; }
        .measure-tab.active { background:#2563eb; color:#ffffff; border-color:#1d4ed8; font-weight:900; box-shadow:0 2px 6px rgba(37,99,235,.3); }
        .measure-tab.complete:not(.active) { background:#f0fdf4; color:#166534; border-color:#86efac; }
        .measure-tab.partial:not(.active) { background:#fffbeb; color:#92400e; border-color:#fde68a; }`;

text = text.replace(oldTabCss, newTabCss);

// 4. 튜토리얼 팝업 카드가 떠 있을 때 카드 외부 영역 클릭 시 closeTutorial() 실행 추가
const initTutorialMarker = `el.skip.addEventListener('click', closeTutorial);`;
if (!text.includes('document.addEventListener(\'pointerdown\', (e) => {')) {
    const extraClickListener = `document.addEventListener('pointerdown', (e) => {
                if (!el.overlay || !el.overlay.classList.contains('show')) return;
                const card = el.card;
                if (card && !card.contains(e.target) && !e.target.closest('#tutorialCard')) {
                    closeTutorial();
                }
            }, true);\n            `;
    text = text.replace(initTutorialMarker, extraClickListener + initTutorialMarker);
}

// 5. tutorialSteps 갱신 (2~4단계 연출 조율, 4단계 보존, 드래그 설명 포함)
const tutorialMarkerStart = 'const tutorialSteps = [';
const tutorialMarkerEnd = 'let tutorialIndex = 0;';

const tStart = text.indexOf(tutorialMarkerStart);
const tEnd = text.indexOf(tutorialMarkerEnd, tStart);

if (tStart > 0 && tEnd > tStart) {
    const updatedTutorialCode = `const tutorialSteps = [
            {
                title: '리듬 창작 앱 도우미입니다.',
                body: '앱 사용법을 제가 직접 리듬 창작하며 보여드릴게요.',
                anchor: 'canvas',
                placement: 'center',
                onEnter: () => {
                    notes = [];
                    scoreMeasures[activeMeasureIndex] = notes;
                    drawAll();
                }
            },
            {
                title: '1단계: ♩ 4분음표 (1박) 입력',
                body: '저는 <strong>4분음표</strong>를 클릭해 보겠습니다. (입력표의 음표를 악보 위로 직접 드래그하여 올려놓을 수도 있습니다.)',
                anchor: '#btn-note-quarter',
                placement: 'top',
                onEnter: () => {
                    notes = [];
                    addNoteSmart('quarter', false);
                    drawAll();
                }
            },
            {
                title: '2단계: 점음표',
                body: '음표나 쉼표를 입력하고 점을 클릭하면 절반(0.5)만큼 길이가 길어집니다. 8분음표에 점을 붙여보겠습니다.',
                anchor: '#dotButton',
                placement: 'top',
                onEnter: () => {
                    notes = [];
                    addNoteSmart('quarter', false);
                    addNoteSmart('eighth', false);
                    drawAll();
                }
            },
            {
                title: '3단계: 16분음표 (1/4박) 입력',
                body: '<strong>16분음표</strong>를 클릭하여 점8분음표와 합쳐 1박을 만들어 보겠습니다.',
                anchor: '#btn-note-sixteenth',
                placement: 'top',
                onEnter: () => {
                    notes = [];
                    addNoteSmart('quarter', false);
                    addNoteSmart('eighth', false);
                    toggleLastDot();
                    addNoteSmart('sixteenth', false);
                    drawAll();
                }
            },
            {
                title: '4단계: 셋잇단음표 (1박 3분할)',
                body: '1박을 3등분하는 <strong>셋잇단음표</strong>를 클릭해 보겠습니다.',
                anchor: '#tripletNoteCell',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 3);
                    addNoteSmart('triplet', false);
                    drawAll();
                }
            },
            {
                title: '5단계: ⌒ 붙임줄 연결하기',
                body: '<strong>붙임줄로 연결해 보겠습니다.</strong> 3박 셋잇단음표의 마지막 음표와 4박 첫 음표가 붙임줄로 연결되는 화면을 확인해 보세요.',
                anchor: '#btn-tie-note',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 6);
                    addNoteSmart('eighth', false);
                    addNoteSmart('eighth', false);
                    if (notes[5] && notes[6]) {
                        notes[5].tied = true;
                        notes[6].tiedTo = true;
                    }
                    drawAll();
                    showToast('붙임줄을 만들었습니다.', true);
                }
            },
            {
                title: '6단계: 선택 삭제',
                body: '특정 구간의 음표나 쉼표를 지우고 싶으면 <strong>선택 삭제</strong>를 클릭해 보세요.',
                anchor: '#btn-delete-note',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 8);
                    drawAll();
                }
            },
            {
                title: '7단계: ➕ 마디 추가',
                body: '마디를 추가할 수 있습니다.',
                anchor: '#canvasNextMeasureBtn',
                placement: 'left',
                onEnter: () => {
                    if (isPlaying) stopPerformance();
                    switchMeasure(1);
                    notes = [];
                    scoreMeasures[1] = notes;
                    drawAll();
                }
            },
            {
                title: '8단계: ▶ 완성된 리듬 들어보기',
                body: '이제 <strong>[▶ 이 마디 듣기]</strong>나 <strong>[▶ 전체 듣기]</strong> 아이콘을 클릭하여 들어보세요.',
                anchor: 'play',
                placement: 'top',
                onEnter: () => {
                    if (isPlaying) stopPerformance();
                    switchMeasure(0);
                    drawAll();
                }
            },
            {
                title: '9단계: 표기 및 옵션 설정',
                body: '화면 아래의 <strong>V자 리듬, 정간보, 메트로놈, 악기</strong> 체크박스 및 드롭다운으로 원하는 표시만 켜거나 끌 수 있습니다.',
                anchor: '#bottomDisplayAndInstrumentOptions',
                placement: 'top'
            }
        ];
        `;

    text = text.slice(0, tStart) + updatedTutorialCode + text.slice(tEnd);
    fs.writeFileSync(filePath, text, 'utf8');
    console.log('Update script v9 written and applied successfully!');
} else {
    console.error('Tutorial markers not found!');
}
