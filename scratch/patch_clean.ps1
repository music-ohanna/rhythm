$filePath = Join-Path $PSScriptRoot "..\index.html"
$lines = [System.IO.File]::ReadAllLines($filePath, [System.Text.Encoding]::UTF8)

# 1. Insert newScreenDialog modal after submissionDialog (around line 685)
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'id="submissionDialog"') {
        # find closing </div> of submissionDialog
        for ($j = $i; $j -lt $lines.Length; $j++) {
            if ($lines[$j] -match '</div>' -and $lines[$j+1] -match '</div>') {
                $dialogInsertion = @"

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
    </div>
"@
                $lines[$j+1] = $lines[$j+1] + "`n" + $dialogInsertion
                Write-Host "Inserted newScreenDialog modal after line $($j+1)"
                break
            }
        }
        break
    }
}

# 2. Make Logo Clickable
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '🎵 리듬 창작 앱') {
        # find the <h1 tag right before or on this line
        for ($k = [Math]::Max(0, $i - 3); $k -le $i; $k++) {
            if ($lines[$k] -match '<h1') {
                $lines[$k] = '        <h1 onclick="openNewScreenModal()" class="text-xl md:text-2xl font-black text-slate-900 tracking-tight flex items-center cursor-pointer hover:opacity-80 transition-opacity" title="새 화면으로 이동 (작업 저장/초기화)">'
                Write-Host "Updated h1 tag on line $($k+1)"
                break
            }
        }
        break
    }
}

# 3. Update Help Button in Header
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'id="btn-help-tutorial"') {
        $lines[$i] = '                <button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm" title="이동식 도움말 투어 시작">'
        Write-Host "Updated btn-help-tutorial on line $($i+1)"
        break
    }
}

# 4. Update tutorialSteps array
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'const tutorialSteps = \[') {
        # Find closing ];
        $endIdx = $i
        for ($j = $i; $j -lt $lines.Length; $j++) {
            if ($lines[$j] -match '^\s*\];') {
                $endIdx = $j
                break
            }
        }
        $newStepsContent = @"
        const tutorialSteps = [
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
        ];
"@
        # Replace range from $i to $endIdx with newStepsContent
        $before = $lines[0..($i-1)]
        $after = $lines[($endIdx+1)..($lines.Length-1)]
        $newScript = $before + ($newStepsContent -split "`r?\n") + $after
        $lines = $newScript
        Write-Host "Updated tutorialSteps array"
        break
    }
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($filePath, $lines, $utf8NoBom)
Write-Host "Successfully patched index.html!"
