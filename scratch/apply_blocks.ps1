# apply_blocks.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)

$blocksText = [System.IO.File]::ReadAllText('scratch/blocks.txt', $utf8) -replace "`r`n", "`n"
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

$block1 = ExtractBlock("BLOCK1")
$block2 = ExtractBlock("BLOCK2")
$block3 = ExtractBlock("BLOCK3")
$block4 = ExtractBlock("BLOCK4")
$block5 = ExtractBlock("BLOCK5")

Write-Host "Extracted blocks:"
Write-Host "Block 1 len: $($block1.Length)"
Write-Host "Block 2 len: $($block2.Length)"
Write-Host "Block 3 len: $($block3.Length)"
Write-Host "Block 4 len: $($block4.Length)"
Write-Host "Block 5 len: $($block5.Length)"

# 1. tutorialSteps
$stepSearch = "const tutorialSteps = ["
$stepIdx = $htmlContent.IndexOf($stepSearch)
if ($stepIdx -ge 0) {
    $stepEndIdx = $htmlContent.IndexOf("];", $stepIdx) + 2
    $oldStepsBlock = $htmlContent.Substring($stepIdx, $stepEndIdx - $stepIdx)
    $htmlContent = $htmlContent.Replace($oldStepsBlock, $block1)
    Write-Host "1. tutorialSteps replaced OK" -ForegroundColor Green
}

# 2. help button
$helpBtnSearch = '<button id="btn-help-tutorial"'
$helpBtnIdx = $htmlContent.IndexOf($helpBtnSearch)
if ($helpBtnIdx -ge 0) {
    $helpBtnEnd = $htmlContent.IndexOf('</button>', $helpBtnIdx) + 9
    $oldBtn = $htmlContent.Substring($helpBtnIdx, $helpBtnEnd - $helpBtnIdx)
    $htmlContent = $htmlContent.Replace($oldBtn, $block2)
    Write-Host "2. help button replaced OK" -ForegroundColor Green
}

# 3. helpSimpleModal remove
$modalSearch = '<div id="helpSimpleModal"'
$modalIdx = $htmlContent.IndexOf($modalSearch)
if ($modalIdx -ge 0) {
    $scriptIdx = $htmlContent.IndexOf('<script>', $modalIdx)
    if ($scriptIdx -gt $modalIdx) {
        $modalBlock = $htmlContent.Substring($modalIdx, $scriptIdx - $modalIdx)
        $htmlContent = $htmlContent.Replace($modalBlock, "")
        Write-Host "3. helpSimpleModal removed OK" -ForegroundColor Green
    }
}

# 4. drawTieCurve
$tieSearch = "function drawTieCurve("
$tieIdx = $htmlContent.IndexOf($tieSearch)
if ($tieIdx -ge 0) {
    $tieEndIdx = $htmlContent.IndexOf("function drawAllTies(", $tieIdx)
    $oldTie = $htmlContent.Substring($tieIdx, $tieEndIdx - $tieIdx)
    $htmlContent = $htmlContent.Replace($oldTie, $block3 + "`n`n")
    Write-Host "4. drawTieCurve replaced OK" -ForegroundColor Green
}

# 5. setTempo
$tempoSearch = "function setTempo(value) {"
$tempoIdx = $htmlContent.IndexOf($tempoSearch)
if ($tempoIdx -ge 0) {
    $tempoEndIdx = $htmlContent.IndexOf("function setMetronomeEnabled(", $tempoIdx)
    $oldTempo = $htmlContent.Substring($tempoIdx, $tempoEndIdx - $tempoIdx)
    $htmlContent = $htmlContent.Replace($oldTempo, $block4 + "`n`n")
    Write-Host "5. setTempo replaced OK" -ForegroundColor Green
}

# 6. showPracticeExample
$practiceSearch = "async function showPracticeExample() {"
$practiceIdx = $htmlContent.IndexOf($practiceSearch)
if ($practiceIdx -ge 0) {
    $practiceEndIdx = $htmlContent.IndexOf("function startGuidedPractice()", $practiceIdx)
    $oldPractice = $htmlContent.Substring($practiceIdx, $practiceEndIdx - $practiceIdx)
    $htmlContent = $htmlContent.Replace($oldPractice, $block5 + "`n`n")
    Write-Host "6. showPracticeExample replaced OK" -ForegroundColor Green
}

$finalContent = $htmlContent -replace "`n", "`r`n"
[System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
Write-Host "Applied UTF-8 blocks patch to index.html successfully!" -ForegroundColor Green
