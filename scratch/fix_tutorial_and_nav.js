/**
 * fix_tutorial_and_nav.js
 *
 * Changes:
 * 1. 4단계 title: "부점 만들기" → "점 추가"
 *    body: "음표나 쉼표 길이의 절반(0.5)만큼 길이가 길어집니다."
 * 2. 3단계: 8분음표 1개 입력 (beat 1) → 4단계에서 dot 추가
 * 3. 4단계 onEnter: dot 후 16분음표 추가 → 2박 완성 (점8분+16분)
 * 4. 5단계: 셋잇단음표 3박 자리에 진짜로 3개 들어가게
 * 5. 6단계: 4박 자리에 8분음표(붙임줄) + 8분쉼표
 * 6. canvasNextMeasureBtn: 텍스트 "다음 마디" 제거, 오른쪽 화살표만, 이전 버튼 제거
 * 7. openHelpModal: showTutorial 대신 helpSimpleModal 표시 (이미 있음)
 *    → openHelpModal을 원래대로 복구
 */

const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

const replacements = [];

// ── 1. 4단계 title/body ──────────────────────────────────────────────
replacements.push([
    `title: '4단계: 점 ( . ) 부점 만들기',\r\n                body: '음표 입력 후 <strong>[ . ] (점)</strong> 버튼을 누르면 점음표로 바뀝니다. 원래 길이의 1.5배가 됩니다.',`,
    `title: '4단계: 점 추가',\r\n                body: '음표나 쉼표 길이의 절반(0.5)만큼 길이가 길어집니다.',`
]);

// ── 2. 3단계 onEnter: 8분음표 1개 입력 (beat 1) ─────────────────────
replacements.push([
    `title: '3단계: ♬ 16분음표 (1/4박) 연속 입력',\r\n                body: '<strong>16분음표</strong>를 입력합니다. 1박을 4등분한 길이입니다.',\r\n                anchor: 'noteRestButtons',\r\n                placement: 'top',\r\n                onEnter: () => {\r\n                    notes = notes.slice(0, 1);\r\n                    addNoteSmart('sixteenth', false);\r\n                    addNoteSmart('sixteenth', false);\r\n                    drawAll();\r\n                }`,
    `title: '3단계: 점음표 (점8분음표 + 16분음표)',\r\n                body: '8분음표에 점을 추가하면 점8분음표(0.75박)가 됩니다. 16분음표(0.25박)와 합쳐 2박이 완성됩니다.',\r\n                anchor: 'noteRestButtons',\r\n                placement: 'top',\r\n                onEnter: () => {\r\n                    notes = notes.slice(0, 1);\r\n                    addNoteSmart('eighth', false);\r\n                    drawAll();\r\n                }`
]);

// ── 3. 4단계 onEnter: dot 후 16분음표 추가 ──────────────────────────
replacements.push([
    `anchor: 'dotButton',\r\n                placement: 'top',\r\n                onEnter: () => {\r\n                    notes = notes.slice(0, 3);\r\n                    toggleLastDot();\r\n                    drawAll();\r\n                }`,
    `anchor: 'dotButton',\r\n                placement: 'top',\r\n                onEnter: () => {\r\n                    notes = notes.slice(0, 2);\r\n                    toggleLastDot();\r\n                    addNoteSmart('sixteenth', false);\r\n                    drawAll();\r\n                }`
]);

// ── 4. 5단계 onEnter: 셋잇단음표 3개 3박 자리에 ─────────────────────
replacements.push([
    `title: '5단계: 셋잇단음표 (1박 3분할)',\r\n                body: '<strong>셋잇단음표</strong>를 입력합니다. 1박을 3등분한 길이입니다.',\r\n                anchor: 'noteRestButtons',\r\n                placement: 'top',\r\n                onEnter: () => {\r\n                    if (!notes.some(n => n.type === 'triplet')) {\r\n                        addNoteSmart('triplet', false);\r\n                    }\r\n                    drawAll();\r\n                }`,
    `title: '5단계: 셋잇단음표 (1박 3분할)',\r\n                body: '<strong>셋잇단음표</strong>를 입력합니다. 1박을 3등분한 길이입니다.',\r\n                anchor: 'noteRestButtons',\r\n                placement: 'top',\r\n                onEnter: () => {\r\n                    // notes: [4분(0), 점8분(1), 16분(1.75)] → 3박(beat 2)에 셋잇단 추가\r\n                    notes = notes.slice(0, 3);\r\n                    // 셋잇단음표는 addNoteSmart('triplet') 한 번으로 3개 세트 삽입\r\n                    addNoteSmart('triplet', false);\r\n                    drawAll();\r\n                }`
]);

