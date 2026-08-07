# apply_new_patch.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)

$blocksText = [System.IO.File]::ReadAllText('scratch/new_blocks.txt', $utf8) -replace "`r`n", "`n"
$htmlContent = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

function ExtractBlock([string]$tag) {
    $startTag = "===$tag==="
    $s = $blocksText.IndexOf($startTag)
    if ($s -lt 0) { return "" }
    $s += $startTag.Length + 1
    $nextTag = "==="
    $e = $blocksText.IndexOf($nextTag, $s)
    if ($e -lt 0) { $e = $blocksText.Length }
    return $blocksText.Substring($s, $e - $s).TrimEnd()
}

$headerBlock = ExtractBlock("NEW_HEADER")
$controlsBlock = ExtractBlock("NEW_CONTROLS")
$tieCurveBlock = ExtractBlock("NEW_TIE_CURVE")
$practiceBlock = ExtractBlock("NEW_PRACTICE_TARGET")
$tutorialStepsBlock = ExtractBlock("NEW_TUTORIAL_STEPS")
$tutorialAnchorBlock = ExtractBlock("NEW_TUTORIAL_ANCHOR")

Write-Host "Extracted new blocks successfully." -ForegroundColor Cyan

# 1. Header replace
$h1Search = '<h1 class="text-xl md:text-2xl'
$h1Idx = $htmlContent.IndexOf($h1Search)
if ($h1Idx -ge 0) {
    $headerEndIdx = $htmlContent.IndexOf('</header>', $h1Idx)
    $oldHeaderInner = $htmlContent.Substring($h1Idx, $headerEndIdx - $h1Idx)
    $htmlContent = $htmlContent.Replace($oldHeaderInner, $headerBlock + "`n    ")
    Write-Host "1. Header updated OK" -ForegroundColor Green
} else {
    Write-Host "WARNING: Header not found" -ForegroundColor Red
}

# 2. Controls replace
$ctrlSearch = '<div class="playback-controls'
$ctrlIdx = $htmlContent.IndexOf($ctrlSearch)
if ($ctrlIdx -ge 0) {
    $ctrlEndIdx = $htmlContent.IndexOf('</div>', $ctrlIdx)
    # Find matching closing div for playback-controls (until play-buttons)
    $playBtnIdx = $htmlContent.IndexOf('<div class="play-buttons', $ctrlIdx)
    if ($playBtnIdx -gt $ctrlIdx) {
        $oldControls = $htmlContent.Substring($ctrlIdx, $playBtnIdx - $ctrlIdx)
        $htmlContent = $htmlContent.Replace($oldControls, $controlsBlock + "`n`n        ")
        Write-Host "2. Controls updated OK" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: Controls not found" -ForegroundColor Red
}

# 3. drawTieCurve replace
$tieSearch = "function drawTieCurve("
$tieIdx = $htmlContent.IndexOf($tieSearch)
if ($tieIdx -ge 0) {
    $tieEndIdx = $htmlContent.IndexOf("function drawAllTies(", $tieIdx)
    $oldTie = $htmlContent.Substring($tieIdx, $tieEndIdx - $tieIdx)
    $htmlContent = $htmlContent.Replace($oldTie, $tieCurveBlock + "`n`n        ")
    Write-Host "3. drawTieCurve updated OK" -ForegroundColor Green
} else {
    Write-Host "WARNING: drawTieCurve not found" -ForegroundColor Red
}

# 4. practice target & example replace
$pracSearch = "// 사진 속 4/4박자 예시 리듬"
$pracIdx = $htmlContent.IndexOf($pracSearch)
if ($pracIdx -lt 0) { $pracSearch = "function getFourFourPracticeExample()"; $pracIdx = $htmlContent.IndexOf($pracSearch) }
if ($pracIdx -ge 0) {
    $pracEndIdx = $htmlContent.IndexOf("function describePracticeEvent(", $pracIdx)
    if ($pracEndIdx -gt $pracIdx) {
        $oldPractice = $htmlContent.Substring($pracIdx, $pracEndIdx - $pracIdx)
        $htmlContent = $htmlContent.Replace($oldPractice, $practiceBlock + "`n`n        ")
        Write-Host "4. Practice target logic updated OK" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: Practice logic not found" -ForegroundColor Red
}

# 5. tutorialSteps replace
$stepSearch = "const tutorialSteps = ["
$stepIdx = $htmlContent.IndexOf($stepSearch)
if ($stepIdx -ge 0) {
    $stepEndIdx = $htmlContent.IndexOf("];", $stepIdx) + 2
    $oldSteps = $htmlContent.Substring($stepIdx, $stepEndIdx - $stepIdx)
    $htmlContent = $htmlContent.Replace($oldSteps, $tutorialStepsBlock)
    Write-Host "5. tutorialSteps updated OK" -ForegroundColor Green
} else {
    Write-Host "WARNING: tutorialSteps not found" -ForegroundColor Red
}

# 6. getTutorialAnchor replace
$ancSearch = "function getTutorialAnchor(anchor) {"
$ancIdx = $htmlContent.IndexOf($ancSearch)
if ($ancIdx -ge 0) {
    $ancEndIdx = $htmlContent.IndexOf("function normalizeTutorialTargets(", $ancIdx)
    if ($ancEndIdx -gt $ancIdx) {
        $oldAnchor = $htmlContent.Substring($ancIdx, $ancEndIdx - $ancIdx)
        $htmlContent = $htmlContent.Replace($oldAnchor, $tutorialAnchorBlock + "`n`n        ")
        Write-Host "6. getTutorialAnchor updated OK" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: getTutorialAnchor not found" -ForegroundColor Red
}

$finalContent = $htmlContent -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Saved all new updates to index.html successfully!" -ForegroundColor Green
