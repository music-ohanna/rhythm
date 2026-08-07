$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$content = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

$targetSnippet = "showValidationAlert('악기 실음을 포함하지 못했습니다"

if ($content.Contains($targetSnippet)) {
    # Replace the return block so it proceeds to save even if audio fetch fails
    $content = $content.Replace("showValidationAlert('악기 실음을 포함하지 못했습니다. 잠시 후 다시 저장해 주세요.');`r`n                return;", "console.warn('실음 내장 실패, 기본 시스템 소리로 연주합니다.');")
    $content = $content.Replace("showValidationAlert('악기 실음을 포함하지 못했습니다. 잠시 후 다시 저장해 주세요.');`n                return;", "console.warn('실음 내장 실패, 기본 시스템 소리로 연주합니다.');")
    [System.IO.File]::WriteAllText($indexPath, $content, [System.Text.Encoding]::UTF8)
    Write-Host "PATCH_SUCCESS: Audio download fallback robustly patched"
} else {
    Write-Host "PATCH_SKIP: targetSnippet not found"
}
