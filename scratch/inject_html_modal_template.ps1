$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

# Replace function body to use HTML modal overlay
$jsCode = @"
        function showPracticeSuccessChoiceModal() {
            let modal = document.getElementById('practiceSuccessChoiceModal');
            if (modal) {
                modal.classList.add('show');
            }
        }

        function closePracticeSuccessChoiceModal() {
            const modal = document.getElementById('practiceSuccessChoiceModal');
            if (modal) modal.classList.remove('show');
        }
"@

# Fix indices
$startIdx = -1
$endIdx = -1
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "function showPracticeSuccessChoiceModal") {
        $startIdx = $i
    }
    if ($startIdx -ge 0 -and $lines[$i] -match "closePracticeSuccessChoiceModal\(\) \{") {
        $endIdx = $i + 2
        break
    }
}

if ($startIdx -ge 0 -and $endIdx -gt $startIdx) {
    $newList = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $startIdx; $i++) { $newList.Add($lines[$i]) }
    $newList.Add($jsCode)
    for ($i = $endIdx + 1; $i -lt $lines.Length; $i++) { $newList.Add($lines[$i]) }
    $lines = $newList.ToArray()
}

# Now inject HTML modal markup before </body>
$htmlModalMarkup = @"
    <!-- 🏆 예시 따라 하기 성공 후 독립 창작 전환 선택 팝업 -->
    <div id="practiceSuccessChoiceModal" class="choice-dialog" role="dialog" aria-modal="true" style="z-index: 100090;">
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
    </div>
"@

$finalList = [System.Collections.Generic.List[string]]::new()
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "</body>") {
        $finalList.Add($htmlModalMarkup)
    }
    $finalList.Add($lines[$i])
}

[System.IO.File]::WriteAllLines($indexPath, $finalList.ToArray(), [System.Text.Encoding]::UTF8)
Write-Host "INJECT_HTML_MODAL_SUCCESS"
