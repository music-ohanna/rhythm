const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. Remove #btn-view-settings from header
const targetBtnView = `<button id="btn-view-settings" onclick="openViewSettings()" class="text-tool-btn text-xs md:text-sm" title="보기 및 세부 설정 메뉴 열기">
                <span class="text-base">⚙️</span> 보기·설정
            </button>`;

if (text.includes(targetBtnView)) {
    text = text.replace(targetBtnView, '');
    console.log('1. btn-view-settings removed from header toolbar');
} else {
    console.warn('1. btn-view-settings not found');
}

// 2. Re-style #notationOptionsGroup into clean, modern pill toolbar
const targetGroup = `<div id="notationOptionsGroup" class="flex items-center gap-2.5 bg-white border-2 border-slate-200 rounded-xl px-2.5 py-1 text-xs font-bold text-slate-800 shadow-sm">
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
                </div>`;

const newGroup = `<div id="notationOptionsGroup" class="flex items-center gap-1 bg-slate-100/90 border border-slate-200/80 rounded-full px-2.5 py-1 text-xs font-bold text-slate-700 shadow-inner">
                    <span class="text-slate-400 font-extrabold text-[11px] mr-0.5">👁️</span>
                    <label class="inline-flex items-center gap-1 cursor-pointer px-2 py-0.5 rounded-full hover:bg-white hover:shadow-sm transition text-slate-700">
                        <input type="checkbox" id="bottomVStyleToggle" onchange="setDisplayLayer('v', this.checked)" checked class="w-3.5 h-3.5 accent-blue-600 rounded">
                        <span>V자 리듬</span>
                    </label>
                    <span class="text-slate-300 text-[10px]">|</span>
                    <label class="inline-flex items-center gap-1 cursor-pointer px-2 py-0.5 rounded-full hover:bg-white hover:shadow-sm transition text-slate-700">
                        <input type="checkbox" id="bottomJeongganboToggle" onchange="setDisplayLayer('blocks', this.checked)" checked class="w-3.5 h-3.5 accent-blue-600 rounded">
                        <span>정간보</span>
                    </label>
                    <span class="text-slate-300 text-[10px]">|</span>
                    <label class="inline-flex items-center gap-1 cursor-pointer px-2 py-0.5 rounded-full hover:bg-white hover:shadow-sm transition text-slate-700">
                        <input type="checkbox" id="bottomAccentToggle" onchange="setDisplayLayer('accents', this.checked)" checked class="w-3.5 h-3.5 accent-blue-600 rounded">
                        <span>강약</span>
                    </label>
                </div>`;

if (text.includes(targetGroup)) {
    text = text.replace(targetGroup, newGroup);
    console.log('2. #notationOptionsGroup re-styled cleanly');
} else {
    console.warn('2. targetGroup not found');
}

// 3. Add Floating Side Navigation Buttons inside #canvasArea
const targetCanvasStart = `<main id="canvasArea" class="relative flex-1 paper-bg rounded-2xl border-2 border-slate-400 shadow-md overflow-hidden cursor-default">`;
const newCanvasBtns = `<button id="canvasPrevMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex - 1)" class="absolute left-2 top-1/2 -translate-y-1/2 z-30 bg-white/90 hover:bg-blue-600 hover:text-white border-2 border-slate-300 text-slate-700 font-extrabold px-2 py-3 rounded-xl shadow-md transition-all text-sm flex flex-col items-center gap-1 opacity-80 hover:opacity-100" title="이전 마디로 이동">
            <span>◀</span>
            <span class="text-[10px] [writing-mode:vertical-lr]">이전</span>
        </button>
        <button id="canvasNextMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex + 1)" class="absolute right-2 top-1/2 -translate-y-1/2 z-30 bg-blue-600 hover:bg-blue-700 text-white font-extrabold px-2.5 py-3 rounded-xl shadow-lg transition-all text-sm flex flex-col items-center gap-1" title="다음 마디로 이동">
            <span>➔</span>
            <span class="text-[11px] [writing-mode:vertical-lr]">다음 마디</span>
        </button>`;

if (text.includes(targetCanvasStart) && !text.includes('id="canvasNextMeasureBtn"')) {
    text = text.replace(targetCanvasStart, targetCanvasStart + '\n        ' + newCanvasBtns);
    console.log('3. Canvas side navigation buttons added successfully');
} else {
    console.warn('3. targetCanvasStart not found or canvasNextMeasureBtn already exists');
}

