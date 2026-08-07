const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. 점(.) 셀에 id="dotButton" 부여
text = text.replace(
    '<div class="guide-cell bg-white" onclick="toggleLastDot()">',
    '<div id="dotButton" class="guide-cell bg-white" onclick="toggleLastDot()">'
);

// 2. 하단 플레이 버튼 정중앙 정렬 및 출처 문구 완벽 정리
const oldFooterBlock = `<div class="play-buttons h-9 md:h-10 shrink-0">
            <div id="playbackControlsBtnsContainer" class="flex items-center gap-2 flex-1">
            <button id="playBtn" onclick="togglePlay()" class="flex-1 bg-amber-600 hover:bg-amber-700 text-white rounded-xl shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                <span class="current-play-icon">▶</span> 이 마디 듣기 (♩ = 60)
            </button>
            <button id="playAllBtn" onclick="toggleProjectPlay()" class="flex-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                <span class="project-play-icon">▶▶</span> 전체 듣기
            </button>
        </div>

        <div class="mt-1 pt-1 border-t border-slate-200 text-center shrink-0">
            <p class="text-[10px] md:text-xs text-slate-500 font-medium">
                제작: <a href="http://joo.is/미래형교사" target="_blank" rel="noopener noreferrer" class="underline hover:text-blue-600 font-bold">오한나</a> · 
                / 악기 음원 출처: <a href="https://www.gugak.go.kr" target="_blank" rel="noopener" class="underline hover:text-blue-600">국립국악원</a> · 
                우드블록: <a href="https://freesound.org/people/hollandm/" target="_blank" rel="noopener" class="underline hover:text-blue-600">hollandm/Freesound (CC0)</a> · 
                드럼: <a href="https://freesound.org/people/menegass/" target="_blank" rel="noopener" class="underline hover:text-blue-600">menegass/Freesound (CC0)</a>
            </p>
        </div>`;

const newFooterBlock = `<div id="playbackControlsBtnsContainer" class="play-buttons h-9 md:h-10 shrink-0 flex items-center justify-center gap-3 w-full">
            <button id="playBtn" onclick="togglePlay()" class="flex-1 max-w-xs bg-amber-600 hover:bg-amber-700 text-white rounded-xl shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                <span class="current-play-icon">▶</span> 이 마디 듣기 (♩ = 60)
            </button>
            <button id="playAllBtn" onclick="toggleProjectPlay()" class="flex-1 max-w-xs bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                <span class="project-play-icon">▶▶</span> 전체 듣기
            </button>
        </div>

        <div class="mt-1 pt-1 border-t border-slate-200 text-center shrink-0">
            <p class="text-[10px] md:text-xs text-slate-500 font-medium">
                제작: <a href="http://joo.is/미래형교사" target="_blank" rel="noopener noreferrer" class="underline hover:text-blue-600 font-bold">오한나</a> · 음원 출처: <a href="https://www.gugak.go.kr" target="_blank" rel="noopener" class="underline hover:text-blue-600">국립국악원</a> / <a href="https://freesound.org" target="_blank" rel="noopener" class="underline hover:text-blue-600">Freesound</a>
            </p>
        </div>`;

text = text.replace(oldFooterBlock, newFooterBlock);

// 3. 마디 1, 마디 2, 마디 3, 마디 4 글자가 확실하게 들어간 탭 버튼으로 HTML 교체
const oldTabsHtml = `<button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디"><i class="measure-status" aria-hidden="true"></i></button>`;

const newTabsHtml = `<button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디"><span>마디 1</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디"><span>마디 2</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디"><span>마디 3</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디"><span>마디 4</span></button>`;

text = text.replace(oldTabsHtml, newTabsHtml);

// 4. getTutorialAnchor에서 dotButton 타깃 정밀화
text = text.replace(
    `if (anchor === 'dotButton') {
                return Array.from(document.querySelectorAll('.guide-cell[onclick]')).find(el => (el.getAttribute('onclick') || '').includes('toggleLastDot'));
            }`,
    `if (anchor === 'dotButton' || anchor === '#dotButton') {
                return document.getElementById('dotButton') || Array.from(document.querySelectorAll('.guide-cell[onclick]')).find(el => (el.getAttribute('onclick') || '').includes('toggleLastDot'));
            }`
);

fs.writeFileSync(filePath, text, 'utf8');
console.log('Update script v11 written and applied successfully!');
