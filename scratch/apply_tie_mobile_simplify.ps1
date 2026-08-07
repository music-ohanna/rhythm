$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

# -----------------------------------------------------------------------
# 1. Make tie curve more rounded using bezier control points
# Find drawTieCurve and update the curve drawing logic
# -----------------------------------------------------------------------
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "function drawTieCurve") {
        # Look for the depth and quadraticCurveTo lines within this function
        for ($j = $i; $j -lt ($i + 25); $j++) {
            if ($lines[$j] -match "const depth = Math.max") {
                $lines[$j] = "            const depth = Math.max(16, Math.min(32, width * 0.25));"
                Write-Host "Updated tie curve depth for rounder look"
            }
            if ($lines[$j] -match "quadraticCurveTo") {
                # Replace with a bezier for rounder arc: control points pulled further out
                $lines[$j] = "            const cx1 = fromX + width * 0.25; const cx2 = fromX + width * 0.75; const cy = y + depth * 1.3; rhythmCtx.bezierCurveTo(cx1, cy, cx2, cy, toX, y);"
                Write-Host "Replaced quadraticCurveTo with bezierCurveTo for rounder tie"
            }
        }
        break
    }
}

# -----------------------------------------------------------------------
# 2. Remove practice button from header (simplify UI)
# -----------------------------------------------------------------------
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'id="btn-header-practice"') {
        $lines[$i] = "                <!-- 단계 연습 버튼은 보기설정 안에서만 노출 (헤더 단순화) -->"
        Write-Host "Removed practice button from header"
    }
}

# -----------------------------------------------------------------------
# 3. Fix mobile display: remove overflow hidden, set proper height scaling
# -----------------------------------------------------------------------
# body - was "h-screen flex flex-col p-2 md:p-3 overflow-hidden"
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match 'class="h-screen flex flex-col p-2 md:p-3 overflow-hidden"') {
        $lines[$i] = $lines[$i] -replace 'class="h-screen flex flex-col p-2 md:p-3 overflow-hidden"', 'class="flex flex-col p-2 md:p-3" style="height:100dvh; min-height:520px; overflow:hidden;"'
        Write-Host "Updated body class for mobile height fix"
    }
}

# -----------------------------------------------------------------------
# 4. Ensure viewport forces full-width fit on Galaxy phones
#    (S22/S23: 360px CSS width at default zoom)
# -----------------------------------------------------------------------
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match '<meta name="viewport"') {
        $lines[$i] = '    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">'
        Write-Host "Reset viewport to standard (no user-scale override)"
    }
}

# -----------------------------------------------------------------------
# 5. Fix tie line width for better visibility
# -----------------------------------------------------------------------
for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "rhythmCtx.lineWidth = 2.35;" -and $i -gt 4000 -and $i -lt 4020) {
        $lines[$i] = "            rhythmCtx.lineWidth = 2.8;"
        Write-Host "Updated tie line width to 2.8 for visibility"
    }
}

[System.IO.File]::WriteAllLines($indexPath, $lines, [System.Text.Encoding]::UTF8)
Write-Host "TIE_AND_MOBILE_PATCH_DONE"
