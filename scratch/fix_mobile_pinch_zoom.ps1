$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$content = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

# 1. Replace touch-none on drawingCanvas with touch-pinch-zoom style
$oldCanvas = '<canvas id="drawingCanvas" class="absolute top-0 left-0 w-full h-full block z-20 touch-none"></canvas>'
$newCanvas = '<canvas id="drawingCanvas" class="absolute top-0 left-0 w-full h-full block z-20" style="touch-action: pan-x pan-y pinch-zoom;"></canvas>'
if ($content.Contains($oldCanvas)) {
    $content = $content.Replace($oldCanvas, $newCanvas)
}

# Save updated file
[System.IO.File]::WriteAllText($indexPath, $content, [System.Text.Encoding]::UTF8)
Write-Host "PINCH_ZOOM_FIX_SUCCESS"
