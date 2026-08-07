$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$content = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

# 1. Update tutorial tie step placement to top so card floats directly above btn-tie-note
$oldTieStep = @"
            {
                title: '붙임줄 연결하기',
                body: '⌒ 붙임줄 버튼을 누른 뒤 이어 붙일 두 음표를 차례로 누르면 하나로 연결돼요!',
                anchor: 'tie',
                placement: 'bottom'
            }
"@

$newTieStep = @"
            {
                title: '붙임줄 연결하기 ⌒',
                body: '하단 도구 모음의 보라색 <strong>[⌒ 붙임줄]</strong> 버튼을 누른 뒤, 연결할 두 음표를 차례로 선택하면 하나로 연결돼요!',
                anchor: 'tie',
                placement: 'top'
            }
"@

if ($content.Contains("anchor: 'tie'")) {
    $content = $content.Replace($oldTieStep, $newTieStep)
}

# 2. Add Guided Practice Success Modal & Update checkGuidedPractice success behavior
$oldSuccessBlock = "playTone(880, 0.12, 0.12, 'sine');`r`n            showToast('예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.', true);"
$oldSuccessBlockUnix = "playTone(880, 0.12, 0.12, 'sine');`n            showToast('예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.', true);"

$newSuccessBlock = @"
            playTone(880, 0.12, 0.12, 'sine');
            guidedPracticeTarget = null;
            practiceStatusMode = null;
            hidePracticeStatus();
            drawAll();
            showPracticeSuccessChoiceModal();
"@

if ($content.Contains("showToast('예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.', true);")) {
    $content = $content.Replace("showToast('예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.', true);", "guidedPracticeTarget = null; practiceStatusMode = null; hidePracticeStatus(); drawAll(); showPracticeSuccessChoiceModal();")
}

# 3. Inject showPracticeSuccessChoiceModal definition into script
$modalFn = @"
        function showPracticeSuccessChoiceModal() {
            let modal = document.getElementById('practiceSuccessChoiceModal');
            if (!modal) {
                const div = document.createElement('div');
                div.id = 'practiceSuccessChoiceModal';
                div.className = 'choice-dialog show';
                div.style.zIndex = '100090';
                div.innerHTML = ``
                    <div class="choice-card" style="width: min(460px, calc(100vw - 28px)); text-align: center; padding: 24px;">
                        <h2 class="choice-title" style="color: #1e3a8a; font-size: 22px; margin-bottom: 10px;">🎉 예시 리듬 완벽 성공!</h2>
                        <p class="choice-description" style="font-size: 14px; color: #334155; line-height: 1.6; margin-bottom: 20px;">
                            예시 리듬을 완벽하게 맞췄습니다!<br>이제 <strong>3. 독립 창작</strong> 단계로 넘어가 나만의 리듬을 자유롭게 만들어 볼까요?
                        </p>
                        <div class="flex flex-col gap-2">
                            <button type="button" onclick="closePracticeSuccessChoiceModal(); startIndependentCreation();" class="w-full py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-black text-sm rounded-xl shadow-md transition">
                                🎨 3. 독립 창작 시작하기 (자유롭게 만들기)
                            </button>
                            <button type="button" onclick="closePracticeSuccessChoiceModal(); startGuidedPractice();" class="w-full py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs rounded-xl border border-slate-300 transition">
                                🔁 2. 예시 다시 따라 만들기
                            </button>
                        </div>
                    </div>
                ``;
                document.body.appendChild(div);
            } else {
                modal.classList.add('show');
            }
        }

        function closePracticeSuccessChoiceModal() {
            const modal = document.getElementById('practiceSuccessChoiceModal');
            if (modal) modal.classList.remove('show');
        }
"@

# Fix double backtick string in PowerShell template
$modalFnFixed = @"
        function showPracticeSuccessChoiceModal() {
            let modal = document.getElementById('practiceSuccessChoiceModal');
            if (!modal) {
                const div = document.createElement('div');
                div.id = 'practiceSuccessChoiceModal';
                div.className = 'choice-dialog show';
                div.style.zIndex = '100090';
                div.innerHTML = '<div class="choice-card" style="width: min(460px, calc(100vw - 28px)); text-align: center; padding: 24px;"><h2 class="choice-title" style="color: #1e3a8a; font-size: 22px; margin-bottom: 10px;">🎉 예시 리듬 완벽 성공!</h2><p class="choice-description" style="font-size: 14px; color: #334155; line-height: 1.6; margin-bottom: 20px;">예시 리듬을 완벽하게 맞췄습니다!<br>이제 <strong>3. 독립 창작</strong> 단계로 넘어가 나만의 리듬을 자유롭게 만들어 볼까요?</p><div class="flex flex-col gap-2"><button type="button" onclick="closePracticeSuccessChoiceModal(); startIndependentCreation();" class="w-full py-3 bg-indigo-600 hover:bg-indigo-700 text-white font-black text-sm rounded-xl shadow-md transition">🎨 3. 독립 창작 시작하기 (자유롭게 만들기)</button><button type="button" onclick="closePracticeSuccessChoiceModal(); startGuidedPractice();" class="w-full py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold text-xs rounded-xl border border-slate-300 transition">🔁 2. 예시 다시 따라 만들기</button></div></div>';
                document.body.appendChild(div);
            } else {
                modal.classList.add('show');
            }
        }

        function closePracticeSuccessChoiceModal() {
            const modal = document.getElementById('practiceSuccessChoiceModal');
            if (modal) modal.classList.remove('show');
        }
"@

if (-not $content.Contains("function showPracticeSuccessChoiceModal()")) {
    $content = $content.Replace("function startIndependentCreation()", $modalFnFixed + "`r`n`r`n        function startIndependentCreation()")
}

[System.IO.File]::WriteAllText($indexPath, $content, [System.Text.Encoding]::UTF8)
Write-Host "PRACTICE_FLOW_PATCH_SUCCESS"
