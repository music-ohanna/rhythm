const fs = require('fs');
const path = require('path');

const finalIndexPath = path.join(__dirname, '..', 'final-rhythm', 'index.html');
const rootIndexPath = path.join(__dirname, '..', 'index.html');

let html = fs.readFileSync(finalIndexPath, 'utf8');

// 1. measure-tab 스타일 추가 및 내부에 글자 유지되도록 CSS 추가
const customTabStyle = `
        /* 마디 탭 알약 칩 스타일 오버라이드 */
        .measure-tabs .measure-tab {
            padding: 4px 14px !important;
            border-radius: 9999px !important;
            font-weight: 800 !important;
            font-size: 13px !important;
            border: 2px solid transparent !important;
            background-color: #e2e8f0 !important;
            color: #334155 !important;
            cursor: pointer !important;
            transition: all 0.15s ease !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
        }
        .measure-tabs .measure-tab:hover {
            background-color: #cbd5e1 !important;
            color: #0f172a !important;
        }
        .measure-tabs .measure-tab.active {
            background-color: #2563eb !important;
            color: #ffffff !important;
            border-color: #1d4ed8 !important;
            box-shadow: 0 2px 6px rgba(37, 99, 235, 0.35) !important;
        }
        .measure-tabs .measure-tab i.measure-status {
            display: none !important;
        }
        
        /* 하단 정중앙 듣기 버튼 푸터 스타일 */
        .play-buttons {
            display: flex !important;
            justify-content: center !important;
            align-items: center !important;
            width: 100% !important;
            margin-top: 4px !important;
            margin-bottom: 4px !important;
        }
        #playbackControlsBtnsContainer {
            display: flex !important;
            justify-content: center !important;
            align-items: center !important;
            gap: 12px !important;
            width: 100% !important;
            max-width: 600px !important;
            margin: 0 auto !important;
        }
`;

if (!html.includes('/* 마디 탭 알약 칩 스타일 오버라이드 */')) {
    html = html.replace('</style>', customTabStyle + '\n    </style>');
}

// 2. HTML 내 마디 탭 내용 변경 ('마디 1', '마디 2', '마디 3', '마디 4')
const oldTabsHtml = `<div class="measure-tabs" role="tablist" aria-label="편집할 마디 선택">
            <button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디"><i class="measure-status" aria-hidden="true"></i></button>
        </div>`;

const newTabsHtml = `<div class="measure-tabs flex gap-2 justify-center items-center" role="tablist" aria-label="편집할 마디 선택">
            <button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디">마디 1</button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디">마디 2</button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디">마디 3</button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디">마디 4</button>
        </div>`;

if (html.includes(oldTabsHtml)) {
    html = html.replace(oldTabsHtml, newTabsHtml);
} else {
    // regex 치환
    html = html.replace(/<div class="measure-tabs"[\s\S]*?<\/div>/, newTabsHtml);
}

// 3. 하단 play-buttons 구조 정중앙 및 넓은 버튼 오버라이드
const oldPlayButtonsHtml = `<div class="play-buttons h-9 md:h-10 shrink-0">
            <div id="playbackControlsBtnsContainer" class="flex items-center gap-2 flex-1">
            <button id="playBtn" onclick="togglePlay()" class="flex-1 bg-amber-600 hover:bg-amber-700 text-white rounded-xl shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                <span class="current-play-icon">▶</span> 이 마디 듣기 (♩ = 60)
            </button>
            <button id="playAllBtn" onclick="toggleProjectPlay()" class="flex-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                <span class="project-play-icon">▶▶</span> 전체 듣기
            </button>
        </div>`;

const newPlayButtonsHtml = `<div class="play-buttons h-10 md:h-12 shrink-0 my-1 flex justify-center items-center w-full">
            <div id="playbackControlsBtnsContainer" class="flex items-center justify-center gap-3 w-full max-w-xl mx-auto px-2">
                <button id="playBtn" onclick="togglePlay()" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-2 px-4 shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                    <span class="current-play-icon text-lg">▶</span> 이 마디 듣기 (♩ = 60)
                </button>
                <button id="playAllBtn" onclick="toggleProjectPlay()" class="flex-1 bg-teal-700 hover:bg-teal-800 text-white rounded-xl py-2 px-4 shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                    <span class="project-play-icon text-lg">▶▶</span> 전체 듣기
                </button>
            </div>
        </div>`;

if (html.includes(oldPlayButtonsHtml)) {
    html = html.replace(oldPlayButtonsHtml, newPlayButtonsHtml);
} else {
    // regex 치환
    html = html.replace(/<div class="play-buttons[\s\S]*?<\/div>\s*<\/div>/, newPlayButtonsHtml);
}

// 4. JS 코드 내에서 updateMeasureTabs()가 탭 버튼 text를 dot으로 덮어쓰지 않게 수정
// JS 내 switchMeasure 나 updateMeasureTabs 관련 logic 조사
html = html.replace(/tab\.innerHTML\s*=\s*['"`][^'"`]*['"`]/g, '// tab.innerHTML text preserved');
html = html.replace(/i\.className\s*=\s*['"`]measure-status[^'"`]*['"`]/g, '// status icon ignored');

fs.writeFileSync(finalIndexPath, html, 'utf8');
fs.writeFileSync(rootIndexPath, html, 'utf8');

console.log('Successfully updated both final-rhythm/index.html and root index.html!');
