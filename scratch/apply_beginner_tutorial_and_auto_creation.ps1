$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

# 1. Fix encoding for header practice button
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'id="btn-header-practice"') {
        $lines[$i] = '                <button id="btn-header-practice" onclick="openPracticePanel()" class="text-tool-btn text-xs md:text-sm" style="background:#eff6ff !important; color:#1d4ed8 !important; border-color:#93c5fd !important; font-weight:900;" title="단계별 리듬 연습"><span class="text-base">🎯</span> 연습</button>'
        Write-Host "Fixed header practice button text"
    }
}

# 2. Update tutorialSteps array to beginner-friendly 5 steps
$oldTutorialStart = -1
$oldTutorialEnd = -1
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "const tutorialSteps = \[") {
        $oldTutorialStart = $i
    }
    if ($oldTutorialStart -ge 0 -and $lines[$i] -match "\];") {
        $oldTutorialEnd = $i
        break
    }
}

$newTutorialSteps = @"
        const tutorialSteps = [
            {
                title: '🎵 1단계: 음표 넣기',
                body: '아래 입력표에서 <strong>4분음표(♩)</strong>, <strong>8분음표(♪)</strong> 등 음표를 눌러 악보에 넣어요.',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '🔇 2단계: 쉼표 넣기',
                body: '쉼표 줄의 <strong>4분쉼표(𝄽)</strong>, <strong>8분쉼표(𝄾)</strong>를 누르면 쉬는 박자를 넣을 수 있어요.',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '• 3단계: 점( . ) 만들기',
                body: '표 오른쪽 끝의 <strong>[ . ] (점)</strong> 버튼을 누르면 방금 넣은 음표가 점음표가 돼요!',
                anchor: 'dotButton',
                placement: 'top'
            },
            {
                title: '⌒ 4단계: 붙임줄 연결하기',
                body: '음표를 다 만든 뒤, 하단 검은색 <strong>[⌒ 붙임줄]</strong> 버튼을 누르고 이어 붙일 두 음표를 차례로 선택하세요!',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '▶️ 5단계: 만든 리듬 듣기',
                body: '하단 <strong>[▶ 이 마디 듣기]</strong> 버튼을 눌러 만든 리듬을 소리로 들어보세요.',
                anchor: 'play',
                placement: 'top'
            }
        ];
"@

if ($oldTutorialStart -ge 0 -and $oldTutorialEnd -gt $oldTutorialStart) {
    $newList = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $oldTutorialStart; $i++) { $newList.Add($lines[$i]) }
    $newList.Add($newTutorialSteps)
    for ($i = $oldTutorialEnd + 1; $i -lt $lines.Length; $i++) { $newList.Add($lines[$i]) }
    $lines = $newList.ToArray()
    Write-Host "Updated tutorial steps"
}

# 3. Update checkGuidedPractice to automatically jump to independent creation mode on success
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "checkGuidedPractice\(\)") {
        for ($j = $i; $j -lt $i + 60; $j++) {
            if ($lines[$j] -match "playTone\(880" -or $lines[$j] -match "showPracticeSuccessChoiceModal") {
                $lines[$j] = "            playTone(880, 0.15, 0.15, 'sine'); playTone(1046, 0.25, 0.2, 'sine');`r`n            guidedPracticeTarget = null;`r`n            practiceStatusMode = null;`r`n            hidePracticeStatus();`r`n            drawAll();`r`n            startIndependentCreation();`r`n            showToast('🎉 정답입니다! 예시를 완벽히 맞췄습니다. 이제 나만의 리듬을 자유롭게 만들어 보세요!', true);"
                break
            }
        }
    }
}

[System.IO.File]::WriteAllLines($indexPath, $lines, [System.Text.Encoding]::UTF8)
Write-Host "BEGINNER_TUTORIAL_PATCH_SUCCESS"
