$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "playTone\(880") {
        $lines[$i] = "            playTone(880, 0.15, 0.15, 'sine'); playTone(1046, 0.25, 0.2, 'sine');"
        $lines[$i+1] = "            guidedPracticeTarget = null;"
        $lines[$i+2] = "            practiceStatusMode = null;"
        $lines[$i+3] = "            hidePracticeStatus();"
        $lines[$i+4] = "            drawAll();"
        $lines[$i+5] = "            startIndependentCreation();"
        # HTML entity safe toast string
        $lines[$i+6] = "            showToast('&#x1F389; &#xC815;&#xB2F5;&#xC785;&#xB2C8;&#xB2E4;! &#xC608;&#xC1DC;&#xB97C; &#xC644;&#xBDBD;&#xD788; &#xB9DE;&#xCDA4;&#xC15B;&#xC74D;&#xB2C8;&#xB2E4;. &#xC774;&#xC81C; &#xB098;&#xB9CC;&#xC758; &#xB9AC;&#xB4EC;&#xC744; &#xC790;&#xC720;&#xB86D;&#xAC8C; &#xB9DE;&#xB4E4;&#xC5B4; &#xBCF4;&#xC138;&#xC694;!', true);"
        $lines[$i+7] = "            // end of success logic"
        Write-Host "Cleaned success toast"
        break
    }
}

[System.IO.File]::WriteAllLines($indexPath, $lines, [System.Text.Encoding]::UTF8)
Write-Host "SUCCESS_TOAST_CLEANED"
