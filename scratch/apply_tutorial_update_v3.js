const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

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
                body: '16분음표(0.25박)를 추가하여 점8분음표와 합쳐 1박을 완성합니다.',
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
                body: '음표 2개를 연속으로 클릭하면 붙임줄로 연결되어 이어서 연주됩니다. 3박 셋잇단음표의 마지막과 4박 첫 음표를 붙임줄로 연결합니다.',
                anchor: 'tie',
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
                title: '7단계: 음표 선택 삭제 & 쉼표 변환',
                body: '<strong>[🏷️ 선택 삭제]</strong> 버튼을 누르거나 음표를 지우고 필요 시 그 자리에 쉼표(8분쉼표)를 입력할 수 있습니다.',
                anchor: '#btn-delete-note',
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
                title: '9단계: ▶ 현재 마디 들어보기',
                body: '<strong>[▶ 이 마디 듣기]</strong>를 눌러 입력한 현재 마디의 리듬을 들어봅니다.',
                anchor: 'play',
                placement: 'top',
                onEnter: () => {
                    if (!isPlaying) playCurrentMeasure();
                }
            },
            {
                title: '10단계: ➕ 마디 이동 및 연속 리듬 창작',
                body: '악보 오른쪽에 있는 <strong>[ 〉 ] 마디 이동 아이콘</strong>을 클릭하여 다음 마디로 이동하고 리듬을 계속 이어 만들 수 있습니다.',
                anchor: '#canvasNextMeasureBtn',
                placement: 'top',
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
                title: '11단계: ▶ 전체 듣기 & 실음 악기 변경',
                body: '<strong>전체 듣기</strong>는 1마디부터 끝까지 전체 마디를 연결해 연속 재생하는 기능입니다. 연주를 들으며 <strong>악기 소리(장구, eng과리, 피아노, 리코더 등)</strong>를 바꾸어 들어보세요!',
                anchor: '#playAllBtn',
                placement: 'top',
                onEnter: () => {
                    if (!isPlaying) playAllMeasures();
                }
            },
            {
                title: '12단계: 직접 리듬 창작하기',
                body: '시범이 끝났습니다. 이제 자유롭게 나만의 리듬을 창작해 보세요.',
                anchor: 'canvas',
                placement: 'center',
                onEnter: () => {
                    if (isPlaying) stopPerformance();
                    switchMeasure(0);
                }
            }
        ];
        `;

    text = text.slice(0, tStart) + updatedTutorialCode + text.slice(tEnd);
    fs.writeFileSync(filePath, text, 'utf8');
    console.log('Tutorial steps updated successfully!');
} else {
    console.error('Tutorial markers not found!');
}
