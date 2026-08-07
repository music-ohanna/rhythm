$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'id="btn-header-practice"') {
        # HTML Entity/ASCII safe string
        $lines[$i] = '                <button id="btn-header-practice" onclick="openPracticePanel()" class="text-tool-btn text-xs md:text-sm" style="background:#eff6ff !important; color:#1d4ed8 !important; border-color:#93c5fd !important; font-weight:900;" title="단계별 연습"><span class="text-base">&#x1F3AF;</span> &#xC5F0;&#xC1B5;</button>'
        Write-Host "Replaced btn-header-practice with HTML entities"
    }
}

[System.IO.File]::WriteAllLines($indexPath, $lines, [System.Text.Encoding]::UTF8)
Write-Host "HEADER_FIX_SUCCESS"
