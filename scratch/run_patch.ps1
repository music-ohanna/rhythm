$FilePath = "index.html"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$content = [System.IO.File]::ReadAllText($FilePath, $utf8NoBom)
$contentLF = $content -replace "`r`n", "`n"

# 1. tutorialSteps
$stepSearch = "const tutorialSteps = ["
$stepIdx = $contentLF.IndexOf($stepSearch)
if ($stepIdx -ge 0) {
    $stepEndIdx = $contentLF.IndexOf("];", $stepIdx) + 2
    $oldStepsBlock = $contentLF.Substring($stepIdx, $stepEndIdx - $stepIdx)

    $newStepsBlock = @"
const tutorialSteps = [
            {
                title: '1?④퀎: ?뚰몴 ?ｊ린',
                body: '?꾨옒 ?쒖뿉??<strong>4遺꾩쓬??/strong>, <strong>8遺꾩쓬??/strong> ???뚰몴瑜??뚮윭 ?낅낫???ｌ뼱??<br><small>?뚰몴 = ?뚮━媛 ?섎뒗 湲고샇?덉슂.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '2?④퀎: ?쇳몴 ?ｊ린',
                body: '?쇳몴 以꾩쓽 <strong>4遺꾩돹??/strong>, <strong>8遺꾩돹??/strong>瑜??뚮윭 議곗슜??諛뺤쓣 留뚮뱾?댁슂.<br><small>?쇳몴 = ?뚮━ ?놁씠 ?щ뒗 湲고샇?덉슂.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '3?④퀎: ?? . ) 遺숈씠湲?,
                body: '?뚰몴???쇳몴瑜??ｌ? ?ㅼ쓬 <strong>[ . ] (??</strong> 踰꾪듉???뚮윭蹂댁꽭??<br>?먯쓣 遺숈씠硫?洹?湲고샇??湲몄씠媛 1.5諛??섏뼱?섏슂!',
                anchor: 'dotButton',
                placement: 'top'
            },
            {
                title: '4?④퀎: 遺숈엫以??곌껐?섍린',
                body: '?뚰몴瑜??섎젮 ?곌껐?섍퀬 ?띕떎硫?<strong>[??遺숈엫以?</strong> 踰꾪듉???뚮윭??<br>?뚮윭 ?쒖꽦?뷀븳 ??<strong>???뚰몴 ?????뚰몴 ?쒖꽌</strong>濡?李⑤?濡??대┃?섏꽭??',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '5?④퀎: ??由щ벉 ?ㅼ뼱蹂닿린',
                body: '?쒕? 梨꾩썱?쇰㈃ <strong>[????留덈뵒 ?ｊ린]</strong> 踰꾪듉???뚮윭 ??由щ벉???ㅼ뼱遊먯슂!<br><small>諛섎났 ?ъ깮?섎땲 留덉쓬???ㅻ㈃ ?ㅼ젙?먯꽌 硫덉텧 ???덉뼱??</small>',
                anchor: 'play',
                placement: 'top'
            },
            {
                title: '6?④퀎: ?섎룎由ш린쨌吏?곌린',
                body: '?섎せ ?낅젰?덉쓣 ?뚮뒗 <strong>?⑼툘 ?섎룎由ш린</strong> ?먮뒗 <strong>?뿊截?吏?곌린</strong>瑜??뚮윭??',
                anchor: 'undoClear',
                placement: 'bottom'
            },
            {
                title: '?덉떆 ?곕씪 留뚮뱾湲??꾩쟾!',
                body: '?ъ뼱瑜?留덉낀?댁슂 ?럦<br>?댁젣 <strong>[?렞 ?덉떆 ?곕씪?섍린]</strong> 踰꾪듉?쇰줈 ?좎깮?섏씠 以鍮꾪븳 4/4諛뺤옄 由щ벉???곕씪 留뚮뱾??蹂댁꽭??',
                anchor: 'practice',
                placement: 'bottom'
            }
        ];
"@
    $contentLF = $contentLF.Replace($oldStepsBlock, $newStepsBlock)
    Write-Host "1. tutorialSteps replaced OK" -ForegroundColor Green
}

