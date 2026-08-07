
$path = "c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm\index.html"
$bytes = [System.IO.File]::ReadAllBytes($path)
$text = [System.Text.Encoding]::UTF8.GetString($bytes)

# 1. showMeasureOverflowWarning
$old1 = "        let warningShowing = false;`n        let lastWarningMessage = '';`n        let warningTimer = null;`n`n        function showValidationAlert(msg) {"
$new1 = "        let warningShowing = false;`n        let lastWarningMessage = '';`n        let warningTimer = null;`n`n        function showMeasureOverflowWarning(type, dotted) {`n            const names = {whole:'온음표', half:'2분음표', quarter:'4분음표', eighth:'8분음표', sixteenth:'16분음표', thirtysecond:'32분음표', triplet:'셋잇단음표'};`n            const typeName = (names[type] || '음표');`n            const dottedStr = dotted ? '점' : '';`n            const msg = '<strong>' + dottedStr + typeName + '</strong>은 이 자리에 넣기엔 너무 길어요! 🎵<br>더 짧은 음표나 쉼표를 선택해 보세요.<br><small>예: 4분음표 자리엔 8분음표 2개가 딱 맞아요.</small>';`n            showValidationAlert(msg);`n        }`n`n        function showValidationAlert(msg) {"

if ($text.Contains($old1)) {
    $text = $text.Replace($old1, $new1)
    Write-Host "OK: 1. showMeasureOverflowWarning"
} else {
    Write-Host "SKIP: 1. showMeasureOverflowWarning (pattern mismatch)"
}

# 2. overflow args
$text = $text.Replace("showMeasureOverflowWarning();", "showMeasureOverflowWarning(type, dotted);")

# 3. tutorialSteps
$tsOldPattern = "(?s)const tutorialSteps = \[.*?\];"
$tsNewContent = @"
const tutorialSteps = [
            {
                title: '🎵 1단계: 음표 넣기',
                body: '아래 버튼에서 <strong>4분음표</strong>, <strong>8분음표</strong> 등 음표를 눌러 악보에 넣어요!<br><small>음표 = 소리가 나는 기호예요.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '🎵 2단계: 쉼표 넣기',
                body: '쉼표 버튼의 <strong>4분쉼표</strong>, <strong>8분쉼표</strong>를 누르면 쉬는 자리를 넣을 수 있어요!<br><small>쉼표 = 잠깐 쉬는 기호예요.</small>',
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
$text = [regex]::Replace($text, $tsOldPattern, $tsNewContent)
Write-Host "OK: 3. tutorialSteps"

# 4. Error messages (Child friendly)
$errMap = @{
    '<strong>기호 수 오류:</strong> ${order}번째 기호가 비어 있습니다. 예시의 <strong>${describePracticeEvent(expected)}</strong>를 이어서 입력하세요.' = '${order}번째 기호가 빠졌어요! 🎵<br>회색 기호 중 <strong>${describePracticeEvent(expected)}</strong>를 눌러 입력해 보세요.';
    '<strong>음표·쉼표 종류 오류:</strong> ${order}번째는 현재 ${current.isRest ? ''쉼표'' : ''음표''}이지만 예시는 ${expected.isRest ? ''쉼표'' : ''음표''}입니다. 선택 삭제로 지운 뒤 <strong>${describePracticeEvent(expected)}</strong>를 입력하세요.' = '${order}번째가 달라요! ✏️<br>지금은 <strong>${current.isRest ? ''쉼표'' : ''음표''}</strong>를 넣었는데, 예시는 <strong>${expected.isRest ? ''쉼표'' : ''음표''}</strong>예요.<br>위의 <strong>삭제</strong> 버튼으로 지운 다음 <strong>${describePracticeEvent(expected)}</strong>를 다시 눌러 보세요.';
    '<strong>음가 오류:</strong> ${order}번째는 현재 <strong>${describePracticeEvent(current)}</strong>, 예시는 <strong>${describePracticeEvent(expected)}</strong>입니다. 길이가 다른 기호이므로 선택 삭제 후 예시와 같은 음가로 다시 입력하세요.' = '${order}번째 음 길이가 달라요! 🕐<br>지금 <strong>${describePracticeEvent(current)}</strong>를 넣었지만, 예시는 <strong>${describePracticeEvent(expected)}</strong>이에요.<br><strong>삭제</strong> 버튼으로 지우고 올바른 기호를 다시 선택하세요.';
    '<strong>위치 오류:</strong> ${order}번째 기호의 시작 위치가 예시와 다릅니다. 앞부분의 빈칸이나 잘못된 음가가 원인입니다. 앞 기호부터 확인하여 빈칸을 채우거나 잘못된 기호를 수정하세요.' = '${order}번째 기호의 위치가 달라요! 📍<br>앞에 빈칸이 있거나 길이가 맞지 않는 기호가 있을 수 있어요.<br>앞 기호부터 하나씩 확인해 보세요.';
    '<strong>붙임줄 오류:</strong> 마지막 두 8분음표의 종류와 위치는 맞지만 붙임줄 연결이 없습니다. 위의 <strong>붙임줄</strong> 버튼을 누른 뒤 두 음표를 왼쪽부터 차례로 선택하세요.' = '붙임줄을 아직 연결하지 않았어요! 🔗<br>위쪽 <strong>[붙임줄 🔗]</strong> 버튼을 누른 뒤,<br>연결할 첫 번째 음표 → 두 번째 음표 순서로 눌러 보세요.';
    '<strong>붙임줄 오류:</strong> 예시에서 연결하지 않은 음표에 붙임줄이 있습니다. 되돌리기로 연결을 취소한 뒤 다시 확인하세요.' = '붙임줄이 잘못 연결되어 있어요! ✏️<br><strong>되돌리기</strong> 버튼을 눌러 붙임줄을 취소하고 다시 확인해 보세요.';
    '예시보다 기호가 ${actual.length - target.length}개 많습니다. 끝에 추가된 기호를 선택 삭제한 뒤 다시 확인하세요.' = '기호가 ${actual.length - target.length}개 더 많아요! ✂️<br>끝에 있는 기호를 <strong>삭제</strong> 버튼으로 지운 다음 다시 확인해 보세요.';
    'showToast(''예시 리듬과 같습니다! 이제 단계 연습에서 독립 창작으로 넘어가세요.'', true);' = 'showToast(''🎉 정답이에요! 예시를 완벽히 따라했어요!'', true);`n            setTimeout(() => { const modal = document.getElementById(''practiceSuccessChoiceModal''); if (modal) modal.classList.add(''show''); }, 700);'
}

foreach ($k in $errMap.Keys) {
    if ($text.Contains($k)) {
        $text = $text.Replace($k, $errMap[$k])
        Write-Host "OK: error msg replaced"
    } else {
        Write-Host "SKIP err msg: $k"
    }
}

$outBytes = [System.Text.Encoding]::UTF8.GetBytes($text)
[System.IO.File]::WriteAllBytes($path, $outBytes)
Write-Host "PURE POWERSHELL PATCH COMPLETE!"