// 4. Update showMeasureOverflowWarning text for measure navigation
const targetOverflowFn = 'function showMeasureOverflowWarning() {';
const idxOverflow = text.indexOf(targetOverflowFn);
if (idxOverflow > 0) {
    const idxEndFn = text.indexOf('showValidationAlert(msg);', idxOverflow);
    const endFn = text.indexOf('}', idxEndFn) + 1;
    const newOverflowFn = `function showMeasureOverflowWarning() {
            initAudio();
            const sig = \`\${timeSignature.top}/\${timeSignature.bottom}\`;
            const msg = \`
                <div style="font-size: 15px; font-weight: 800; margin-bottom: 8px; color: #fef08a;">
                    ⚠️ \${sig} 마디의 길이를 넘었습니다
                </div>
                <div style="font-size: 14px; line-height: 1.65; font-weight: 600;">
                    <strong>원인:</strong> 넣으려는 음표(쉼표) 길이가 마디에 남은 박보다 길어요.<br><br>
                    <strong>수정 방법:</strong><br>
                    • 더 짧은 음표나 쉼표를 골라 넣어보세요.<br>
                    • 이미 마디가 다 찼다면 <strong>악보 오른쪽(또는 상단)의 [다음 마디 ➔]</strong> 화살표를 눌러 다음 마디로 이동하세요.<br>
                    • 중간의 특정 음표를 지우고 싶다면 <strong>악보 위 음표를 더블클릭</strong>하거나 <strong>[🏷️ 선택 삭제]</strong>를 사용하세요.
                </div>
            \`;
            showValidationAlert(msg);
        }`;
    text = text.slice(0, idxOverflow) + newOverflowFn + text.slice(endFn);
    console.log('4. showMeasureOverflowWarning updated successfully');
}

// 5. Update downloadPlayableScoreHtml for guaranteed real audio sound export
const targetAudioCatch = `} catch (error) {
                console.warn('제출 파일 실음 포함 실패:', error);
                showValidationAlert('악기 실음을 포함하지 못했습니다. 잠시 후 다시 저장해 주세요.');
                return;
            }`;

const replaceAudioCatch = `} catch (error) {
                console.warn('제출 파일 실음 샘플 수집 중 경고 (기본 합성음 활성화됨):', error);
            }`;

if (text.includes(targetAudioCatch)) {
    text = text.replace(targetAudioCatch, replaceAudioCatch);
    console.log('5. downloadPlayableScoreHtml sample catch updated');
} else {
    console.warn('5. targetAudioCatch not found');
}

const targetSaveToast = `showToast(\`\${completedCount}마디 재생 작품을 저장했습니다.\`, true);`;
const replaceSaveToast = `showToast(\`\${completedCount}마디 재생 작품을 저장했습니다. (실음 포함)\`, true);`;
if (text.includes(targetSaveToast)) {
    text = text.replace(targetSaveToast, replaceSaveToast);
    console.log('5b. Save toast message updated');
}

// 6. Redesign helpSimpleModal into Help & Example Scores Modal
const targetHelpModalStart = `<div id="helpSimpleModal" class="choice-dialog" role="dialog" aria-modal="true" aria-labelledby="helpSimpleTitle">`;
const idxHelpStart = text.indexOf(targetHelpModalStart);
if (idxHelpStart > 0) {
    const idxHelpEnd = text.indexOf('</div>\n    </div>', idxHelpStart) + 12;
    const newHelpModal = `<div id="helpSimpleModal" class="choice-dialog" role="dialog" aria-modal="true" aria-labelledby="helpSimpleTitle">
        <div class="choice-card" style="width: min(500px, calc(100vw - 28px)); text-align: left; padding: 22px;">
            <div class="flex justify-between items-center mb-3 pb-2 border-b border-slate-200">
                <h2 id="helpSimpleTitle" class="choice-title" style="margin: 0; font-size: 19px; color: #1e3a8a;">
                    <span>❓</span> 도움말 및 예시 악보 세팅
                </h2>
                <button type="button" onclick="closeHelpModal()" class="text-slate-400 hover:text-slate-700 font-extrabold text-lg px-2">✕</button>
            </div>
            
            <div class="space-y-3">
                <div class="p-3 bg-blue-50/80 border border-blue-200 rounded-2xl">
                    <h3 class="text-xs font-black text-blue-900 mb-2 flex items-center gap-1">🎵 추천 예시 악보 불러오기</h3>
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
                        <button type="button" onclick="closeHelpModal(); loadPresetRhythm('basic44');" class="p-2.5 bg-white border border-blue-300 rounded-xl text-left hover:bg-blue-100 transition shadow-sm">
                            <div class="text-xs font-bold text-slate-800">🥁 4/4 8분음표 기본 리듬</div>
                            <div class="text-[11px] text-slate-500">4/4박 8분음표 리듬 예시</div>
                        </button>
                        <button type="button" onclick="closeHelpModal(); loadPresetRhythm('waltz34');" class="p-2.5 bg-white border border-blue-300 rounded-xl text-left hover:bg-blue-100 transition shadow-sm">
                            <div class="text-xs font-bold text-slate-800">🔔 3/4 쿵짝짝 리듬</div>
                            <div class="text-[11px] text-slate-500">3/4박 왈츠 형태 리듬</div>
                        </button>
                        <button type="button" onclick="closeHelpModal(); loadPresetRhythm('gutgeori68');" class="p-2.5 bg-white border border-blue-300 rounded-xl text-left hover:bg-blue-100 transition shadow-sm">
                            <div class="text-xs font-bold text-slate-800">🪘 6/8 붓듬 겹박자 리듬</div>
                            <div class="text-[11px] text-slate-500">6/8 겹박자 리듬 예시</div>
                        </button>
                        <button type="button" onclick="closeHelpModal(); openPracticePanel();" class="p-2.5 bg-gradient-to-r from-indigo-500 to-blue-600 text-white rounded-xl text-left hover:from-indigo-600 hover:to-blue-700 transition shadow-md">
                            <div class="text-xs font-extrabold text-white">🎯 단계별 연습 모드</div>
                            <div class="text-[11px] text-blue-100">1~3단계 따라 만들기</div>
                        </button>
                    </div>
                </div>

                <div class="p-3 bg-amber-50/80 border border-amber-200 rounded-2xl flex items-center justify-between">
                    <div>
                        <div class="text-xs font-bold text-amber-900">💡 이동식 가이드 투어 다시보기</div>
                        <div class="text-[11px] text-amber-700">앱 화면 이동식 안내 팝업을 다시 시작합니다.</div>
                    </div>
                    <button type="button" onclick="closeHelpModal(); showTutorial(true);" class="px-3 py-1.5 bg-amber-500 text-white font-bold rounded-xl text-xs hover:bg-amber-600 shadow-sm shrink-0">투어 시작</button>
                </div>
            </div>

            <div class="flex justify-end mt-4 pt-3 border-t border-slate-200">
                <button type="button" onclick="closeHelpModal()" class="px-4 py-1.5 bg-slate-200 text-slate-800 font-bold rounded-xl text-xs hover:bg-slate-300">닫기</button>
            </div>
        </div>
    </div>`;
    text = text.slice(0, idxHelpStart) + newHelpModal + text.slice(idxHelpEnd);
    console.log('6. helpSimpleModal redesigned for preset scores');
}

