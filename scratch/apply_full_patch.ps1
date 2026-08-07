$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$content = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

# 1. Update meta viewport for pinch-zoom and responsive scaling
$oldViewport = '<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">'
$newViewport = '<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=0.3, maximum-scale=5.0, user-scalable=yes, viewport-fit=cover">'
if ($content.Contains($oldViewport)) {
    $content = $content.Replace($oldViewport, $newViewport)
}

# 2. Fix body styling for zoom and scrolling
$oldBodyCss = "touch-action: none;"
$newBodyCss = "touch-action: manipulation;"
$content = $content.Replace("touch-action: none;`r`n            background-color: #f8fafc;", "touch-action: manipulation;`r`n            background-color: #f8fafc;")
$content = $content.Replace("touch-action: none;`n            background-color: #f8fafc;", "touch-action: manipulation;`n            background-color: #f8fafc;")
$content = $content.Replace("overflow: hidden;`r`n            user-select: none;", "overflow-x: auto; overflow-y: auto;`r`n            user-select: none;")
$content = $content.Replace("overflow: hidden;`n            user-select: none;", "overflow-x: auto; overflow-y: auto;`n            user-select: none;")

# 3. Add Practice button to header
$headerBtnTarget = '<button id="btn-undo"'
$headerBtnInsert = '<button id="btn-header-practice" onclick="openPracticePanel()" class="text-tool-btn text-xs md:text-sm" style="background:#eff6ff !important; color:#1d4ed8 !important; border-color:#93c5fd !important; font-weight:900;" title="단계별 리듬 연습"><span class="text-base">🎯</span> 연습</button>' + "`r`n                " + '<button id="btn-undo"'

if (-not $content.Contains("btn-header-practice")) {
    $content = $content.Replace($headerBtnTarget, $headerBtnInsert)
}

# 4. Highlight Tie button (btn-tie-note)
$oldTieBtn = '<button id="btn-tie-note" onclick="toggleTieMode()" class="text-tool-btn text-xs" title="붙임줄 만들기">'
$newTieBtn = '<button id="btn-tie-note" onclick="toggleTieMode()" class="text-tool-btn text-xs font-black" style="background:#4f46e5 !important; color:#ffffff !important; border:2px solid #3730a3 !important; font-weight:900 !important; padding:5px 12px !important; border-radius:10px !important; box-shadow:0 2px 5px rgba(79,70,229,0.35);" title="두 음표를 연결하는 붙임줄 만들기">'
if ($content.Contains($oldTieBtn)) {
    $content = $content.Replace($oldTieBtn, $newTieBtn)
}

# 5. Fix setTimeSig to clear guided practice state when switching meters
$oldTimeSigLine = "timeSignature.top = top; timeSignature.bottom = bottom;"
$newTimeSigLine = "timeSignature.top = top; timeSignature.bottom = bottom; guidedPracticeTarget = null; practiceStatusMode = null; hidePracticeStatus();"
if ($content.Contains($oldTimeSigLine) -and -not $content.Contains("guidedPracticeTarget = null; practiceStatusMode = null; hidePracticeStatus();")) {
    $content = $content.Replace($oldTimeSigLine, $newTimeSigLine)
}

# Save updated HTML
[System.IO.File]::WriteAllText($indexPath, $content, [System.Text.Encoding]::UTF8)
Write-Host "FULL_PATCH_SUCCESS"
