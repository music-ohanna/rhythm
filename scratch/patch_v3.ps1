
# patch_v3.ps1 - 라인 번호 + 블록 기반 혼합 패치
# 모든 JS template literal 포함 문자열은 라인 기반으로 처리
$indexPath = "c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm\index.html"

# =============================================
# Part A: 블록 패치 (here-string, JS template literal 없음)
# =============================================
$text = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

function TryReplace($label, $old, $new) {
    if ($script:text.Contains($old)) {
        $script:text = $script:text.Replace($old, $new)
        Write-Host "OK: $label"
        return $true
    }
    Write-Host "SKIP: $label"
    return $false
}

# 1. showMeasureOverflowWarning 삽입
$A1_OLD = @'
        let warningShowing = false;
        let lastWarningMessage = '';
        let warningTimer = null;

        function showValidationAlert(msg) {
            if (warningShowing && lastWarningMessage === msg) return;
'@
$A1_NEW = @'
        let warningShowing = false;
        let lastWarningMessage = '';
        let warningTimer = null;

        function showMeasureOverflowWarning(type, dotted) {
            const names = {whole:'온음표', half:'2분음표', quarter:'4분음표', eighth:'8분음표', sixteenth:'16분음표', thirtysecond:'32분음표', triplet:'셋잇단음표'};
            const typeName = (names[type] || '음표');
            const dottedStr = dotted ? '점' : '';
            const msg = '<strong>' + dottedStr + typeName + '</strong>은 이 자리에 넣기엔 너무 길어요!<br>더 짧은 음표나 쉼표를 선택해 보세요.<br><small>예: 4분음표 자리엔 8분음표 2개가 딱 맞아요.</small>';
            showValidationAlert(msg);
        }

        function showValidationAlert(msg) {
            if (warningShowing && lastWarningMessage === msg) return;
'@
TryReplace "showMeasureOverflowWarning" $A1_OLD $A1_NEW | Out-Null

# 2. addDurationAtOffset overflow 호출 타입 추가
TryReplace "overflow call with args" `
    "                showMeasureOverflowWarning();" `
    "                showMeasureOverflowWarning(type, dotted);" | Out-Null

# 3. 성공 토스트 중복 및 깨진 텍스트 제거 - startIndependentCreation() 라인
# (checkGuidedPractice 내부에서 startIndependentCreation을 호출하고 있는 부분 - 제거)
TryReplace "remove orphan startIndependentCreation" `
    "            startIndependentCreation();" `
    "            // startIndependentCreation is now called from modal" | Out-Null

# 4. 깨진 성공 toast 교체
TryReplace "broken toast -> clean" `
    "            showToast('예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.', true);" `
    "            showToast('정답이에요! 예시를 완벽히 따라했어요!', true);" | Out-Null

# 5. modal 표시 로직 추가 (if (modal) { ... } 블록 찾기)
$A5_OLD = @'
            if (modal) {
                modal.classList.add('show');
            }
'@
$A5_NEW = @'
            setTimeout(function() {
                const modal = document.getElementById('practiceSuccessChoiceModal');
                if (modal) modal.classList.add('show');
            }, 700);
'@
TryReplace "success modal show" $A5_OLD $A5_NEW | Out-Null

# 6. guided step tutorial 시스템 삽입
$A6_OLD = @'
        function hidePracticeStatus() {
'@
$A6_NEW = @'
        // ── 예시 리듬 단계별 팝업 (guided practice step tutorial) ──
        let guidedStepTutorialActive = false;
        let guidedStepIndex = 0;
        const GUIDED_STEPS = [
            { title: '1박 자리: 4분음표를 눌러요!', body: '아래 회색 기호 중 첫 번째 자리에<br><strong>4분음표 버튼</strong>을 눌러 입력해 보세요!', anchor: 'noteRestButtons' },
            { title: '2박 자리: 8분음표 2개!', body: '두 번째 박 자리에 <strong>8분음표</strong>가 2개 있어요.<br>버튼을 2번 눌러 넣어 보세요!', anchor: 'noteRestButtons' },
            { title: '3박 자리: 8분쉼표 + 8분음표!', body: '먼저 <strong>8분쉼표</strong> 버튼을 누르고,<br>그 다음 <strong>8분음표</strong> 버튼을 눌러요!', anchor: 'noteRestButtons' },
            { title: '4박 자리: 8분음표 2개 + 붙임줄!', body: '<strong>8분음표</strong> 2개를 넣은 다음,<br><strong>[붙임줄]</strong> 버튼을 눌러 두 음표를 이어보세요!<br><small>붙임줄 버튼 → 첫 음표 클릭 → 두 번째 음표 클릭</small>', anchor: 'tie' }
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
            el.next.textContent = guidedStepIndex >= GUIDED_STEPS.length - 1 ? '시작할게요!' : '다음 단계';
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
            requestAnimationFrame(function() {
                if (!el.card || !rect) return;
                const gap = 14, pad = 10;
                const cardRect = el.card.getBoundingClientRect();
                const vw = window.innerWidth, vh = window.innerHeight;
                let left = rect.left + rect.width / 2 - cardRect.width / 2;
                let top = rect.top - cardRect.height - gap;
                if (top < pad) top = rect.bottom + gap;
                left = Math.max(pad, Math.min(left, vw - cardRect.width - pad));
                top = Math.max(pad, Math.min(top, vh - cardRect.height - pad));
                el.card.style.left = left + 'px';
                el.card.style.top = top + 'px';
                el.card.style.transform = 'none';
            });
        }
        function advanceGuidedStep() {
            guidedStepIndex++;
            if (guidedStepIndex >= GUIDED_STEPS.length) closeGuidedStepTutorial();
            else showGuidedStepPopup();
        }
        function closeGuidedStepTutorial() {
            guidedStepTutorialActive = false;
            clearTutorialHighlight();
            const el = getTutorialElements();
            if (el.overlay) el.overlay.classList.remove('show');
            const neverLabel = el.never ? el.never.closest('label') : null;
            if (neverLabel) neverLabel.style.display = '';
        }
        // ── end guided practice step tutorial ──

        function hidePracticeStatus() {
'@
TryReplace "guided step tutorial" $A6_OLD $A6_NEW | Out-Null

# 7. startGuidedPractice에서 guided tutorial 연결
TryReplace "wire guided tutorial" `
    "            showToast('예시를 기억해 한 마디를 직접 입력한 뒤 정답 확인을 누르세요.', true);" `
    "            showToast('예시를 기억해 한 마디를 직접 입력한 뒤 정답 확인을 누르세요.', true);
            setTimeout(startGuidedStepTutorial, 500);" | Out-Null

# 8. next 버튼 guided 분기
$A8_OLD = @'
            el.next.addEventListener('click', () => {
                if (tutorialIndex >= tutorialSteps.length - 1) {
                    closeTutorial();
                    return;
                }
                tutorialIndex += 1;
                renderTutorialStep();
            });
'@
$A8_NEW = @'
            el.next.addEventListener('click', () => {
                if (guidedStepTutorialActive) { advanceGuidedStep(); return; }
                if (tutorialIndex >= tutorialSteps.length - 1) {
                    closeTutorial();
                    return;
                }
                tutorialIndex += 1;
                renderTutorialStep();
            });
'@
TryReplace "next btn guided" $A8_OLD $A8_NEW | Out-Null

# 9. skip 버튼 guided 분기
TryReplace "skip btn guided" `
    "            el.skip.addEventListener('click', closeTutorial);" `
    "            el.skip.addEventListener('click', function() { if (guidedStepTutorialActive) { closeGuidedStepTutorial(); } else { closeTutorial(); } });" | Out-Null

# 10. modal 텍스트 수정 (깨진 한국어)
TryReplace "modal comment" `
    "    <!-- ?룇 ?덉떆 ?곕씪 ?섍린 ?깃났 ???낅┰ 李쎌옉 ?꾪솚 ?좏깮 ?앹뾽 -->" `
    "    <!-- 예시 따라하기 성공 후 독립 창작 이동 선택 모달 -->" | Out-Null

TryReplace "modal h2" `
    "?럦 ?덉떆 由щ벉 ?꾨꼍 ?깃났!" `
    "예시 따라하기 성공!" | Out-Null

# Part A 저장
[System.IO.File]::WriteAllText($indexPath, $text, [System.Text.Encoding]::UTF8)
Write-Host "Part A saved."

# =============================================
# Part B: 라인 기반 패치 (JS template literals 포함)
# =============================================
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

function PatchLine($lineNum, $oldSubstr, $newSubstr) {
    $i = $lineNum - 1
    if ($i -lt 0 -or $i -ge $lines.Length) { Write-Host "SKIP line $lineNum (out of range)"; return }
    if ($lines[$i].Contains($oldSubstr)) {
        $lines[$i] = $lines[$i].Replace($oldSubstr, $newSubstr)
        Write-Host "OK line $lineNum: patched"
    } else {
        Write-Host "SKIP line $lineNum: '$oldSubstr' not found"
        Write-Host "  Actual: $($lines[$i])"
    }
}

# Find key error lines dynamically
for ($i = 0; $i -lt $lines.Length; $i++) {
    $ln = $lines[$i]

    # err: 기호 비어있음 (기호 수 오류)
    if ($ln.Contains('<strong>기호 수 오류:</strong>')) {
        $lines[$i] = $lines[$i] -replace [regex]::Escape('<strong>기호 수 오류:</strong>'), ''
        $lines[$i] = $lines[$i] -replace '번째 기호가 비어 있습니다\. 예시의 <strong>\$\{describePracticeEvent\(expected\)\}</strong>를 이어서 입력하세요\.', '번째 기호가 빠졌어요!<br>회색 기호 중 <strong>${describePracticeEvent(expected)}</strong>를 눌러 입력해 보세요.'
        Write-Host "OK: err 기호수 line $($i+1)"
    }

    # err: 음표쉼표 종류 오류 -> check for 음표·쉼표 종류 오류
    if ($ln.Contains('<strong>음표·쉼표 종류 오류:</strong>')) {
        $lines[$i] = '                    showValidationAlert(`${order}번째가 달라요!<br>지금은 <strong>${current.isRest ? `+[char]39+`쉼표`+[char]39+` : `+[char]39+`음표`+[char]39+`}</strong>를 넣었는데, 예시는 <strong>${expected.isRest ? `+[char]39+`쉼표`+[char]39+` : `+[char]39+`음표`+[char]39+`}</strong>예요.<br>위의 <strong>삭제</strong> 버튼으로 지운 다음 <strong>${describePracticeEvent(expected)}</strong>를 다시 눌러 보세요.`);'
        Write-Host "OK: err 종류 line $($i+1)"
    }

    # err: 음가 오류 (길이 다름)
    if ($ln.Contains('<strong>음가 오류:</strong>')) {
        $lines[$i] = '                    showValidationAlert(`${order}번째 음 길이가 달라요!<br>지금 <strong>${describePracticeEvent(current)}</strong>를 넣었지만, 예시는 <strong>${describePracticeEvent(expected)}</strong>이에요.<br><strong>삭제</strong> 버튼으로 지우고 올바른 기호를 다시 선택하세요.`);'
        Write-Host "OK: err 음가 line $($i+1)"
    }

    # err: 위치 오류
    if ($ln.Contains('<strong>위치 오류:</strong>')) {
        $lines[$i] = '                    showValidationAlert(`${order}번째 기호의 위치가 달라요!<br>앞에 빈칸이 있거나 길이가 맞지 않는 기호가 있을 수 있어요.<br>앞 기호부터 하나씩 확인해 보세요.`);'
        Write-Host "OK: err 위치 line $($i+1)"
    }

    # err: 붙임줄 없음
    if ($ln.Contains('마지막 두 8분음표의 종류와 위치는 맞지만 붙임줄 연결이 없습니다')) {
        $lines[$i] = '                        showValidationAlert(`붙임줄을 아직 연결하지 않았어요!<br>위쪽 <strong>[붙임줄]</strong> 버튼을 누른 뒤,<br>연결할 첫 번째 음표 → 두 번째 음표 순서로 눌러 보세요.`);'
        Write-Host "OK: err 붙임줄없음 line $($i+1)"
    }

    # err: 붙임줄 잘못됨
    if ($ln.Contains('예시에서 연결하지 않은 음표에 붙임줄이 있습니다')) {
        $lines[$i] = '                        showValidationAlert(`붙임줄이 잘못 연결되어 있어요!<br><strong>되돌리기</strong> 버튼을 눌러 붙임줄을 취소하고 다시 확인해 보세요.`);'
        Write-Host "OK: err 붙임줄잘못됨 line $($i+1)"
    }

    # err: 기호 많음
    if ($ln.Contains('끝에 추가된 기호를 선택 삭제한 뒤 다시 확인하세요')) {
        $lines[$i] = $lines[$i] -replace '예시보다 기호가 \$\{actual\.length - target\.length\}개 많습니다\. 끝에 추가된 기호를 선택 삭제한 뒤 다시 확인하세요\.', '기호가 ${actual.length - target.length}개 더 많아요!<br>끝에 있는 기호를 <strong>삭제</strong> 버튼으로 지운 다음 다시 확인해 보세요.'
        Write-Host "OK: err 기호많음 line $($i+1)"
    }

    # dot: 마디 끝 초과
    if ($ln.Contains('가 마디 끝에 너무 가깝습니다')) {
        $lines[$i] = $lines[$i] -replace '\. <strong>원인:</strong> \$\{describePracticeEvent\(target\)\}가 마디 끝에 너무 가깝습니다\. <strong>수정:</strong> 앞쪽의 점을 붙일 음표를 악보에서 선택하거나, 뒤 기호를 선택 삭제해 빈칸을 만든 뒤 다시 누르세요\.', '.<br>점을 붙이면 마디 끝을 넘어요!<br>뒤쪽 기호를 <strong>삭제</strong>해서 자리를 만든 다음 다시 눌러 보세요.'
        Write-Host "OK: dot 초과 line $($i+1)"
    }

    # dot: 박 충돌
    if ($ln.Contains('남은 칸이 부족합니다')) {
        $lines[$i] = $lines[$i] -replace '박 안의 남은 칸이 부족합니다\. <strong>원인:</strong> 점을 붙이면 뒤 기호와 겹칩니다\. <strong>수정:</strong> 겹치는 뒤 음표나 쉼표를 선택 삭제한 뒤 다시 점을 누르세요\.', '점을 붙이면 옆 기호와 겹쳐요!<br>뒤에 있는 음표나 쉼표를 <strong>삭제</strong>한 다음 다시 눌러 보세요.'
        Write-Host "OK: dot 박충돌 line $($i+1)"
    }

    # dot: 단순 겹침
    if ($ln.Contains('점을 붙이면 다음 음표와 겹칩니다')) {
        $lines[$i] = $lines[$i] -replace '점을 붙이면 다음 음표와 겹칩니다\. <strong>수정:</strong> 뒤 음표나 쉼표를 선택 삭제한 뒤 다시 점을 누르세요\.', '점을 붙이면 옆 기호와 겹쳐요!<br>뒤에 있는 음표나 쉼표를 <strong>삭제</strong>한 다음 다시 눌러 보세요.'
        Write-Host "OK: dot 겹침 line $($i+1)"
    }

    # 셋잇단 6/8 오류
    if ($ln.Contains('6/8박자는 8분음표 3개씩 묶이는 겹박자라 셋잇단음표를 넣지 않습니다')) {
        $lines[$i] = '                showValidationAlert(`6/8박자에는 셋잇단음표를 넣지 않아요!<br>대신 <strong>8분음표</strong>나 <strong>16분음표</strong>를 사용해 보세요.`);'
        Write-Host "OK: triplet 6/8 line $($i+1)"
    }

    # 점 없는 기호 오류
    if ($ln.Contains('셋잇단음표에는 점을 붙이지 않아요')) {
        # Already child-friendly, keep
    }
}

# tutorialSteps 배열 교체 (라인 기반)
$tsStartLine = -1
$tsEndLine = -1
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Contains("const tutorialSteps = [")) {
        $tsStartLine = $i
    }
    if ($tsStartLine -ge 0 -and $i -gt $tsStartLine -and $lines[$i].TrimEnd() -eq "        ];") {
        $tsEndLine = $i
        break
    }
}
if ($tsStartLine -ge 0 -and $tsEndLine -gt $tsStartLine) {
    $newTSLines = @(
        "        const tutorialSteps = [",
        "            {",
        "                title: '1단계: 음표 넣기',",
        "                body: '아래 버튼에서 <strong>4분음표</strong>, <strong>8분음표</strong> 등 음표를 눌러 악보에 넣어요!<br><small>음표 = 소리가 나는 기호예요.</small>',",
        "                anchor: 'noteRestButtons',",
        "                placement: 'top'",
        "            },",
        "            {",
        "                title: '2단계: 쉼표 넣기',",
        "                body: '쉼표 버튼의 <strong>4분쉼표</strong>, <strong>8분쉼표</strong>를 누르면 쉬는 자리를 넣을 수 있어요!<br><small>쉼표 = 잠깐 쉬는 기호예요.</small>',",
        "                anchor: 'noteRestButtons',",
        "                placement: 'top'",
        "            },",
        "            {",
        "                title: '3단계: 점(.) 붙이기',",
        "                body: '음표나 쉼표를 선택한 뒤 <strong>[ . ] (점)</strong> 버튼을 눌러 보세요!<br>점을 붙이면 그 기호의 길이가 1.5배가 돼요!',",
        "                anchor: 'dotButton',",
        "                placement: 'top'",
        "            },",
        "            {",
        "                title: '4단계: 붙임줄 만들기',",
        "                body: '음표를 이어 붙이고 싶다면 <strong>[붙임줄]</strong> 버튼을 누른 뒤,<br>이어 붙일 첫 번째 음표 → 두 번째 음표 순서로 눌러 보세요!',",
        "                anchor: 'tie',",
        "                placement: 'top'",
        "            },",
        "            {",
        "                title: '5단계: 내 리듬 들어보기',",
        "                body: '아래 <strong>[이 마디 듣기]</strong> 버튼을 눌러 내가 만든 리듬을 들어봐요!<br><small>반복 재생되니까 수정하면서 들을 수 있어요.</small>',",
        "                anchor: 'play',",
        "                placement: 'top'",
        "            }",
        "        ];"
    )
    $beforeLines = $lines[0..($tsStartLine - 1)]
    $afterLines  = $lines[($tsEndLine + 1)..($lines.Length - 1)]
    $lines = $beforeLines + $newTSLines + $afterLines
    Write-Host "OK: tutorialSteps replaced (lines $($tsStartLine+1)..$($tsEndLine+1))"
} else {
    Write-Host "SKIP: tutorialSteps lines not found (start=$tsStartLine end=$tsEndLine)"
}

# 저장
[System.IO.File]::WriteAllLines($indexPath, $lines, [System.Text.Encoding]::UTF8)
Write-Host ""
Write-Host "ALL DONE"