# 2. help button
$helpBtnSearch = '<button id="btn-help-tutorial"'
$helpBtnIdx = $contentLF.IndexOf($helpBtnSearch)
if ($helpBtnIdx -ge 0) {
    $helpBtnEnd = $contentLF.IndexOf('</button>', $helpBtnIdx) + 9
    $oldBtn = $contentLF.Substring($helpBtnIdx, $helpBtnEnd - $helpBtnIdx)

    $newBtn = @"
<button id="btn-help-tutorial" onclick="showTutorial(true)" class="text-tool-btn text-xs md:text-sm" title="?ъ뼱 媛?대뱶 ?ㅼ떆 蹂닿린">
                    <span class="text-base">?뱰</span> 媛?대뱶
                </button>
"@
    $contentLF = $contentLF.Replace($oldBtn, $newBtn)
    Write-Host "2. help button replaced OK" -ForegroundColor Green
}

# 3. helpSimpleModal remove
$modalSearch = '<div id="helpSimpleModal"'
$modalIdx = $contentLF.IndexOf($modalSearch)
if ($modalIdx -ge 0) {
    $scriptIdx = $contentLF.IndexOf('<script>', $modalIdx)
    if ($scriptIdx -gt $modalIdx) {
        $modalBlock = $contentLF.Substring($modalIdx, $scriptIdx - $modalIdx)
        $contentLF = $contentLF.Replace($modalBlock, "")
        Write-Host "3. helpSimpleModal removed OK" -ForegroundColor Green
    }
}

# 4. drawTieCurve
$tieSearch = "function drawTieCurve("
$tieIdx = $contentLF.IndexOf($tieSearch)
if ($tieIdx -ge 0) {
    $tieEndIdx = $contentLF.IndexOf("function drawAllTies(", $tieIdx)
    $oldTie = $contentLF.Substring($tieIdx, $tieEndIdx - $tieIdx)

    $newTie = @"
function drawTieCurve(fromNote, toNote, staffY, color = '#0f172a', alpha = 1) {
            if (!fromNote || !toNote) return;
            const fromX = fromNote.x + 10.5;
            const toX = toNote.x - 10.5;
            if (toX <= fromX + 4) return;

            const y = staffY + 12;
            const width = toX - fromX;
            // ??蹂쇰줉?섍퀬 源딄쾶 (理쒖냼 24px, ?덈퉬 鍮꾨? 0.32, 理쒕? 52px)
            const depth = Math.max(24, Math.min(52, width * 0.32));

            rhythmCtx.save();
            rhythmCtx.strokeStyle = color;
            rhythmCtx.globalAlpha = alpha;
            rhythmCtx.lineWidth = 3.2;
            rhythmCtx.lineCap = 'round';
            rhythmCtx.lineJoin = 'round';

            // 踰좎???怨≪꽑?쇰줈 ?띿꽦?섍쾶 怨〓쪧 ?뺤꽦
            rhythmCtx.beginPath();
            rhythmCtx.moveTo(fromX, y);
            rhythmCtx.bezierCurveTo(
                fromX + width * 0.22, y + depth,
                toX - width * 0.22, y + depth,
                toX, y
            );
            rhythmCtx.stroke();

            // ?댁쨷 ???④낵濡??뚯븙??遺숈엫以?誘멸컧 利앸?
            rhythmCtx.lineWidth = 1.8;
            rhythmCtx.globalAlpha = alpha * 0.7;
            rhythmCtx.beginPath();
            rhythmCtx.moveTo(fromX + 2, y + 1.5);
            rhythmCtx.bezierCurveTo(
                fromX + width * 0.24, y + depth * 0.88,
                toX - width * 0.24, y + depth * 0.88,
                toX - 2, y + 1.5
            );
            rhythmCtx.stroke();

            rhythmCtx.restore();
        }

"@
    $contentLF = $contentLF.Replace($oldTie, $newTie)
    Write-Host "4. drawTieCurve replaced OK" -ForegroundColor Green
}