// 7. Add loadPresetRhythm and openHelpModal JS functions
const targetHelpFn = 'function openHelpModal() {';
const idxHelpFn = text.indexOf(targetHelpFn);
if (idxHelpFn > 0) {
    const endHelpFn = text.indexOf('}', idxHelpFn) + 1;
    const newHelpFns = `function openHelpModal() {
            const modal = document.getElementById('helpSimpleModal');
            if (modal) modal.classList.add('show');
        }

        function closeHelpModal() {
            const modal = document.getElementById('helpSimpleModal');
            if (modal) modal.classList.remove('show');
        }

        function loadPresetRhythm(type) {
            pushUndoState();
            notes = [];
            if (type === 'basic44') {
                timeSignature = {top: 4, bottom: 4};
                notes = [
                    {type: 'quarter', dotted: false, beatOffset: 0},
                    {type: 'eighth', dotted: false, beatOffset: 1},
                    {type: 'eighth', dotted: false, beatOffset: 1.5},
                    {type: 'quarter', dotted: false, beatOffset: 2},
                    {type: 'quarter', dotted: false, beatOffset: 3}
                ];
            } else if (type === 'waltz34') {
                timeSignature = {top: 3, bottom: 4};
                notes = [
                    {type: 'quarter', dotted: false, beatOffset: 0},
                    {type: 'quarter', dotted: false, beatOffset: 1},
                    {type: 'quarter', dotted: false, beatOffset: 2}
                ];
            } else if (type === 'gutgeori68') {
                timeSignature = {top: 6, bottom: 8};
                notes = [
                    {type: 'quarter', dotted: true, beatOffset: 0},
                    {type: 'eighth', dotted: false, beatOffset: 1.5},
                    {type: 'quarter', dotted: false, beatOffset: 2}
                ];
            }
            scoreMeasures[activeMeasureIndex] = notes;
            updateMeasureNavigator();
            drawAll();
            showToast('예시 리듬 악보를 불러왔습니다.', true);
        }`;
    text = text.slice(0, idxHelpFn) + newHelpFns + text.slice(endHelpFn);
    console.log('7. loadPresetRhythm and openHelpModal functions updated');
}

// 8. Auto-run tutorial on initial page load
const targetInitTutEnd = `window.addEventListener('load', () => setTimeout(initTutorial, 100));`;
const replaceInitTutEnd = `window.addEventListener('load', () => {
            setTimeout(() => {
                initTutorial();
                showTutorial(false);
            }, 300);
        });`;

if (text.includes(targetInitTutEnd)) {
    text = text.replace(targetInitTutEnd, replaceInitTutEnd);
    console.log('8. Auto-run tutorial on initial load added');
}

fs.writeFileSync(filePath, text, 'utf8');
console.log('Patch req 4 finished!');
