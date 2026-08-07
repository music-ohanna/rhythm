const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. 하단 저작권 문구 치환 (정확한 Exact string matching)
const oldFooterTarget = `제작: 오한나 (<a href="mailto:muse@frano.kr" class="underline hover:text-blue-600">muse@frano.kr</a>) · 
                국립국악원: <a href="https://www.gugak.go.kr" target="_blank" rel="noopener" class="underline hover:text-blue-600">국립국악원</a> · 
                우드블록: <a href="https://freesound.org/people/hollandm/" target="_blank" rel="noopener" class="underline hover:text-blue-600">hollandm/Freesound (CC0)</a> · 
                드럼: <a href="https://freesound.org/people/menegass/" target="_blank" rel="noopener" class="underline hover:text-blue-600">menegass/Freesound (CC0)</a>`;

const newFooterHtml = `제작: <a href="http://joo.is/미래형교사" target="_blank" rel="noopener noreferrer" class="underline hover:text-blue-600 font-bold">오한나</a> / 악기 음원 출처: <a href="https://www.gugak.go.kr" target="_blank" rel="noopener" class="underline hover:text-blue-600">국립국악원</a>, <a href="https://freesound.org" target="_blank" rel="noopener" class="underline hover:text-blue-600">hollandm, menegass / Freesound (CC0)</a>`;

if (text.includes('muse@frano.kr')) {
    text = text.replace(
        '제작: 오한나 (<a href="mailto:muse@frano.kr" class="underline hover:text-blue-600">muse@frano.kr</a>)',
        '제작: <a href="http://joo.is/미래형교사" target="_blank" rel="noopener noreferrer" class="underline hover:text-blue-600 font-bold">오한나</a>'
    );
    text = text.replace(
        '국악 음원:',
        '/ 악기 음원 출처:'
    );
    text = text.replace(
        `우드블록: <a href="https://freesound.org/people/hollandm/" target="_blank" rel="noopener" class="underline hover:text-blue-600">hollandm/Freesound (CC0)</a> · \n                드럼: <a href="https://freesound.org/people/menegass/" target="_blank" rel="noopener" class="underline hover:text-blue-600">menegass/Freesound (CC0)</a>`,
        `<a href="https://freesound.org" target="_blank" rel="noopener" class="underline hover:text-blue-600">hollandm, menegass / Freesound (CC0)</a>`
    );
}

// 2. 음표 셀 ID 부여 (btn-note-quarter, btn-note-eighth, btn-note-sixteenth)
if (!text.includes('id="btn-note-quarter"')) {
    text = text.replace(
        '<div class="guide-cell bg-white" onclick="addNoteSmart(\'quarter\', false)">',
        '<div id="btn-note-quarter" class="guide-cell bg-white" onclick="addNoteSmart(\'quarter\', false)">'
    );
}
if (!text.includes('id="btn-note-eighth"')) {
    text = text.replace(
        '<div class="guide-cell bg-white" onclick="addNoteSmart(\'eighth\', false)">',
        '<div id="btn-note-eighth" class="guide-cell bg-white" onclick="addNoteSmart(\'eighth\', false)">'
    );
}
if (!text.includes('id="btn-note-sixteenth"')) {
    text = text.replace(
        '<div class="guide-cell bg-white" onclick="addNoteSmart(\'sixteenth\', false)">',
        '<div id="btn-note-sixteenth" class="guide-cell bg-white" onclick="addNoteSmart(\'sixteenth\', false)">'
    );
}

// 3. 캔버스 마디 추가 (+) 버튼 스타일 및 화살표 제거
// canvasPrevMeasureBtn 제거
text = text.replace(
    /<button id="canvasPrevMeasureBtn"[\s\S]*?<\/button>\s*/,
    ''
);

// canvasNextMeasureBtn (+) 단독 버튼화 (배경/테두리 제거, text-4xl 크기)
text = text.replace(
    /<button id="canvasNextMeasureBtn"[\s\S]*?<\/button>/,
    '<button id="canvasNextMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex + 1)" class="absolute right-2 top-1/2 -translate-y-1/2 z-30 text-blue-600 hover:text-blue-800 font-black text-4xl cursor-pointer p-0 bg-transparent border-0 outline-none hover:scale-110 active:scale-95 transition-transform" title="마디 추가">➕</button>'
);

// 4. V자 리듬 ~ 악기 선택까지 감싸는 그룹 ID bottomDisplayAndInstrumentOptions 적용
if (!text.includes('id="bottomDisplayAndInstrumentOptions"')) {
    const searchTarget = `<div id="bottomDisplayOptions" class="flex flex-wrap items-center gap-3">`;
    const replacement = `<div id="bottomDisplayAndInstrumentOptions" class="flex flex-wrap items-center gap-3">\n            <div id="bottomDisplayOptions" class="flex flex-wrap items-center gap-3">`;
    text = text.replace(searchTarget, replacement);

    text = text.replace(
        '</select>\n            </label>',
        '</select>\n            </label>\n            </div>'
    );
}

// 5. getTutorialAnchor에 bottomDisplayAndInstrumentOptions 추가
const getAnchorMarker = 'if (anchor === \'dotButton\') {';
const anchorIdx = text.indexOf(getAnchorMarker);
if (anchorIdx > 0 && !text.includes('bottomDisplayAndInstrumentOptions')) {
    const extraAnchorCode = `if (anchor === 'bottomDisplayAndInstrumentOptions') {
                return document.getElementById('bottomDisplayAndInstrumentOptions');
            }\n            `;
    text = text.slice(0, anchorIdx) + extraAnchorCode + text.slice(anchorIdx);
}

// 6. tutorialSteps 정밀 교체
const tutorialMarkerStart = 'const tutorialSteps = [';
const tutorialMarkerEnd = 'let tutorialIndex = 0;';

const tStart = text.indexOf(tutorialMarkerStart);
const tEnd = text.indexOf(tutorialMarkerEnd, tStart);

if (tStart > 0 && tEnd > tStart) {
    const updatedTutorialCode = `const tutorialSteps = [
            {
                title: '환영합니다!',
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
                body: '저는 <strong>4분음표</strong>를 클릭해 보겠습니다.',
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
                    notes = notes.slice(0, 1);
                    addNoteSmart('eighth', false);
                    toggleLastDot();
                    drawAll();
                }
            },
            {
                title: '3단계: 16분음표 (1/4박) 입력',
                body: '<strong>16분음표</strong>를 클릭하여 점8분음표와 합쳐 1박을 만들어 보겠습니다.',
                anchor: '#btn-note-sixteenth',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 2);
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
                    addNoteSmart('quarter', false);
                    addNoteSmart('quarter', false);
                    addNoteSmart('eighth', false);
                    addNoteSmart('eighth', false);
                    addNoteSmart('eighth', false);
                    addNoteSmart('eighth', false);
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
    console.log('Update script v7 written and applied safely!');
} else {
    console.error('Tutorial markers not found!');
}
