# split_sound.ps1
$utf8 = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText('index.html', $utf8) -replace "`r`n", "`n"

$startMarker = "const EMBEDDED_RHYTHM_AUDIO_DATA_URIS = {"
$endMarker = "};"

$startIdx = $content.IndexOf($startMarker)
if ($startIdx -ge 0) {
    $endIdx = $content.IndexOf($endMarker, $startIdx) + $endMarker.Length
    $soundCode = $content.Substring($startIdx, $endIdx - $startIdx)

    # Save sound_data.js
    [System.IO.File]::WriteAllText('sound_data.js', $soundCode, $utf8)
    Write-Host "1. Created sound_data.js successfully! (Size: $($soundCode.Length) bytes)" -ForegroundColor Green

    # Replace in index.html
    $replacement = "// EMBEDDED_RHYTHM_AUDIO_DATA_URIS is loaded from sound_data.js"
    $content = $content.Replace($soundCode, $replacement)

    # Add <script src="sound_data.js"></script> before </head>
    $headEnd = $content.IndexOf("</head>")
    if ($headEnd -ge 0) {
        $tag = "    <script src=`"sound_data.js`"></script>`n"
        $content = $content.Insert($headEnd, $tag)
        Write-Host "2. Added sound_data.js script tag to head!" -ForegroundColor Green
    }

    # Default score initialization when measure 0 is empty
    $initSearch = "notes = scoreMeasures[activeMeasureIndex];"
    $initIdx = $content.IndexOf($initSearch)
    if ($initIdx -ge 0) {
        $patchInit = "notes = scoreMeasures[activeMeasureIndex];`n                if (getAuthoredMeasureNotes(notes).length === 0) {`n                    notes.splice(0, notes.length,`n                        { type: 'quarter', isRest: false, beatOffset: 0, dotted: false },`n                        { type: 'quarter', isRest: false, beatOffset: 1, dotted: false },`n                        { type: 'quarter', isRest: false, beatOffset: 2, dotted: false },`n                        { type: 'quarter', isRest: false, beatOffset: 3, dotted: false }`n                    );`n                }"
        $content = $content.Replace($initSearch, $patchInit)
        Write-Host "3. Added default 4/4 score initialization!" -ForegroundColor Green
    }

    # Default score in resetToHome
    $resetSearch = "function resetToHome() {"
    $resetIdx = $content.IndexOf($resetSearch)
    if ($resetIdx -ge 0) {
        $resetEnd = $content.IndexOf("switchMeasure(0);", $resetIdx) + "switchMeasure(0);".Length
        $oldReset = $content.Substring($resetIdx, $resetEnd - $resetIdx)
        $newReset = "function resetToHome() {`n            stopPerformance();`n            guidedPracticeTarget = null;`n            hidePracticeStatus();`n            closePracticePanel();`n            if (timeSignature.top !== 4 || timeSignature.bottom !== 4) {`n                setTimeSig(4, 4);`n            }`n            switchMeasure(0);`n            notes.splice(0, notes.length,`n                { type: 'quarter', isRest: false, beatOffset: 0, dotted: false },`n                { type: 'quarter', isRest: false, beatOffset: 1, dotted: false },`n                { type: 'quarter', isRest: false, beatOffset: 2, dotted: false },`n                { type: 'quarter', isRest: false, beatOffset: 3, dotted: false }`n            );`n            drawAll();"
        $content = $content.Replace($oldReset, $newReset)
        Write-Host "4. Updated resetToHome with default 4/4 score!" -ForegroundColor Green
    }

    $finalContent = $content -replace "`n", "`r`n"
    [System.IO.File]::WriteAllText('index.html', $finalContent, $utf8)
    Write-Host "Finished index.html optimization! New index.html size: $($finalContent.Length) bytes." -ForegroundColor Green
} else {
    Write-Host "EMBEDDED_RHYTHM_AUDIO_DATA_URIS not found!" -ForegroundColor Red
}
