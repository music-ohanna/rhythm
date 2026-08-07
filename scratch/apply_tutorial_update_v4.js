const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. 음표 세포들에 ID 추가
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

// 2. 옵션 체크박스 영역 감싸는 ID 추가
if (!text.includes('id="bottomDisplayOptions"')) {
    text = text.replace(
        '<!-- 하단에 드러난 보기 옵션 체크리스트 -->',
        '<!-- 하단에 드러난 보기 옵션 체크리스트 -->\n            <div id="bottomDisplayOptions" class="flex flex-wrap items-center gap-3">'
    );
    // 닫는 tag도 확인하여 추가
}

// 3. canvasNextMeasureBtn 아이콘 ➕ 지원
text = text.replace(
    'title="다음 마디로 이동">›</button>',
    'title="마디 추가 및 이동">➕</button>'
);

// 4. getTutorialAnchor 업데이트
const getAnchorMarker = 'if (anchor === \'dotButton\') {';
const anchorIdx = text.indexOf(getAnchorMarker);
if (anchorIdx > 0 && !text.includes('bottomDisplayOptions')) {
    const extraAnchorCode = `if (anchor === 'bottomVStyleToggle' || anchor === 'bottomDisplayOptions') {
                return document.getElementById('bottomDisplayOptions') || document.getElementById('bottomVStyleToggle');
            }\n            `;
    text = text.slice(0, anchorIdx) + extraAnchorCode + text.slice(anchorIdx);
}

// 5. tutorialSteps 교체
const tutorialMarkerStart = 'const tutorialSteps = [';
const tutorialMarkerEnd = 'let tutorialIndex = 0;';

const tStart = text.indexOf(tutorialMarkerStart);
const tEnd = text.indexOf(tutorialMarkerEnd, tStart);

if (tStart > 0 && tEnd > tStart) {
    const updatedTutorialCode = `const tutorialSteps = [
            {
                title: '1단계: 리듬 창작 앱 가이드',
                body: '이 앱의 사용법을 제가 직접 리듬 창작하며 보여드릴게요.',
                anchor: 'canvas',
                placement: 'center',
                onEnter: () => {
                    notes = [];
                    scoreMeasures[activeMeasureIndex] = notes;
                    drawAll();
                }
            },
            {
                title: '2단계: 표기 및 옵션 설정',
                body: '화면 아래의 <strong>V자 리듬, 정간보, 메트로놈</strong> 체크박스로 원하는 표시만 켜거나 끌 수 있습니다.',
                anchor: '#bottomVStyleToggle',
                placement: 'top'
            },
            {
                title: '3단계: ♩ 4분음표 (1박) 입력',
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
                title: '4단계: 점음표 (♩. 점8분음표)',
                body: '이번에는 8분음표를 누른 뒤 <strong>점(.) 버튼</strong>을 클릭해 보겠습니다. 원래 길이에 절반(0.5배)이 더해집니다.',
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
                title: '5단계: 16분음표 (1/4박) 입력',
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
                title: '6단계: 셋잇단음표 (1박 3분할)',
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
                title: '7단계: ⌒ 붙임줄 연결하기',
                body: '<strong>붙임줄로 연결해 보겠습니다.</strong> 3박 셋잇단음표의 마지막 음표와 4박 첫 음표가 붙임줄로 연결되는 화면을 확인해 보세요.',
                anchor: '#btn-tie-note',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 6);
                    addNoteSmart('eighth', false);
                    addNoteSmart('eighth', false);
                    if (notes[5] && !notes[5].isRest) {
                        notes[5].tied = true;
                    }
                    drawAll();
                }
            },
            {
                title: '8단계: 선택 삭제',
                body: '특정 구간의 음표나 쉼표를 지우고 싶으면 <strong>선택 삭제</strong>를 클릭해 보세요.',
                anchor: '#btn-delete-note',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 7);
                    addNoteSmart('eighth', true);
                    drawAll();
                }
            },
            {
                title: '9단계: ➕ 마디 추가 및 리듬 창작',
                body: '오른쪽에 있는 <strong>마디 추가 아이콘(➕)</strong>을 클릭하여 마디를 늘리고, 이어서 다른 리듬을 창작해 보세요.',
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
                title: '10단계: ▶ 완성된 리듬 들어보기',
                body: '이제 <strong>[▶ 이 마디 듣기]</strong>나 <strong>[▶ 전체 듣기]</strong> 아이콘을 클릭하여 들어보세요.',
                anchor: 'play',
                placement: 'top',
                onEnter: () => {
                    if (isPlaying) stopPerformance();
                    switchMeasure(0);
                    drawAll();
                }
            }
        ];
        `;

    text = text.slice(0, tStart) + updatedTutorialCode + text.slice(tEnd);
    fs.writeFileSync(filePath, text, 'utf8');
    console.log('Update script v4 written and applied!');
} else {
    console.error('Tutorial markers not found!');
}