# 5. setTempo
$tempoSearch = "function setTempo(value) {"
$tempoIdx = $contentLF.IndexOf($tempoSearch)
if ($tempoIdx -ge 0) {
    $tempoEndIdx = $contentLF.IndexOf("function setMetronomeEnabled(", $tempoIdx)
    $oldTempo = $contentLF.Substring($tempoIdx, $tempoEndIdx - $tempoIdx)

    $newTempo = @"
let _tempoRestartTimer = null;
        function setTempo(value) {
            tempo = Math.max(40, Math.min(160, Number(value) || 60));
            const tempoValue = document.getElementById('tempoValue');
            if (tempoValue) tempoValue.textContent = `??= \${tempo}`;
            updatePlayButtonLabel();
            if (isPlaying && !isProjectPlaying) {
                clearTimeout(_tempoRestartTimer);
                _tempoRestartTimer = setTimeout(async () => {
                    if (isPlaying && !isProjectPlaying) {
                        stopPerformance();
                        await startPerformance();
                    }
                }, 200);
            }
        }

"@
    $contentLF = $contentLF.Replace($oldTempo, $newTempo)
    Write-Host "5. setTempo replaced OK" -ForegroundColor Green
}

# 6. showPracticeExample
$practiceSearch = "async function showPracticeExample() {"
$practiceIdx = $contentLF.IndexOf($practiceSearch)
if ($practiceIdx -ge 0) {
    $practiceEndIdx = $contentLF.IndexOf("function startGuidedPractice()", $practiceIdx)
    $oldPractice = $contentLF.Substring($practiceIdx, $practiceEndIdx - $practiceIdx)

    $newPractice = @"
// ?ъ쭊 ??4/4諛뺤옄 ?덉떆 由щ벉: 4遺꾩쓬??쨌 ??遺꾩쓬??16遺꾩쓬??쨌 ?뗭엲??3媛?쨌 8遺꾩쓬??8遺꾩돹??        function getFourFourPracticeExample() {
            return [
                { type: 'quarter',   isRest: false, beatOffset: 0,           dotted: false },
                { type: 'eighth',    isRest: false, beatOffset: 1,           dotted: true  },
                { type: 'sixteenth', isRest: false, beatOffset: 1.75,        dotted: false },
                { type: 'triplet',   isRest: false, beatOffset: 2,           dotted: false },
                { type: 'triplet',   isRest: false, beatOffset: 2 + 1/3,     dotted: false },
                { type: 'triplet',   isRest: false, beatOffset: 2 + 2/3,     dotted: false },
                { type: 'eighth',    isRest: false, beatOffset: 3,           dotted: false },
                { type: 'eighth',    isRest: true,  beatOffset: 3.5,         dotted: false }
            ];
        }

        async function showPracticeExample() {
            stopPerformance();
            if (timeSignature.top !== 4 || timeSignature.bottom !== 4) {
                showToast('?좑툘 ?덉떆 李쎌옉? 4/4諛뺤옄瑜?湲곗??쇰줈 ?⑸땲?? 4/4諛뺤옄濡??먮룞 ?꾪솚?⑸땲??', true);
                await new Promise(r => setTimeout(r, 800));
                setTimeSig(4, 4);
                await new Promise(r => setTimeout(r, 100));
            } else {
                showToast('?뱦 ?덉떆 李쎌옉? 4/4諛뺤옄瑜?湲곗??쇰줈 ?덈궡?⑸땲??', true);
                await new Promise(r => setTimeout(r, 500));
            }
            pushUndoState();
            const example = getFourFourPracticeExample();
            notes.splice(0, notes.length, ...example.map(note => ({...note})));
            guidedPracticeTarget = example.map(note => ({...note}));
            dotCandidateNote = null;
            syncActiveMeasureState();
            closePracticePanel();
            showPracticeStatus('example');
            drawAll();
            showToast('?덉떆: 4遺꾩쓬??쨌 ??遺꾩쓬??16遺꾩쓬??쨌 ?뗭엲??3媛?쨌 8遺꾩쓬??8遺꾩돹??, true);
            await startPerformance();
        }

"@
    $contentLF = $contentLF.Replace($oldPractice, $newPractice)
    Write-Host "6. showPracticeExample replaced OK" -ForegroundColor Green
}

$finalContent = $contentLF -replace "`n", "`r`n"
[System.IO.File]::WriteAllText($FilePath, $finalContent, $utf8NoBom)
Write-Host "Saved index.html cleanly with UTF-8!" -ForegroundColor Green