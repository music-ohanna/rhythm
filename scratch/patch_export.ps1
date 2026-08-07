$pwdPath = (Get-Location).ProviderPath
$indexPath = Join-Path $pwdPath "index.html"
$content = [System.IO.File]::ReadAllText($indexPath, [System.Text.Encoding]::UTF8)

$functionCode = @"
        // 단독 실행 가능한 실음 포함 악보 HTML 저장 및 다운로드 기능
        function downloadPlayableScoreHtml() {
            try {
                syncActiveMeasureState();
                const scoreData = {
                    version: "2.0",
                    title: "나의 리듬 창작 작품",
                    timeSignature: timeSignature,
                    tempo: bpm,
                    instrument: rhythmInstrument,
                    measures: scoreMeasures
                };

                const currentDocHtml = document.documentElement.outerHTML;
                const scriptInject = "<script>window.__EMBEDDED_SCORE_DATA__ = " + JSON.stringify(scoreData) + ";</script>";
                let exportHtml = currentDocHtml.replace("</head>", scriptInject + "\n</head>");

                const blob = new Blob([exportHtml], { type: "text/html;charset=utf-8" });
                const url = URL.createObjectURL(blob);
                const a = document.createElement("a");
                const dateStr = new Date().toISOString().slice(0, 10);
                a.href = url;
                a.download = `리듬창작_작품_${dateStr}.html`;
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                setTimeout(() => URL.revokeObjectURL(url), 1000);
                showToast("실음 저장 및 실행 가능한 작품 HTML 파일로 내려받았습니다!", true);
            } catch (err) {
                console.error(err);
                showValidationAlert("작품 파일 저장 중 오류가 발생했습니다: " + err.message);
            }
        }

"@

$targetMarker = "function initTutorial()"

if (-not $content.Contains("function downloadPlayableScoreHtml()")) {
    $content = $content.Replace($targetMarker, $functionCode + "        " + $targetMarker)
    [System.IO.File]::WriteAllText($indexPath, $content, [System.Text.Encoding]::UTF8)
    Write-Host "PATCH_SUCCESS: downloadPlayableScoreHtml added successfully"
} else {
    Write-Host "PATCH_SKIP: downloadPlayableScoreHtml already exists"
}
