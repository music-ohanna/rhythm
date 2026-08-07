import os

filepath = os.path.join(os.path.dirname(__file__), "..", "index.html")

with open(filepath, "r", encoding="utf-8") as f:
    text = f.read()

# 1. Logo clickable
target1 = 'class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center">'
replace1 = 'onclick="openNewScreenModal()" class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center cursor-pointer hover:opacity-80 transition-opacity" title="새 화면으로 이동 (작업 저장/초기화)">'
if target1 in text:
    text = text.replace(target1, replace1, 1)
    print("1. Logo updated")

# 2. Help button
target2 = 'id="btn-help-tutorial" onclick="openHelpModal()"'
replace2 = 'id="btn-help-tutorial" onclick="showTutorial(true)"'
if target2 in text:
    text = text.replace(target2, replace2, 1)
    print("2. Help button updated")

# 3. Add newScreenDialog modal HTML after submissionDialog
target3 = 'id="submissionDialog"'
idx3 = text.find(target3)
if idx3 > 0:
    close1 = text.find('</div>', idx3)
    close2 = text.find('</div>', close1 + 6)
    if close2 > 0:
        insert_pos = close2 + 6
        modal_html = """

    <!-- 새 화면 / 새 작업 시작 확인 모달 -->
    <div id="newScreenDialog" class="choice-dialog" role="dialog" aria-modal="true" aria-labelledby="newScreenTitle">
        <div class="choice-card" style="width: min(440px, calc(100vw - 28px)); text-align: center; padding: 22px;">
            <h2 id="newScreenTitle" class="choice-title" style="margin-bottom: 8px; color: #1e3a8a;">🎵 새 화면으로 이동</h2>
            <p class="choice-description" style="margin-bottom: 20px; font-size: 14px; color: #475569; line-height: 1.6;">
                새 작업을 시작하시겠습니까?<br>
                현재 만들던 악보를 <strong>저장</strong>하고 이동하시겠습니까?
            </p>
            <div style="display: flex; flex-direction: column; gap: 10px;">
                <button type="button" onclick="handleNewScreenChoice('save')" class="choice-button primary" style="background: #4f46e5; border-color: #3730a3; color: white;">
                    📥 악보 저장 후 새 화면으로
                </button>
                <button type="button" onclick="handleNewScreenChoice('reset')" class="choice-button" style="background: #fef2f2; color: #dc2626; border-color: #fca5a5;">
                    🗑️ 저장 안 하고 새 화면으로
                </button>
                <button type="button" onclick="handleNewScreenChoice('cancel')" class="choice-button" style="background: white; color: #64748b;">
                    취소
                </button>
            </div>
        </div>
    </div>"""
        text = text[:insert_pos] + modal_html + text[insert_pos:]
        print("3. newScreenDialog inserted")

# 4. openHelpModal function update and add openNewScreenModal
targetFn = 'function openHelpModal() {'
idxFn = text.find(targetFn)
if idxFn > 0:
    fnEnd1 = text.find('}', idxFn)
    fnEnd2 = text.find('}', fnEnd1 + 1)
    if fnEnd2 > 0:
        fn_end_pos = fnEnd2 + 1
        new_fns = """function openHelpModal() {
            showTutorial(true);
        }

        function closeHelpModal() {
            closeTutorial();
        }

        function openNewScreenModal() {
            const dialog = document.getElementById('newScreenDialog');
            if (dialog) dialog.classList.add('show');
        }

        function closeNewScreenModal() {
            const dialog = document.getElementById('newScreenDialog');
            if (dialog) dialog.classList.remove('show');
        }

        function resetAllScoreMeasures() {
            stopPerformance();
            scoreMeasures = Array.from({length: PROJECT_MEASURE_COUNT}, () => []);
            measureUndoStacks = Array.from({length: PROJECT_MEASURE_COUNT}, () => []);
            notes = scoreMeasures[0];
            undoStack = measureUndoStacks[0];
            activeMeasureIndex = 0;
            dotCandidateNote = null;
            tieSourceNote = null;
            clearDrawings();
            updateMeasureNavigator();
            drawAll();
        }

        async function handleNewScreenChoice(choice) {
            closeNewScreenModal();
            if (choice === 'save') {
                downloadPlayableScoreHtml();
                setTimeout(() => {
                    resetAllScoreMeasures();
                    showToast('작품을 저장하고 새 화면으로 이동했습니다.', true);
                }, 500);
            } else if (choice === 'reset') {
                resetAllScoreMeasures();
                showToast('새 화면으로 이동했습니다.', true);
            }
        }"""
        text = text[:idxFn] + new_fns + text[fn_end_pos:]
        print("4. Functions updated")

# 5. tutorialSteps array replacement
target4Start = 'const tutorialSteps = ['
idx4Start = text.find(target4Start)
if idx4Start > 0:
    idx4End = text.find('];', idx4Start)
    if idx4End > 0:
        end_pos = idx4End + 2
        new_steps = """const tutorialSteps = [
            {
                title: '1단계: 음표·쉼표 넣기',
                body: '아래 입력표에서 <strong>음표</strong>나 <strong>쉼표</strong>를 눌러 악보에 넣으세요.',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '2단계: 점 ( . ) 붙이기',
                body: '음표나 쉼표를 넣은 후 <strong>[ . ] (점)</strong> 버튼을 누르면 점음표나 점쉼표로 바뀝니다.',
                anchor: 'dotButton',
                placement: 'top'
            },
            {
                title: '3단계: 붙임줄 연결하기',
                body: '두 음표를 이어 연주하고 싶다면 <strong>[⌒ 붙임줄]</strong> 버튼을 켠 후 <strong>연결할 음표 2개</strong>를 차례대로 클릭하세요.<br><small>(첫 번째 음표 → 두 번째 음표 순서)</small>',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '4단계: 내 리듬 들어보기',
                body: '악보를 만든 뒤 <strong>[▶ 이 마디 듣기]</strong>나 <strong>[▶▶ 전체 듣기]</strong>를 눌러 내가 만든 리듬을 들어보세요!',
                anchor: 'play',
                placement: 'top'
            },
            {
                title: '5단계: 지우기·되돌리기',
                body: '잘못 입력했을 때는 <strong>↩️ 되돌리기</strong> 또는 <strong>🗑️ 지우기</strong>를 누르세요.',
                anchor: 'undoClear',
                placement: 'bottom'
            },
            {
                title: '6단계: 시작하기',
                body: '이동식 가이드 안내가 끝났습니다. 자유롭게 리듬을 창작해 보세요! 🎉',
                anchor: 'canvas',
                placement: 'center'
            }
        ];"""
        text = text[:idx4Start] + new_steps + text[end_pos:]
        print("5. tutorialSteps updated")

with open(filepath, "w", encoding="utf-8", newline="\n") as f:
    f.write(text)

print("Patch complete in Python!")
