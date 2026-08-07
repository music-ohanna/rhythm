$filePath = Join-Path (Get-Location) "index.html"
$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)

Write-Host "Initial content length:" $content.Length

# --- FIX 1: Measure Tabs CSS & HTML ---
$oldTabCss = @'
        .measure-tabs { display:flex; align-items:center; justify-content:center; gap:16px; }
        .measure-tab {
            width: 24px;
            height: 24px;
            border-radius: 9999px;
            border: 2px solid #cbd5e1;
            background: #f8fafc;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .measure-tab:hover { border-color:#2563eb; transform:scale(1.15); }
        .measure-tab.active { background:#2563eb; border-color:#1d4ed8; box-shadow:0 0 0 4px rgba(37,99,235,.25); transform:scale(1.25); }
        .measure-tab.complete:not(.active) { background:#22c55e; border-color:#16a34a; }
        .measure-tab.partial:not(.active) { background:#f59e0b; border-color:#d97706; }
        .measure-status { width: 8px; height: 8px; border-radius: 9999px; background: transparent; transition: background 0.2s ease; }
        .measure-tab.active .measure-status { background:#ffffff; }
'@

$newTabCss = @'
        .measure-tabs { display:flex; align-items:center; justify-content:center; gap:8px; }
        .measure-tab {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 4px 14px;
            border-radius: 9999px;
            font-size: 13px;
            font-weight: 700;
            border: 1.5px solid #cbd5e1;
            background: #f8fafc;
            color: #475569;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        .measure-tab:hover { border-color:#2563eb; color:#1d4ed8; background:#eff6ff; }
        .measure-tab.active { background:#2563eb; color:#ffffff; border-color:#1d4ed8; font-weight:900; box-shadow:0 2px 8px rgba(37,99,235,.35); }
        .measure-tab.complete:not(.active) { background:#f0fdf4; color:#166534; border-color:#86efac; }
        .measure-tab.partial:not(.active) { background:#fffbeb; color:#92400e; border-color:#fde68a; }
        .measure-status { display: none; }
'@

if ($content.Contains($oldTabCss)) {
    $content = $content.Replace($oldTabCss, $newTabCss)
    Write-Host "FIX 1a: Updated tab CSS"
} else {
    Write-Host "FIX 1a: oldTabCss exact string not matched."
}

$oldTabsHtml = @'
        <div class="measure-tabs" role="tablist" aria-label="편집할 마디 선택">
            <button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디"><i class="measure-status" aria-hidden="true"></i></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디"><i class="measure-status" aria-hidden="true"></i></button>
        </div>
'@

$newTabsHtml = @'
        <div class="measure-tabs" role="tablist" aria-label="편집할 마디 선택">
            <button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디"><span>마디 1</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디"><span>마디 2</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디"><span>마디 3</span></button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디"><span>마디 4</span></button>
        </div>
'@

if ($content.Contains($oldTabsHtml)) {
    $content = $content.Replace($oldTabsHtml, $newTabsHtml)
    Write-Host "FIX 1b: Updated tabs HTML"
} else {
    Write-Host "FIX 1b: oldTabsHtml exact string not matched."
}


# --- FIX 2: Canvas Next Measure Button Position ---
$oldPlusBtn = '<button id="canvasNextMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex + 1)" class="absolute right-3 top-1/2 -translate-y-1/2 z-40 text-blue-600 hover:text-blue-800 font-black text-4xl md:text-5xl cursor-pointer p-1 bg-transparent border-0 outline-none hover:scale-110 active:scale-95 transition-transform" title="마디 추가">➕</button>'
$newPlusBtn = '<button id="canvasNextMeasureBtn" type="button" onclick="switchMeasure(activeMeasureIndex + 1)" style="position: absolute; right: 16px; top: 50%; transform: translateY(-50%); z-index: 40;" class="text-blue-600 hover:text-blue-800 font-black text-4xl md:text-5xl cursor-pointer p-1 bg-transparent border-0 outline-none hover:scale-110 active:scale-95 transition-transform" title="마디 추가">➕</button>'

if ($content.Contains($oldPlusBtn)) {
    $content = $content.Replace($oldPlusBtn, $newPlusBtn)
    Write-Host "FIX 2: Fixed canvasNextMeasureBtn position style"
} else {
    Write-Host "FIX 2: oldPlusBtn exact string not matched."
}


# --- FIX 3: Sound Bar ID & Tutorial Step 9 Anchor ---
$oldCtrlDiv = '<div class="playback-controls flex justify-between items-center gap-2 shrink-0">'
$newCtrlDiv = '<div id="bottomDisplayAndInstrumentOptions" class="playback-controls flex justify-between items-center gap-2 shrink-0">'
if ($content.Contains($oldCtrlDiv)) {
    $content = $content.Replace($oldCtrlDiv, $newCtrlDiv)
    Write-Host "FIX 3a: Added bottomDisplayAndInstrumentOptions ID"
}

$oldStep9Anchor = "anchor: '#bottomFullControlsContainer',"
$newStep9Anchor = "anchor: '#bottomDisplayAndInstrumentOptions',"
if ($content.Contains($oldStep9Anchor)) {
    $content = $content.Replace($oldStep9Anchor, $newStep9Anchor)
    Write-Host "FIX 3b: Updated step 9 anchor"
}


# --- FIX 4: Footer Play Buttons & Credits ---
$oldFooter = @'
        <div class="play-buttons h-9 md:h-10 shrink-0">
            <div id="playbackControlsBtnsContainer" class="flex items-center gap-2 flex-1">
            <button id="playBtn" onclick="togglePlay()" class="flex-1 bg-amber-600 hover:bg-amber-700 text-white rounded-xl shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                <span class="current-play-icon">▶</span> 이 마디 듣기 (♩ = 60)
            </button>
            <button id="playAllBtn" onclick="toggleProjectPlay()" class="flex-1 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                <span class="project-play-icon">▶▶</span> 전체 듣기
            </button>
        </div>

        <div class="mt-1 pt-1 border-t border-slate-200 text-center shrink-0">
            <p class="text-[10px] md:text-xs text-slate-500 font-medium">
                제작: <a href="http://joo.is/미래형교사" target="_blank" rel="noopener noreferrer" class="underline hover:text-blue-600 font-bold">오한나</a> · 
                / 악기 음원 출처: <a href="https://www.gugak.go.kr" target="_blank" rel="noopener" class="underline hover:text-blue-600">국립국악원</a> · 
                우드블록: <a href="https://freesound.org/people/hollandm/" target="_blank" rel="noopener" class="underline hover:text-blue-600">hollandm/Freesound (CC0)</a> · 
                드럼: <a href="https://freesound.org/people/menegass/" target="_blank" rel="noopener" class="underline hover:text-blue-600">menegass/Freesound (CC0)</a>
            </p>
        </div>
'@

$newFooter = @'
        <div id="footerBar" class="relative flex flex-col md:flex-row items-center justify-center min-h-[42px] w-full mt-1 px-2 gap-2 shrink-0">
            <div id="playbackControlsBtnsContainer" class="flex items-center justify-center gap-3 w-full md:w-auto mx-auto">
                <button id="playBtn" onclick="togglePlay()" class="px-6 py-2 bg-amber-600 hover:bg-amber-700 active:scale-95 text-white font-extrabold text-sm md:text-base rounded-xl shadow-md flex items-center justify-center gap-2 transition min-w-[200px]">
                    <span class="current-play-icon">▶</span> 이 마디 듣기 (♩ = 60)
                </button>
                <button id="playAllBtn" onclick="toggleProjectPlay()" class="px-6 py-2 bg-emerald-600 hover:bg-emerald-700 active:scale-95 text-white font-extrabold text-sm md:text-base rounded-xl shadow-md flex items-center justify-center gap-2 transition min-w-[150px]">
                    <span class="project-play-icon">▶▶</span> 전체 듣기
                </button>
            </div>
            <div class="credits-text md:absolute md:right-2 text-[10px] md:text-xs text-slate-500 font-medium text-right whitespace-nowrap">
                제작: <a href="http://joo.is/미래형교사" target="_blank" rel="noopener noreferrer" class="underline hover:text-blue-600 font-bold">오한나</a> · 
                악기 음원 출처: <a href="https://www.gugak.go.kr" target="_blank" rel="noopener" class="underline hover:text-blue-600">국립국악원</a> · 
                우드블록: <a href="https://freesound.org/people/hollandm/" target="_blank" rel="noopener" class="underline hover:text-blue-600">hollandm/Freesound (CC0)</a> · 
                드럼: <a href="https://freesound.org/people/menegass/" target="_blank" rel="noopener" class="underline hover:text-blue-600">menegass/Freesound (CC0)</a>
            </div>
        </div>
'@

if ($content.Contains($oldFooter)) {
    $content = $content.Replace($oldFooter, $newFooter)
    Write-Host "FIX 4: Updated footer"
} else {
    Write-Host "FIX 4: oldFooter exact string not matched."
}

$outPath = Join-Path (Get-Location) "index.html"
[System.IO.File]::WriteAllText($outPath, $content, [System.Text.Encoding]::UTF8)
Write-Host "Updated index.html successfully. Final length:" $content.Length
