
# ============================================================
# Patch: tutorial steps, error messages, guided step tutorial
# Uses StreamReader-safe replacements with @'...'@ here-strings
# ============================================================
$indexPath = "c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm\index.html"
$text = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)
$origLen = $text.Length

# Helper to report status
function Rep($label, $old, $new) {
    if ($text.Contains($old)) {
        $script:text = $script:text.Replace($old, $new)
        Write-Host "OK: $label"
    } else {
        Write-Host "SKIP (not found): $label"
    }
}

# ─────────────────────────────────────────────
# 1. showMeasureOverflowWarning 함수 삽입
# ─────────────────────────────────────────────
$OLD1 = @'
        let warningShowing = false;
        let lastWarningMessage = '';
        let warningTimer = null;

        function showValidationAlert(msg) {
            if (warningShowing && lastWarningMessage === msg) return;
'@

$NEW1 = @'
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
'@
Rep "showMeasureOverflowWarning insert" $OLD1 $NEW1

# ─────────────────────────────────────────────
# 2. addDurationAtOffset - overflow 호출에 인자 추가
# ─────────────────────────────────────────────
Rep "addDurationAtOffset overflow call args" `
    "                showMeasureOverflowWarning();" `
    "                showMeasureOverflowWarning(type, dotted);"

# ─────────────────────────────────────────────
# 3. tutorialSteps 배열 교체
# ─────────────────────────────────────────────
# Find start and end of tutorialSteps array
$tsStart = $text.IndexOf("        const tutorialSteps = [")
if ($tsStart -ge 0) {
    $searchFrom = $tsStart + 30
    $tsClose = $text.IndexOf("`n        ];", $searchFrom)
    if ($tsClose -ge 0) {
        $tsEnd = $tsClose + ("`n        ];").Length
        $NEW_TS = @'

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
'@
        $text = $text.Substring(0, $tsStart) + $NEW_TS + $text.Substring($tsEnd)
        Write-Host "OK: tutorialSteps replaced"
    } else {
        Write-Host "SKIP: tutorialSteps close marker not found"
    }
} else {
    Write-Host "SKIP: tutorialSteps not found"
}

# ─────────────────────────────────────────────
# 4. checkGuidedPractice 성공 블록 교체 (깨진 toast 제거)
# ─────────────────────────────────────────────
# Find by landmark: after drawAll(); look for startIndependentCreation and broken toasts
$OLD4 = @'
            drawAll();
            startIndependentCreation();
            showToast('&#x1F389; &#xC815;&#xB2F5;&#xC785;&#xB2C8;&#xB2E4;! &#xC608;&#xC1DC;&#xB97C; &#xC644;&#xBDBD;&#xD788; &#xB9DE;&#xCDA4;&#xC15B;&#xC74D;&#xB2C8;&#xB2E4;. &#xC774;&#xC81C; &#xB098;&#xB9CC;&#xC758; &#xB9AC;&#xB4EC;&#xC744; &#xC790;&#xC720;&#xB86D;&#xAC8C; &#xB9DE;&#xB4E4;&#xC5B4; &#xBCF4;&#xC138;&#xC694;!', true);
            // end of success logic
            if (modal) {
'@
$NEW4 = @'
            drawAll();
            showToast('🎉 정답이에요! 예시를 완벽히 따라했어요!', true);
            setTimeout(function() {
                const modal = document.getElementById('practiceSuccessChoiceModal');
                if (modal) modal.classList.add('show');
            }, 700);
            // end of success logic
            if (false && modal) {
'@
Rep "success block" $OLD4 $NEW4

# 위의 HTML entity 버전이 없으면 다른 인코딩 확인
$OLD4b = @'
            drawAll();
            startIndependentCreation();
            showToast('🎉 정답입니다! 예시를 완벽히 맞췄습니다. 이제 나만의 리듬을 자유롭게 만들어 보세요!', true);
            // end of success logic
'@
if ($text.Contains($OLD4b)) {
    Rep "success block alt" $OLD4b @'
            drawAll();
            showToast('🎉 정답이에요! 예시를 완벽히 따라했어요!', true);
            setTimeout(function() {
                const modal = document.getElementById('practiceSuccessChoiceModal');
                if (modal) modal.classList.add('show');
            }, 700);
            // end of success logic
'@
}

# ─────────────────────────────────────────────
# 4b. 중복 showToast 제거 (2488 line)
# ─────────────────────────────────────────────
Rep "duplicate success toast" `
    "            showToast('예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.', true);" `
    "            // (toast already shown above)"

# ─────────────────────────────────────────────
# 5. checkGuidedPractice 오류 메시지 어린이 친화적으로 교체
# ─────────────────────────────────────────────
# err: 기호 수
Rep "err: 기호 비어있음" `
    "<strong>기호 수 오류:</strong> `${order}번째 기호가 비어 있습니다. 예시의 <strong>`${describePracticeEvent(expected)}</strong>를 이어서 입력하세요." `
    "`${order}번째 기호가 빠졌어요! 🎵<br>회색 기호 중 <strong>`${describePracticeEvent(expected)}</strong>를 눌러 입력해 보세요."

# err: 음가 오류
Rep "err: 음가" `
    "<strong>음가 오류:</strong> `${order}번째는 현재 <strong>`${describePracticeEvent(current)}</strong>, 예시는 <strong>`${describePracticeEvent(expected)}</strong>입니다. 길이가 다른 기호이므로 선택 삭제 후 예시와 같은 음가로 다시 입력하세요." `
    "`${order}번째 음 길이가 달라요! 🕐<br>지금 <strong>`${describePracticeEvent(current)}</strong>를 넣었지만 예시는 <strong>`${describePracticeEvent(expected)}</strong>이에요.<br><strong>삭제</strong> 버튼으로 지우고 올바른 기호를 다시 선택하세요."

# err: 위치
Rep "err: 위치" `
    "<strong>위치 오류:</strong> `${order}번째 기호의 시작 위치가 예시와 다릅니다. 앞부분의 빈칸이나 잘못된 음가가 원인입니다. 앞 기호부터 확인하여 빈칸을 채우거나 잘못된 기호를 수정하세요." `
    "`${order}번째 기호의 위치가 달라요! 📍<br>앞에 빈칸이 있거나 길이가 맞지 않는 기호가 있을 수 있어요.<br>앞 기호부터 하나씩 확인해 보세요."

# err: 붙임줄 없음
Rep "err: 붙임줄 없음" `
    "<strong>붙임줄 오류:</strong> 마지막 두 8분음표의 종류와 위치는 맞지만 붙임줄 연결이 없습니다. 위의 <strong>붙임줄</strong> 버튼을 누른 뒤 두 음표를 왼쪽부터 차례로 선택하세요." `
    "붙임줄을 아직 연결하지 않았어요! 🔗<br>위쪽 <strong>[붙임줄 🔗]</strong> 버튼을 누른 뒤,<br>연결할 첫 번째 음표 → 두 번째 음표 순서로 눌러 보세요."

# err: 붙임줄 잘못됨
Rep "err: 붙임줄 잘못됨" `
    "<strong>붙임줄 오류:</strong> 예시에서 연결하지 않은 음표에 붙임줄이 있습니다. 되돌리기로 연결을 취소한 뒤 다시 확인하세요." `
    "붙임줄이 잘못 연결되어 있어요! ✏️<br><strong>되돌리기</strong> 버튼을 눌러 붙임줄을 취소하고 다시 확인해 보세요."

# err: 기호 많음
Rep "err: 기호 많음" `
    "예시보다 기호가 `${actual.length - target.length}개 많습니다. 끝에 추가된 기호를 선택 삭제한 뒤 다시 확인하세요." `
    "기호가 `${actual.length - target.length}개 더 많아요! ✂️<br>끝에 있는 기호를 <strong>삭제</strong> 버튼으로 지운 다음 다시 확인해 보세요."

# toggleLastDot 오류
Rep "dot: 마디 끝 초과" `
    ". <strong>원인:</strong> `${describePracticeEvent(target)}가 마디 끝에 너무 가깝습니다. <strong>수정:</strong> 앞쪽의 점을 붙일 음표를 악보에서 선택하거나, 뒤 기호를 선택 삭제해 빈칸을 만든 뒤 다시 누르세요." `
    ".<br>점을 붙이면 마디 끝을 넘어요! ✋<br>뒤쪽 기호를 <strong>삭제</strong>해서 자리를 만든 다음 다시 눌러 보세요."

Rep "dot: 박 충돌" `
    "<strong>원인:</strong> 점을 붙이면 뒤 기호와 겹칩니다. <strong>수정:</strong> 겹치는 뒤 음표나 쉼표를 선택 삭제한 뒤 다시 점을 누르세요." `
    "점을 붙이면 다음 기호와 겹쳐요! 🔄<br>뒤에 있는 음표나 쉼표를 <strong>삭제</strong>한 다음 다시 눌러 보세요."

Rep "dot: 겹침" `
    "점을 붙이면 다음 음표와 겹칩니다. <strong>수정:</strong> 뒤 음표나 쉼표를 선택 삭제한 뒤 다시 점을 누르세요." `
    "점을 붙이면 다음 기호와 겹쳐요! 🔄<br>뒤에 있는 음표나 쉼표를 <strong>삭제</strong>한 다음 다시 눌러 보세요."

# triplet 오류
Rep "triplet: 6/8 제한" `
    "6/8박자는 8분음표 3개씩 묶이는 겹박자라 셋잇단음표를 넣지 않습니다. 8분음표 또는 16분음표 조합을 사용해 주세요." `
    "6/8박자에는 셋잇단음표를 넣지 않아요! 🎵<br>대신 <strong>8분음표</strong>나 <strong>16분음표</strong>를 사용해 보세요."

# ─────────────────────────────────────────────
# 6. 예시 리듬 단계별 팝업 시스템 + startGuidedStepTutorial
# ─────────────────────────────────────────────
$OLD6 = @'
        function hidePracticeStatus() {
'@
$NEW6 = @'
        // ── 예시 리듬 단계별 팝업 (guided practice inline tutorial) ──
        let guidedStepTutorialActive = false;
        let guidedStepIndex = 0;
        const GUIDED_STEPS = [
            {
                title: '1박 자리: 4분음표를 눌러요! 🎵',
                body: '아래 회색으로 보이는 첫 기호 자리에<br><strong>4분음표 버튼</strong>을 눌러 입력해 보세요!',
                anchor: 'noteRestButtons'
            },
            {
                title: '2박 자리: 8분음표 2개! 🎶',
                body: '두 번째 박 자리에 <strong>8분음표</strong>가 2개 있어요.<br>버튼을 2번 눌러 넣어 보세요!',
                anchor: 'noteRestButtons'
            },
            {
                title: '3박 자리: 쉼표 + 8분음표! 🎵',
                body: '먼저 <strong>8분쉼표</strong> 버튼을 누르고,<br>그 다음 <strong>8분음표</strong> 버튼을 눌러요!',
                anchor: 'noteRestButtons'
            },
            {
                title: '4박 자리: 붙임줄로 연결! 🔗',
                body: '<strong>8분음표</strong> 2개를 넣은 다음,<br><strong>[붙임줄 🔗]</strong> 버튼을 눌러 두 음표를 이어보세요!<br><small>붙임줄 버튼 → 첫 음표 클릭 → 두 번째 음표 클릭</small>',
                anchor: 'tie'
            }
        ];

        function startGuidedStepTutorial() {
            guidedStepTutorialActive = true;
            guidedStepIndex = 0;
            showGuidedStepPopup();
        }

        function showGuidedStepPopup() {
            if (!guidedStepTutorialActive) return;
            if (guidedStepIndex >= GUIDED_STEPS.length) {
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
            el.next.textContent = guidedStepIndex >= GUIDED_STEPS.length - 1 ? '시작할게요!' : '다음 단계 ▶';
            const neverLabel = el.never ? el.never.closest('label') : null;
            if (neverLabel) neverLabel.style.display = 'none';
            el.overlay.classList.add('show');
            clearTutorialHighlight();
            const anchorEl = getTutorialAnchor(step.anchor);
            const targets = normalizeTutorialTargets(anchorEl);
            currentTutorialTarget = targets;
            targets.forEach(function(t) { t.classList.add('tutorial-target-highlight'); });
            const rect = getCombinedRect(targets);
            if (rect) showTutorialGroupHighlight(rect);
            // Override positionTutorialCard with guided step data
            const fakeStep = Object.assign({}, step, {placement: 'top'});
            const savedIdx = tutorialIndex;
            tutorialIndex = guidedStepIndex;
            const savedSteps = tutorialSteps;
            // Temporarily swap so positionTutorialCard uses guided step
            window.__guidedRect = rect;
            requestAnimationFrame(function() {
                const card = el.card;
                if (!card || !rect) return;
                const gap = 14, pad = 10;
                const cardRect = card.getBoundingClientRect();
                const vw = window.innerWidth, vh = window.innerHeight;
                let left = rect.left + rect.width / 2 - cardRect.width / 2;
                let top = rect.top - cardRect.height - gap;
                if (top < pad) top = rect.bottom + gap;
                left = Math.max(pad, Math.min(left, vw - cardRect.width - pad));
                top = Math.max(pad, Math.min(top, vh - cardRect.height - pad));
                card.style.left = left + 'px';
                card.style.top = top + 'px';
                card.style.transform = 'none';
                showTutorialGroupHighlight(rect);
            });
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
            const neverLabel = el.never ? el.never.closest('label') : null;
            if (neverLabel) neverLabel.style.display = '';
        }
        // ── end guided practice inline tutorial ──

        function hidePracticeStatus() {
'@
Rep "guided step tutorial system" $OLD6 $NEW6

# ─────────────────────────────────────────────
# 7. startGuidedPractice에서 guided tutorial 시작
# ─────────────────────────────────────────────
Rep "wire startGuidedStepTutorial" `
    "            showToast('예시를 기억해 한 마디를 직접 입력한 뒤 정답 확인을 누르세요.', true);" `
    "            showToast('예시를 기억해 한 마디를 직접 입력한 뒤 정답 확인을 누르세요.', true);
            setTimeout(startGuidedStepTutorial, 500);"

# ─────────────────────────────────────────────
# 8. next 버튼 클릭 핸들러에 guidedStep 분기 추가
# ─────────────────────────────────────────────
$OLD8 = @'
            el.next.addEventListener('click', () => {
                if (tutorialIndex >= tutorialSteps.length - 1) {
                    closeTutorial();
                    return;
                }
                tutorialIndex += 1;
                renderTutorialStep();
            });
'@
$NEW8 = @'
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
'@
Rep "next btn guided step" $OLD8 $NEW8

# ─────────────────────────────────────────────
# 9. skip 버튼에 guidedStep 분기 추가
# ─────────────────────────────────────────────
Rep "skip btn guided step" `
    "            el.skip.addEventListener('click', closeTutorial);" `
    "            el.skip.addEventListener('click', function() { if (guidedStepTutorialActive) { closeGuidedStepTutorial(); } else { closeTutorial(); } });"

# ─────────────────────────────────────────────
# 10. practiceSuccessChoiceModal 텍스트 수정
# ─────────────────────────────────────────────
Rep "modal comment fix" `
    "    <!-- ?룇 ?덉떆 ?곕씪 ?섍린 ?깃났 ???낅┰ 李쎌옉 ?꾪솚 ?좏깮 ?앹뾽 -->" `
    "    <!-- 예시 따라하기 성공 후 독립 창작 이동 선택 모달 -->"

Rep "modal h2 fix" `
    "?럦 ?덉떆 由щ벉 ?꾨꼍 ?깃났!" `
    "🎉 예시 따라하기 성공!"

# ─────────────────────────────────────────────
# 완료
# ─────────────────────────────────────────────
$newLen = $text.Length
[System.IO.File]::WriteAllText($indexPath, $text, [System.Text.Encoding]::UTF8)
Write-Host ""
Write-Host "ALL DONE. $origLen → $newLen bytes"
