const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. Header Toolbar Deletion Tools Grouping
const targetUndo = 'id="btn-undo"';
const idxUndo = text.indexOf(targetUndo);
if (idxUndo > 0) {
    const startDiv = text.lastIndexOf('<div', idxUndo);
    const endDiv = text.indexOf('</div>', text.indexOf('id="btn-view-settings"', idxUndo)) + 6;
    if (startDiv > 0 && endDiv > startDiv) {
        const replacement = `<div class="flex gap-1.5 items-center">
            <!-- 지우기/수정 도구 통합 그룹 -->
            <div class="flex gap-1 bg-slate-100/90 p-0.5 rounded-xl border border-slate-200 shadow-sm">
                <button id="btn-undo" onclick="undoLastAction()" class="text-tool-btn text-xs md:text-sm" title="방금 입력한 마지막 기호 취소">
                    <span class="text-base">↩️</span> 되돌리기
                </button>
                <button id="btn-delete-note" onclick="toggleDeleteMode()" class="text-tool-btn text-xs md:text-sm" title="특정 음표만 선택하여 지우기 (더블클릭 가능)">
                    <span class="text-base">🏷️</span> <span id="delete-label">선택 삭제</span>
                </button>
                <button id="btn-clear-all" onclick="confirmClear()" class="text-tool-btn text-xs md:text-sm" title="현재 마디의 모든 기호 지우기">
                    <span class="text-base">🗑️</span> 마디 비우기
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
        text = text.slice(0, startDiv) + replacement + text.slice(endDiv);
        console.log('1. Header deletion tools grouped successfully');
    }
}

// 2. Bottom Control Bar Revealed View Checkboxes
const targetTie = 'id="btn-tie-note"';
const idxTie = text.indexOf(targetTie);
if (idxTie > 0) {
    const startDiv = text.lastIndexOf('<div', idxTie);
    const endDiv = text.indexOf('</div>', text.indexOf('id="btn-delete-note"', idxTie)) + 6;
    if (startDiv > 0 && endDiv > startDiv) {
        const replacement = `<div class="flex items-center gap-2">
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
        text = text.slice(0, startDiv) + replacement + text.slice(endDiv);
        console.log('2. Bottom control bar view options added successfully');
    }
}

// 3. Remove Redundant Save Button from Settings Modal
const targetExport = 'id="btn-export-score"';
const idxExport = text.indexOf(targetExport);
if (idxExport > 0) {
    const startBtn = text.lastIndexOf('<button', idxExport);
    const endBtn = text.indexOf('</button>', idxExport) + 9;
    if (startBtn > 0 && endBtn > startBtn) {
        text = text.slice(0, startBtn) + text.slice(endBtn);
        console.log('3. Redundant save button removed from settings modal');
    }
}

// 4. setDisplayLayer Checkbox Sync
const targetFn = 'function setDisplayLayer(layer, enabled) {';
const idxFn = text.indexOf(targetFn);
if (idxFn > 0) {
    const endFn = text.indexOf('}', text.indexOf('drawAll()', idxFn)) + 1;
    if (endFn > idxFn) {
        const replacement = `function setDisplayLayer(layer, enabled) {
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
        text = text.slice(0, idxFn) + replacement + text.slice(endFn);
        console.log('4. setDisplayLayer updated for bi-directional checkbox sync');
    }
}

fs.writeFileSync(filePath, text, 'utf8');
console.log('Done exact patching!');
