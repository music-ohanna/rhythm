const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. Update tutorialSteps array with live-action demo handlers
const targetStepsStart = 'const tutorialSteps = [';
const idxStepsStart = text.indexOf(targetStepsStart);
if (idxStepsStart > 0) {
    const idxStepsEnd = text.indexOf('];', idxStepsStart);
    if (idxStepsEnd > 0) {
        const endPos = idxStepsEnd + 2;
        const newTutorialSteps = `const tutorialSteps = [
            {
                title: '1단계: 4/4박자 시범 리듬 창작',
                body: '지금부터 앱이 직접 음표를 넣으며 리듬을 만드는 시범을 보여드립니다!',
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
                title: '3단계: ♬ 16분음표 (1/4박) 연속 입력',
                body: '<strong>16분음표</strong>를 눌러 촘촘하고 리드미컬한 소리를 넣습니다.',
                anchor: 'noteRestButtons',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 1);
                    addNoteSmart('sixteenth', false);
                    addNoteSmart('sixteenth', false);
                    drawAll();
                }
            },
            {
                title: '4단계: 점 ( . ) 부점 만들기',
                body: '음표 입력 후 <strong>[ . ] (점)</strong> 버튼을 누르면 점음표(부점 리듬)로 변합니다.',
                anchor: 'dotButton',
                placement: 'top',
                onEnter: () => {
                    notes = notes.slice(0, 3);
                    toggleLastDot();
                    drawAll();
                }
            },
            {
                title: '5단계: 셋잇단음표 (1박 3분할)',
                body: '<strong>셋잇단음표</strong> 버튼을 누르면 1박을 3등분한 화려한 리듬이 들어갑니다.',
                anchor: 'noteRestButtons',
                placement: 'top',
                onEnter: () => {
                    if (!notes.some(n => n.type === 'triplet')) {
                        addNoteSmart('triplet', false);
                    }
                    drawAll();
                }
            },
            {
                title: '6단계: ⌒ 붙임줄 연결하기',
                body: '<strong>[⌒ 붙임줄]</strong> 기능으로 두 음표를 이어서 부드럽게 연주할 수 있어요.',
                anchor: 'tie',
                placement: 'top',
                onEnter: () => {
                    if (notes.length >= 2) {
                        notes[0].tied = true;
                        notes[0].tiedTo = {measureIndex: activeMeasureIndex, noteIndex: 1};
                        notes[1].tiedSource = {measureIndex: activeMeasureIndex, noteIndex: 0};
                    }
                    drawAll();
                }
            },
            {
                title: '7단계: ♩ = 80 빠르기 조절',
                body: '빠르기 슬라이더를 이동해 연주 속도를 <strong>♩ = 80</strong>으로 신나게 높여봅니다.',
                anchor: '#tempoSlider',
                placement: 'top',
                onEnter: () => {
                    setTempo(80);
                    const slider = document.getElementById('tempoSlider');
                    if (slider) slider.value = 80;
                }
            },
            {
                title: '8단계: ▶ 완성된 리듬 들어보기!',
                body: '<strong>[▶ 이 마디 듣기]</strong>를 눌러 완성된 시범 리듬을 들어봅니다!',
                anchor: 'play',
                placement: 'top',
                onEnter: () => {
                    if (!isPlaying) playCurrentMeasure();
                }
            },
            {
                title: '9단계: 직접 리듬 창작하기',
                body: '시범이 완료되었습니다! 이제 자유롭게 나만의 멋진 리듬을 만들어 보세요! 🎉',
                anchor: 'canvas',
                placement: 'center',
                onEnter: () => {
                    if (isPlaying) stopPerformance();
                }
            }
        ];`;
        text = text.slice(0, idxStepsStart) + newTutorialSteps + text.slice(endPos);
        console.log('1. tutorialSteps updated with live actions');
    }
}

// 2. Update renderTutorialStep to execute step.onEnter
const targetRenderStep = `function renderTutorialStep() {
            if (!el.overlay) return;
            const step = tutorialSteps[tutorialIndex];`;

const newRenderStep = `function renderTutorialStep() {
            const el = getTutorialElements();
            if (!el.overlay) return;
            const step = tutorialSteps[tutorialIndex];
            if (step && typeof step.onEnter === 'function') {
                try { step.onEnter(); } catch(e) { console.warn('Tutorial step action error:', e); }
            }`;

if (text.includes('function renderTutorialStep() {')) {
    const idx = text.indexOf('function renderTutorialStep() {');
    const end = text.indexOf('requestAnimationFrame(positionTutorialCard);', idx) + 45;
    const endFn = text.indexOf('}', end) + 1;
    const replacement = `function renderTutorialStep() {
            const el = getTutorialElements();
            if (!el.overlay) return;
            const step = tutorialSteps[tutorialIndex];
            if (step && typeof step.onEnter === 'function') {
                try { step.onEnter(); } catch(e) { console.warn('Tutorial step action error:', e); }
            }
            el.count.textContent = \`\${tutorialIndex + 1} / \${tutorialSteps.length}\`;
            el.title.textContent = step.title;
            el.body.innerHTML = step.body;
            el.prev.disabled = tutorialIndex === 0;
            el.next.textContent = tutorialIndex === tutorialSteps.length - 1 ? '시작하기' : '다음';
            hideTutorialNotationPreview();
            requestAnimationFrame(positionTutorialCard);
        }`;
    text = text.slice(0, idx) + replacement + text.slice(endFn);
    console.log('2. renderTutorialStep updated to execute onEnter actions');
}

// 3. Make openHelpModal call showTutorial(true) directly
const targetOpenHelp = `function openHelpModal() {
            const modal = document.getElementById('helpSimpleModal');
            if (modal) modal.classList.add('show');
        }`;

const newOpenHelp = `function openHelpModal() {
            showTutorial(true);
        }`;

if (text.includes(targetOpenHelp)) {
    text = text.replace(targetOpenHelp, newOpenHelp);
    console.log('3. openHelpModal updated to launch interactive tutorial tour');
}

fs.writeFileSync(filePath, text, 'utf8');
console.log('Done live-action tutorial patch!');
