const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. 4분쉼표 쪼개짐 버그 수정 (addDurationAtOffset)
const oldAddDurationCode = `const splitPieces = splitAcrossStructuralBeatBoundary(newStart, duration);`;
const newAddDurationCode = `const splitPieces = isRest ? null : splitAcrossStructuralBeatBoundary(newStart, duration);`;

text = text.replace(oldAddDurationCode, newAddDurationCode);

// 2. playbackControlsBtnsContainer 감싸는 ID 추가 (8단계 재생 버튼 2개 모두 선택)
if (!text.includes('id="playbackControlsBtnsContainer"')) {
    text = text.replace(
        '<button id="playBtn" onclick="togglePlay()"',
        '<div id="playbackControlsBtnsContainer" class="flex items-center gap-2 flex-1">\n            <button id="playBtn" onclick="togglePlay()"'
    );
    text = text.replace(
        '</button>\n        </div>\n\n        <div class="mt-1 pt-1',
        '</button>\n            </div>\n        </div>\n\n        <div class="mt-1 pt-1'
    );
}

// 3. getTutorialAnchor에 playbackControlsBtnsContainer 및 bottomFullControlsContainer 등록
const getAnchorMarker = 'if (anchor === \'dotButton\') {';
const anchorIdx = text.indexOf(getAnchorMarker);
if (anchorIdx > 0 && !text.includes('playbackControlsBtnsContainer')) {
    const extraAnchorCode = `if (anchor === 'playbackControlsBtnsContainer') {
                return document.getElementById('playbackControlsBtnsContainer');
            }
            if (anchor === 'bottomFullControlsContainer') {
                return document.getElementById('bottomFullControlsContainer');
            }\n            `;
    text = text.slice(0, anchorIdx) + extraAnchorCode + text.slice(anchorIdx);
}

// 4. tutorialSteps 갱신
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
                title: '1단계: 음표나 쉼표 입력',
                body: '저는 <strong>4분음표</strong>를 클릭해 보겠습니다. (입력표의 음표나 쉼표를 악보 위로 직접 드래그하여 올려놓을 수도 있습니다.)',
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
                body: '음표나 쉼표를 선택한 뒤 <strong>점(.) 버튼</strong>을 누르면 원래 길이의 절반(0.5배)만큼 길어집니다. 8분음표에 점을 붙여보겠습니다.',
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
                body: '<strong>[▶ 이 마디 듣기]</strong>는 현재 마디만 연주합니다. 마디를 여러 개 추가하여 작품을 만들었을 때는 <strong>[▶▶ 전체 듣기]</strong>를 클릭하여 처음부터 끝까지 들어보세요!',
                anchor: '#playbackControlsBtnsContainer',
                placement: 'top',
                onEnter: () => {
                    if (isPlaying) stopPerformance();
                    switchMeasure(0);
                    drawAll();
                }
            },
            {
                title: '9단계: 표기 및 옵션 설정',
                body: '화면 아래의 <strong>V자 리듬, 정간보, 강약, 빠르기, 메트로놈, 악기</strong> 체크박스 및 컨트롤로 원하는 표시만 켜거나 끌 수 있습니다.',
                anchor: '#bottomFullControlsContainer',
                placement: 'top'
            }
        ];
        `;

    text = text.slice(0, tStart) + updatedTutorialCode + text.slice(tEnd);
    fs.writeFileSync(filePath, text, 'utf8');
    console.log('Update script v10 written and applied successfully!');
} else {
    console.error('Tutorial markers not found!');
}
