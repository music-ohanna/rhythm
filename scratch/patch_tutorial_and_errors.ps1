
# 대용량 index.html 패치 - 튜토리얼 텍스트/에러메시지/팝업 수정
$indexPath = "c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm\index.html"
$text = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

# ─────────────────────────────────────────────
# 1. showMeasureOverflowWarning 함수 삽입 (showValidationAlert 바로 앞에)
# ─────────────────────────────────────────────
$OLD_VALIDATE_DECL = @"
        let warningShowing = false;
        let lastWarningMessage = '';
        let warningTimer = null;

        function showValidationAlert(msg) {
            if (warningShowing && lastWarningMessage === msg) return;
"@
$NEW_VALIDATE_DECL = @"
        let warningShowing = false;
        let lastWarningMessage = '';
        let warningTimer = null;

        function showMeasureOverflowWarning(type, dotted) {
            const names = {whole:'온음표', half:'2분음표', quarter:'4분음표', eighth:'8분음표', sixteenth:'16분음표', thirtysecond:'32분음표', triplet:'셋잇단음표'};
            const typeName = (names[type] || '음표');
            const dottedStr = dotted ? '점' : '';
            const msg = '<strong>' + dottedStr + typeName + '</strong>은 이 자리에 넣기엔 너무 길어요! 🎵<br>더 짧은 음표나 쉼표를 선택해 보세요.<br><small>예: 4분음표 자리엔 8분음표 2개가 딱 맞아요.</small>';
            showValidationAlert(msg);
        }

        function showValidationAlert(msg) {
            if (warningShowing && lastWarningMessage === msg) return;
"@
if ($text.Contains($OLD_VALIDATE_DECL)) {
    $text = $text.Replace($OLD_VALIDATE_DECL, $NEW_VALIDATE_DECL)
    Write-Host "OK: showMeasureOverflowWarning inserted"
} else {
    Write-Host "WARN: showValidationAlert decl not found exactly"
}

# ─────────────────────────────────────────────
# 2. addDurationAtOffset - showMeasureOverflowWarning 호출에 인자 추가
# ─────────────────────────────────────────────
$OLD_OVERFLOW_CALL = "                showMeasureOverflowWarning();"
$NEW_OVERFLOW_CALL = "                showMeasureOverflowWarning(type, dotted);"
$count = ([regex]::Matches($text, [regex]::Escape($OLD_OVERFLOW_CALL))).Count
$text = $text.Replace($OLD_OVERFLOW_CALL, $NEW_OVERFLOW_CALL)
Write-Host "OK: replaced $count showMeasureOverflowWarning() calls with typed version"

# ─────────────────────────────────────────────
# 3. tutorialSteps 배열 교체 (깨진 텍스트 → 정상 한국어)
# ─────────────────────────────────────────────
$OLD_TUTORIAL_OPEN = "        const tutorialSteps = ["
$NEW_TUTORIAL_BLOCK = @"
        const tutorialSteps = [
            {
                title: '🎵 1단계: 음표 넣기',
                body: '아래 버튼에서 <strong>4분음표</strong>, <strong>8분음표</strong> 등 음표를 눌러 악보에 넣어요!<br><small>음표 = 소리가 나는 기호예요.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '🎵 2단계: 쉼표 넣기',
                body: '쉼표 버튼의 <strong>4분쉼표(𝄽)</strong>, <strong>8분쉼표(𝄾)</strong>를 누르면 쉬는 자리를 넣을 수 있어요!<br><small>쉼표 = 잠깐 쉬는 기호예요.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '✨ 3단계: 점(.) 붙이기',
                body: '음표나 쉼표를 선택한 뒤 <strong>[ . ] (점)</strong> 버튼을 눌러 보세요!<br>점을 붙이면 그 기호의 길이가 1.5배가 돼요!',
                anchor: 'dotButton',
                placement: 'top'
            },
            {
                title: '🔗 4단계: 붙임줄 만들기',
                body: '음표를 이어 붙이고 싶다면 <strong>[🔗 붙임줄]</strong> 버튼을 누른 뒤,<br>이어 붙일 첫 번째 음표 → 두 번째 음표 순서로 눌러 보세요!',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '▶ 5단계: 내 리듬 들어보기',
                body: '아래 <strong>[▶ 이 마디 듣기]</strong> 버튼을 눌러 내가 만든 리듬을 들어봐요!<br><small>반복 재생되니까 수정하면서 들을 수 있어요.</small>',
                anchor: 'play',
                placement: 'top'
            }
        ];
"@

# Find the index of tutorialSteps and its closing ];
$startIdx = $text.IndexOf($OLD_TUTORIAL_OPEN)
if ($startIdx -ge 0) {
    # Find the closing ]; after tutorialSteps
    $searchFrom = $startIdx + $OLD_TUTORIAL_OPEN.Length
    $closePattern = "`n        ];"
    $closeIdx = $text.IndexOf($closePattern, $searchFrom)
    if ($closeIdx -ge 0) {
        $endIdx = $closeIdx + $closePattern.Length
        $before = $text.Substring(0, $startIdx)
        $after  = $text.Substring($endIdx)
        $text = $before + $NEW_TUTORIAL_BLOCK + $after
        Write-Host "OK: tutorialSteps replaced"
    } else {
        Write-Host "WARN: could not find closing ]; for tutorialSteps"
    }
} else {
    Write-Host "WARN: tutorialSteps open not found"
}

# ─────────────────────────────────────────────
# 4. checkGuidedPractice - 에러 메시지 어린이 친화적으로 교체
# ─────────────────────────────────────────────

# 4-1. 기호 수 오류 (빈 기호)
$OLD_ERR1 = '<strong>기호 수 오류:</strong> ${order}번째 기호가 비어 있습니다. 예시의 <strong>${describePracticeEvent(expected)}</strong>를 이어서 입력하세요.'
$NEW_ERR1 = '${order}번째 기호가 빠졌어요! 🎵<br>회색 기호 중 <strong>${describePracticeEvent(expected)}</strong>를 눌러 입력해 보세요.'
$text = $text.Replace($OLD_ERR1, $NEW_ERR1)
Write-Host "OK: err1 replaced"

# 4-2. 음표·쉼표 종류 오류
$OLD_ERR2 = '<strong>음표·쉼표 종류 오류:</strong> ${order}번째는 현재 ${current.isRest ? \'쉼표\' : \'음표\'}이지만 예시는 ${expected.isRest ? \'쉼표\' : \'음표\'}입니다. 선택 삭제로 지운 뒤 <strong>${describePracticeEvent(expected)}</strong>를 입력하세요.'
$NEW_ERR2 = '${order}번째가 달라요! ✏️<br>지금은 <strong>${current.isRest ? \'쉼표\' : \'음표\'}</strong>를 넣었는데, 예시는 <strong>${expected.isRest ? \'쉼표\' : \'음표\'}</strong>예요.<br>위의 <strong>삭제</strong> 버튼으로 지운 다음 <strong>${describePracticeEvent(expected)}</strong>를 다시 눌러 보세요.'
$text = $text.Replace($OLD_ERR2, $NEW_ERR2)
Write-Host "OK: err2 replaced"

# 4-3. 음가 오류
$OLD_ERR3 = '<strong>음가 오류:</strong> ${order}번째는 현재 <strong>${describePracticeEvent(current)}</strong>, 예시는 <strong>${describePracticeEvent(expected)}</strong>입니다. 길이가 다른 기호이므로 선택 삭제 후 예시와 같은 음가로 다시 입력하세요.'
$NEW_ERR3 = '${order}번째 음 길이가 달라요! 🕐<br>지금 <strong>${describePracticeEvent(current)}</strong>를 넣었지만, 예시는 <strong>${describePracticeEvent(expected)}</strong>이에요.<br><strong>삭제</strong> 버튼으로 지우고 올바른 기호를 다시 선택하세요.'
$text = $text.Replace($OLD_ERR3, $NEW_ERR3)
Write-Host "OK: err3 replaced"

# 4-4. 위치 오류
$OLD_ERR4 = '<strong>위치 오류:</strong> ${order}번째 기호의 시작 위치가 예시와 다릅니다. 앞부분의 빈칸이나 잘못된 음가가 원인입니다. 앞 기호부터 확인하여 빈칸을 채우거나 잘못된 기호를 수정하세요.'
$NEW_ERR4 = '${order}번째 기호의 위치가 달라요! 📍<br>앞에 빈칸이 있거나 길이가 맞지 않는 기호가 있을 수 있어요.<br>앞 기호부터 하나씩 확인해 보세요.'
$text = $text.Replace($OLD_ERR4, $NEW_ERR4)
Write-Host "OK: err4 replaced"

# 4-5. 붙임줄 없음 오류
$OLD_ERR5 = '<strong>붙임줄 오류:</strong> 마지막 두 8분음표의 종류와 위치는 맞지만 붙임줄 연결이 없습니다. 위의 <strong>붙임줄</strong> 버튼을 누른 뒤 두 음표를 왼쪽부터 차례로 선택하세요.'
$NEW_ERR5 = '붙임줄을 아직 연결하지 않았어요! 🔗<br>위쪽 <strong>[붙임줄 🔗]</strong> 버튼을 누른 뒤,<br>연결할 첫 번째 음표 → 두 번째 음표 순서로 눌러 보세요.'
$text = $text.Replace($OLD_ERR5, $NEW_ERR5)
Write-Host "OK: err5 (tie missing) replaced"

# 4-6. 붙임줄 잘못됨 오류
$OLD_ERR6 = '<strong>붙임줄 오류:</strong> 예시에서 연결하지 않은 음표에 붙임줄이 있습니다. 되돌리기로 연결을 취소한 뒤 다시 확인하세요.'
$NEW_ERR6 = '붙임줄이 잘못 연결되어 있어요! ✏️<br><strong>되돌리기</strong> 버튼을 눌러 붙임줄을 취소하고 다시 확인해 보세요.'
$text = $text.Replace($OLD_ERR6, $NEW_ERR6)
Write-Host "OK: err6 (tie wrong) replaced"

# 4-7. 기호 많음 오류
$OLD_ERR7 = '예시보다 기호가 ${actual.length - target.length}개 많습니다. 끝에 추가된 기호를 선택 삭제한 뒤 다시 확인하세요.'
$NEW_ERR7 = '기호가 ${actual.length - target.length}개 더 많아요! ✂️<br>끝에 있는 기호를 <strong>삭제</strong> 버튼으로 지운 다음 다시 확인해 보세요.'
$text = $text.Replace($OLD_ERR7, $NEW_ERR7)
Write-Host "OK: err7 replaced"

# ─────────────────────────────────────────────
# 5. checkGuidedPractice 성공 시 깨진 토스트 교체 및 중복 제거
# ─────────────────────────────────────────────
$OLD_SUCCESS = @"
            playTone(880, 0.15, 0.15, 'sine'); playTone(1046, 0.25, 0.2, 'sine');
            guidedPracticeTarget = null;
            practiceStatusMode = null;
            hidePracticeStatus();
            drawAll();
            startIndependentCreation();
            showToast('?럦 ?뺣떟?낅땲?? ?덉떆瑜??꾨꼍??留욎톬?듬땲?? ?댁젣 ?섎쭔??由щ벉???먯쑀濡?쾶 留뚮뱾??蹂댁꽭??', true);
            showToast('예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.', true);
"@
$NEW_SUCCESS = @"
            playTone(880, 0.15, 0.15, 'sine'); playTone(1046, 0.25, 0.2, 'sine');
            guidedPracticeTarget = null;
            practiceStatusMode = null;
            hidePracticeStatus();
            drawAll();
            showToast('🎉 정답이에요! 예시를 완벽히 따라했어요!', true);
            setTimeout(function() {
                const modal = document.getElementById('practiceSuccessChoiceModal');
                if (modal) modal.classList.add('show');
            }, 700);
"@
if ($text.Contains($OLD_SUCCESS)) {
    $text = $text.Replace($OLD_SUCCESS, $NEW_SUCCESS)
    Write-Host "OK: success block replaced"
} else {
    Write-Host "WARN: success block not matched exactly - trying partial"
    # Try partial replacement
    $OLD_TOAST_BROKEN = "            showToast('?럦 ?뺣떟?낅땲?? ?덉떆瑜??꾨꼍??留욎톬?듬땲?? ?댁젣 ?섎쭔??由щ벉???먯쑀濡?쾶 留뚮뱾??蹂댁꽭??', true);"
    $OLD_TOAST_DUP   = "            showToast('예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.', true);"
    $NEW_SUCCESS_FRAGMENT = @"
            showToast('🎉 정답이에요! 예시를 완벽히 따라했어요!', true);
            setTimeout(function() {
                const modal = document.getElementById('practiceSuccessChoiceModal');
                if (modal) modal.classList.add('show');
            }, 700);
"@
    $text = $text.Replace($OLD_TOAST_BROKEN + "`r`n" + $OLD_TOAST_DUP, $NEW_SUCCESS_FRAGMENT)
    Write-Host "OK: partial success toast replaced"
}

# Also remove orphaned startIndependentCreation() right before both toasts
$OLD_ORPHAN = @"
            drawAll();
            startIndependentCreation();
            showToast(
"@
# (This won't be in the file after replacement, skip)

# ─────────────────────────────────────────────
# 6. 예시 리듬 단계별 안내 팝업 시스템 삽입
#    startGuidedPractice() 함수 바로 뒤에 삽입
# ─────────────────────────────────────────────
$OLD_AFTER_GUIDED = @"
        function hidePracticeStatus() {
"@
$NEW_GUIDED_TUTORIAL = @"
        // ── 예시 리듬 입력 단계별 팝업 (guided practice tutorial) ──
        let guidedStepTutorialActive = false;
        let guidedStepIndex = 0;
        const GUIDED_STEPS = [
            {
                title: '1박 자리: 4분음표를 눌러요!',
                body: '회색으로 보이는 <strong>4분음표</strong> 위치에<br><strong>4분음표 버튼</strong>을 눌러 입력해 보세요! 🎵',
                anchor: 'noteRestButtons'
            },
            {
                title: '2박 자리: 8분음표 2개!',
                body: '회색 기호를 보면 <strong>8분음표가 2개</strong> 있어요.<br>버튼을 2번 눌러 넣어 보세요! 🎶',
                anchor: 'noteRestButtons'
            },
            {
                title: '3박 자리: 8분쉼표 + 8분음표!',
                body: '먼저 <strong>8분쉼표</strong>를 누르고,<br>그 다음 <strong>8분음표</strong>를 눌러요! 🎵',
                anchor: 'noteRestButtons'
            },
            {
                title: '4박 자리: 8분음표 2개 + 붙임줄!',
                body: '<strong>8분음표</strong> 2개를 넣은 다음,<br><strong>[🔗 붙임줄]</strong> 버튼을 눌러 두 음표를 이어보세요!',
                anchor: 'tie'
            }
        ];

        function startGuidedStepTutorial() {
            guidedStepTutorialActive = true;
            guidedStepIndex = 0;
            showGuidedStepPopup();
        }

        function showGuidedStepPopup() {
            if (!guidedStepTutorialActive || guidedStepIndex >= GUIDED_STEPS.length) {
                closeGuidedStepTutorial();
                return;
            }
            const step = GUIDED_STEPS[guidedStepIndex];
            const el = getTutorialElements();
            if (!el.overlay || !el.card) return;
            el.count.textContent = (guidedStepIndex + 1) + ' / ' + GUIDED_STEPS.length;
            el.title.textContent = step.title;
            el.body.innerHTML = step.body;
            el.prev.disabled = true;
            el.next.textContent = guidedStepIndex >= GUIDED_STEPS.length - 1 ? '시작!' : '다음 단계';
            if (el.never) el.never.closest('label').style.display = 'none';
            el.overlay.classList.add('show');
            const skipEl = el.skip;
            if (skipEl) skipEl.textContent = '건너뛰기';
            // anchor for placement
            const anchorEl = getTutorialAnchor(step.anchor);
            const targets = normalizeTutorialTargets(anchorEl);
            clearTutorialHighlight();
            currentTutorialTarget = targets;
            targets.forEach(t => t.classList.add('tutorial-target-highlight'));
            const rect = getCombinedRect(targets);
            if (rect) showTutorialGroupHighlight(rect);
            requestAnimationFrame(positionTutorialCard);
            // temporarily override step so positionTutorialCard works
            el.card.dataset.guidedStep = guidedStepIndex;
        }

        function advanceGuidedStep() {
            guidedStepIndex++;
            if (guidedStepIndex >= GUIDED_STEPS.length) {
                closeGuidedStepTutorial();
            } else {
                showGuidedStepPopup();
            }
        }

        function closeGuidedStepTutorial() {
            guidedStepTutorialActive = false;
            clearTutorialHighlight();
            const el = getTutorialElements();
            if (el.overlay) el.overlay.classList.remove('show');
            if (el.never) el.never.closest('label').style.display = '';
            if (el.skip) el.skip.textContent = '건너뛰기';
        }
        // ── end guided practice tutorial ──

        function hidePracticeStatus() {
"@
if ($text.Contains($OLD_AFTER_GUIDED)) {
    $text = $text.Replace($OLD_AFTER_GUIDED, $NEW_GUIDED_TUTORIAL)
    Write-Host "OK: guided step tutorial system inserted"
} else {
    Write-Host "WARN: hidePracticeStatus anchor not found"
}

# ─────────────────────────────────────────────
# 7. startGuidedPractice 에서 단계별 팝업 시작 연결
# ─────────────────────────────────────────────
$OLD_GUIDED_PRACTICE = @"
            showToast('예시를 기억해 한 마디를 직접 입력한 뒤 정답 확인을 누르세요.', true);
        }
"@
$NEW_GUIDED_PRACTICE = @"
            showToast('예시를 기억해 한 마디를 직접 입력한 뒤 정답 확인을 누르세요.', true);
            setTimeout(startGuidedStepTutorial, 600);
        }
"@
if ($text.Contains($OLD_GUIDED_PRACTICE)) {
    $text = $text.Replace($OLD_GUIDED_PRACTICE, $NEW_GUIDED_PRACTICE)
    Write-Host "OK: startGuidedStepTutorial wired to startGuidedPractice"
} else {
    Write-Host "WARN: startGuidedPractice tail not found"
}

# ─────────────────────────────────────────────
# 8. initTutorial의 next 버튼 클릭에서 guidedStep 체크 연결
# ─────────────────────────────────────────────
$OLD_NEXT_BTN = @"
            el.next.addEventListener('click', () => {
                if (tutorialIndex >= tutorialSteps.length - 1) {
                    closeTutorial();
                    return;
                }
                tutorialIndex += 1;
                renderTutorialStep();
            });
"@
$NEW_NEXT_BTN = @"
            el.next.addEventListener('click', () => {
                if (guidedStepTutorialActive) {
                    advanceGuidedStep();
                    return;
                }
                if (tutorialIndex >= tutorialSteps.length - 1) {
                    closeTutorial();
                    return;
                }
                tutorialIndex += 1;
                renderTutorialStep();
            });
"@
if ($text.Contains($OLD_NEXT_BTN)) {
    $text = $text.Replace($OLD_NEXT_BTN, $NEW_NEXT_BTN)
    Write-Host "OK: next button wired to guidedStepTutorialActive"
} else {
    Write-Host "WARN: next btn event not matched"
}

# ─────────────────────────────────────────────
# 9. skip 버튼도 guidedStep 종료 연결
# ─────────────────────────────────────────────
$OLD_SKIP_BTN = "            el.skip.addEventListener('click', closeTutorial);"
$NEW_SKIP_BTN = @"
            el.skip.addEventListener('click', () => {
                if (guidedStepTutorialActive) { closeGuidedStepTutorial(); return; }
                closeTutorial();
            });
"@
if ($text.Contains($OLD_SKIP_BTN)) {
    $text = $text.Replace($OLD_SKIP_BTN, $NEW_SKIP_BTN)
    Write-Host "OK: skip button wired"
} else {
    Write-Host "WARN: skip btn not matched"
}

# ─────────────────────────────────────────────
# 10. practiceSuccessChoiceModal 텍스트 (깨진 한국어) 수정
# ─────────────────────────────────────────────
$OLD_SUCCESS_MODAL_H2 = '?럦 ?덉떆 由щ벉 ?꾨꼍 ?깃났!'
$NEW_SUCCESS_MODAL_H2 = '🎉 예시 따라하기 성공!'
$text = $text.Replace($OLD_SUCCESS_MODAL_H2, $NEW_SUCCESS_MODAL_H2)
Write-Host "OK: modal h2 fixed"

$OLD_SUCCESS_MODAL_P = @"
                ?덉떆 由щ벉???꾨꼍?섍쾶 留욎톬?듬땲??<br>?댁젣 <strong>3. ?낅┰ 李쎌옉</strong> ?④퀎濡??섏뼱媛 ?섎쭔??由щ벉???먯쑀濡?쾶 留뚮뱾??蹂쇨퉴??
"@
$NEW_SUCCESS_MODAL_P = @"
                예시 따라하기를 성공했어요!<br>이제 <strong>나만의 리듬</strong>을 자유롭게 만들어 볼까요? 🎶
"@
$text = $text.Replace($OLD_SUCCESS_MODAL_P.Trim(), $NEW_SUCCESS_MODAL_P.Trim())
Write-Host "OK: modal paragraph fixed"

$OLD_SUCCESS_BTN1 = @"
                    ?렓 3. ?낅┰ 李쎌옉 ?쒖옉?섍린 (?먯쑀濡?쾶 留뚮뱾湲?
"@
$NEW_SUCCESS_BTN1 = '🎵 나만의 리듬 만들기 (독립 창작 시작)'
$text = $text.Replace($OLD_SUCCESS_BTN1.Trim(), $NEW_SUCCESS_BTN1)
Write-Host "OK: success btn1 fixed"

$OLD_SUCCESS_BTN2 = @"
                    ?봺 2. ?덉떆 ?ㅼ떆 ?곕씪 留뚮뱾湲?                
"@
$NEW_SUCCESS_BTN2 = '🔁 예시 다시 따라하기'
$text = $text.Replace($OLD_SUCCESS_BTN2.Trim(), $NEW_SUCCESS_BTN2)
Write-Host "OK: success btn2 fixed"

# ─────────────────────────────────────────────
# 11. practiceSuccessChoiceModal body 텍스트 주석도 수정
# ─────────────────────────────────────────────
$OLD_COMMENT = "    <!-- ?룇 ?덉떆 ?곕씪 ?섍린 ?깃났 ???낅┰ 李쎌옉 ?꾪솚 ?좏깮 ?앹뾽 -->"
$NEW_COMMENT = "    <!-- 예시 따라하기 성공 후 독립 창작 이동 선택 모달 -->"
$text = $text.Replace($OLD_COMMENT, $NEW_COMMENT)
Write-Host "OK: comment fixed"

# ─────────────────────────────────────────────
# 저장
# ─────────────────────────────────────────────
[System.IO.File]::WriteAllText($indexPath, $text, [System.Text.Encoding]::UTF8)
Write-Host ""
Write-Host "ALL_DONE - 파일 저장 완료"