// ── 5. 6단계 onEnter: 4박에 8분음표(붙임줄) + 8분쉼표 ──────────────
replacements.push([
    `title: '6단계: ⌒ 붙임줄 연결하기',\r\n                body: '<strong>붙임줄</strong>로 연결된 두 음표는 한 번에 이어서 연주됩니다.',\r\n                anchor: 'tie',\r\n                placement: 'top',\r\n                onEnter: () => {\r\n                    if (notes.length >= 2) {\r\n                        notes[0].tied = true;\r\n                        notes[0].tiedTo = {measureIndex: activeMeasureIndex, noteIndex: 1};\r\n                        notes[1].tiedSource = {measureIndex: activeMeasureIndex, noteIndex: 0};\r\n                    }\r\n                    drawAll();\r\n                }`,
    `title: '6단계: ⌒ 붙임줄 연결하기',\r\n                body: '<strong>붙임줄</strong>로 연결된 두 음표는 한 번에 이어서 연주됩니다. 8분쉼표도 함께 넣을 수 있습니다.',\r\n                anchor: 'tie',\r\n                placement: 'top',\r\n                onEnter: () => {\r\n                    // notes: [4분(0), 점8분(1), 16분(1.75), 셋잇단×3(2~3)]\r\n                    // 4박(beat 3)에 8분음표(붙임줄) + 8분쉼표 추가\r\n                    notes = notes.slice(0, 6);\r\n                    // 8분음표 at beat 3\r\n                    addNoteSmart('eighth', false);\r\n                    // 8분쉼표 at beat 3.5\r\n                    addNoteSmart('eighth', true);\r\n                    // 마지막 전 음표(8분음표)에 붙임줄 설정\r\n                    const tieIdx = notes.length - 2;\r\n                    if (tieIdx >= 0 && notes[tieIdx] && !notes[tieIdx].isRest) {\r\n                        notes[tieIdx].tied = true;\r\n                    }\r\n                    drawAll();\r\n                }`
]);

// ── 6. canvasArea: 이전 마디 버튼 제거, 다음 버튼 화살표만 ──────────
replacements.push([
    `<button id="canvasPrevMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex - 1)" class="absolute left-2 top-1/2 -translate-y-1/2 z-30 bg-white/90 hover:bg-blue-600 hover:text-white border-2 border-slate-300 text-slate-700 font-extrabold px-2 py-3 rounded-xl shadow-md transition-all text-sm flex flex-col items-center gap-1 opacity-80 hover:opacity-100" title="이전 마디로 이동">\r\n            <span>◀</span>\r\n            <span class="text-[10px] [writing-mode:vertical-lr]">이전</span>\r\n        </button>\r\n        <button id="canvasNextMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex + 1)" class="absolute right-2 top-1/2 -translate-y-1/2 z-30 bg-blue-600 hover:bg-blue-700 text-white font-extrabold px-2.5 py-3 rounded-xl shadow-lg transition-all text-sm flex flex-col items-center gap-1" title="다음 마디로 이동">\r\n            <span>➔</span>\r\n            <span class="text-[11px] [writing-mode:vertical-lr]">다음 마디</span>\r\n        </button>`,
    `<button id="canvasNextMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex + 1)" class="absolute right-3 top-1/2 -translate-y-1/2 z-30 bg-blue-600/90 hover:bg-blue-700 text-white font-extrabold w-9 h-12 rounded-xl shadow-lg transition-all text-xl flex items-center justify-center" title="다음 마디로 이동">›</button>`
]);

// ── 7. openHelpModal: showTutorial → helpSimpleModal 열기 ────────────
replacements.push([
    `function openHelpModal() {\r\n            showTutorial(true);\r\n        }`,
    `function openHelpModal() {\r\n            const modal = document.getElementById('helpSimpleModal');\r\n            if (modal) modal.classList.add('show');\r\n        }`
]);

// Apply all replacements
let count = 0;
for (const [from, to] of replacements) {
    if (text.includes(from)) {
        text = text.replace(from, to);
        count++;
    } else {
        console.warn('NOT FOUND:', from.slice(0, 80));
    }
}

fs.writeFileSync(filePath, text, 'utf8');
console.log(`Done. ${count}/${replacements.length} replacements applied.`);

// Verify structure
const check = fs.readFileSync(filePath, 'utf8');
const htmlTags = (check.match(/<html/g) || []).length;
console.log('html tags:', htmlTags, '(should be 1)');
