import os
import re

final_index_path = r"c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm\index.html"
root_index_path = r"c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\index.html"

with open(final_index_path, "r", encoding="utf-8") as f:
    html = f.read()

# 1. CSS 오버라이드
custom_style = """
        /* 마디 탭 알약 칩 스타일 오버라이드 */
        .measure-tabs .measure-tab {
            padding: 4px 16px !important;
            border-radius: 9999px !important;
            font-weight: 800 !important;
            font-size: 13px !important;
            border: 2px solid #cbd5e1 !important;
            background-color: #f1f5f9 !important;
            color: #334155 !important;
            cursor: pointer !important;
            transition: all 0.15s ease !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
        }
        .measure-tabs .measure-tab:hover {
            background-color: #e2e8f0 !important;
            color: #0f172a !important;
        }
        .measure-tabs .measure-tab.active {
            background-color: #2563eb !important;
            color: #ffffff !important;
            border-color: #1d4ed8 !important;
            box-shadow: 0 2px 6px rgba(37, 99, 235, 0.35) !important;
        }
        .measure-tabs .measure-tab i.measure-status {
            display: none !important;
        }
        
        /* 하단 정중앙 듣기 버튼 푸터 스타일 */
        .play-buttons {
            display: flex !important;
            justify-content: center !important;
            align-items: center !important;
            width: 100% !important;
            margin-top: 6px !important;
            margin-bottom: 4px !important;
        }
        #playbackControlsBtnsContainer {
            display: flex !important;
            justify-content: center !important;
            align-items: center !important;
            gap: 16px !important;
            width: 100% !important;
            max-width: 650px !important;
            margin: 0 auto !important;
        }
"""

if "/* 마디 탭 알약 칩 스타일 오버라이드 */" not in html:
    html = html.replace("</style>", custom_style + "\n    </style>")

# 2. 마디 탭 HTML 바꾸기
new_tabs_html = """<div class="measure-tabs flex gap-2 justify-center items-center" role="tablist" aria-label="편집할 마디 선택">
            <button class="measure-tab active" type="button" role="tab" aria-selected="true" data-measure-index="0" onclick="switchMeasure(0)" title="1마디">마디 1</button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="1" onclick="switchMeasure(1)" title="2마디">마디 2</button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="2" onclick="switchMeasure(2)" title="3마디">마디 3</button>
            <button class="measure-tab" type="button" role="tab" aria-selected="false" data-measure-index="3" onclick="switchMeasure(3)" title="4마디">마디 4</button>
        </div>"""

html = re.sub(r'<div class="measure-tabs"[\s\S]*?</div>', new_tabs_html, html)

# 3. 하단 플레이 버튼 정중앙 래퍼 및 버튼 스타일 정돈
new_play_buttons_html = """<div class="play-buttons h-10 md:h-12 shrink-0 my-1 flex justify-center items-center w-full">
            <div id="playbackControlsBtnsContainer" class="flex items-center justify-center gap-3 w-full max-w-xl mx-auto px-2">
                <button id="playBtn" onclick="togglePlay()" class="flex-1 bg-blue-600 hover:bg-blue-700 text-white rounded-xl py-2 px-4 shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                    <span class="current-play-icon text-lg">▶</span> 이 마디 듣기 (♩ = 60)
                </button>
                <button id="playAllBtn" onclick="toggleProjectPlay()" class="flex-1 bg-teal-700 hover:bg-teal-800 text-white rounded-xl py-2 px-4 shadow-md flex items-center justify-center gap-2 text-sm md:text-base font-extrabold active:scale-95 transition">
                    <span class="project-play-icon text-lg">▶▶</span> 전체 듣기
                </button>
            </div>
        </div>"""

html = re.sub(r'<div class="play-buttons[\s\S]*?</div>\s*</div>', new_play_buttons_html, html)

# 4. JS 코드 내에서 text를 dot으로 재설정하는 코드가 있다면 비활성화
html = re.sub(r'tab\.innerHTML\s*=\s*[\'"`][^\'"`]*[\'"`]', '// tab text preserved', html)

with open(final_index_path, "w", encoding="utf-8") as f:
    f.write(html)

with open(root_index_path, "w", encoding="utf-8") as f:
    f.write(html)

print("Python Script: Successfully updated both index.html files!")
