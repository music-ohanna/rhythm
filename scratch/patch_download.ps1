$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$content = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

$oldCatch = @"
            try {
                for (const sampleKey of getInstrumentSampleKeys(rhythmInstrument)) {
                    const assetUrl = rhythmSampleUrls[sampleKey];
                    if (!assetUrl) continue;
                    const dataUri = await fetchAudioAsDataUri(assetUrl);
                    html = html.split(assetUrl).join(dataUri);
                }
            } catch (error) {
                console.warn('제출 파일 실음 포함 실패:', error);
                showValidationAlert('악기 실음을 포함하지 못했습니다. 잠시 후 다시 저장해 주세요.');
                return;
            }
"@

$newCatch = @"
            try {
                for (const sampleKey of getInstrumentSampleKeys(rhythmInstrument)) {
                    const assetUrl = rhythmSampleUrls[sampleKey];
                    if (!assetUrl) continue;
                    try {
                        const dataUri = await fetchAudioAsDataUri(assetUrl);
                        if (dataUri) html = html.split(assetUrl).join(dataUri);
                    } catch (e) {
                        console.warn('개별 샘플 데이터 변환 스킵:', sampleKey, e);
                    }
                }
            } catch (error) {
                console.warn('온라인 실음 데이터 변환 중 일부 실패, 내장 실음으로 내보냅니다:', error);
            }
"@

if ($content.Contains("showValidationAlert('악기 실음을 포함하지 못했습니다. 잠시 후 다시 저장해 주세요.');")) {
    $content = $content.Replace($oldCatch, $newCatch)
    [System.IO.File]::WriteAllText($indexPath, $content, [System.Text.Encoding]::UTF8)
    Write-Host "PATCH_SUCCESS: Audio download fallback patched"
} else {
    Write-Host "PATCH_SKIP: Target download catch block not found"
}
