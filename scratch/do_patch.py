import os

index_path = r"c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm\index.html"

with open(index_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# 1. 4976번째 부근 tutorialSteps 정상 한국어 수정
new_tutorial_lines = [
    "        const tutorialSteps = [\n",
    "            {\n",
    "                title: '🎵 1단계: 음표 넣기',\n",
    "                body: '아래 버튼에서 <strong>4분음표</strong>, <strong>8분음표</strong> 등 음표를 눌러 악보에 넣어요!<br><small>음표 = 소리가 나는 기호예요.</small>',\n",
    "                anchor: 'noteRestButtons',\n",
    "                placement: 'top'\n",
    "            },\n",
    "            {\n",
    "                title: '🎵 2단계: 쉼표 넣기',\n",
    "                body: '쉼표 버튼의 <strong>4분쉼표</strong>, <strong>8분쉼표</strong>를 누르면 쉬는 자리를 넣을 수 있어요!<br><small>쉼표 = 잠깐 쉬는 기호예요.</small>',\n",
    "                anchor: 'noteRestButtons',\n",
    "                placement: 'top'\n",
    "            },\n",
    "            {\n",
    "                title: '✨ 3단계: 점(.) 붙이기',\n",
    "                body: '음표나 쉼표를 선택한 뒤 <strong>[ . ] (점)</strong> 버튼을 눌러 보세요!<br>점을 붙이면 그 기호의 길이가 1.5배가 돼요!',\n",
    "                anchor: 'dotButton',\n",
    "                placement: 'top'\n",
    "            },\n",
    "            {\n",
    "                title: '🔗 4단계: 붙임줄 만들기',\n",
    "                body: '음표를 이어 붙이고 싶다면 <strong>[🔗 붙임줄]</strong> 버튼을 누른 뒤,<br>이어 붙일 첫 번째 음표 → 두 번째 음표 순서로 눌러 보세요!',\n",
    "                anchor: 'tie',\n",
    "                placement: 'top'\n",
    "            },\n",
    "            {\n",
    "                title: '▶ 5단계: 내 리듬 들어보기',\n",
    "                body: '아래 <strong>[▶ 이 마디 듣기]</strong> 버튼을 눌러 내가 만든 리듬을 들어봐요!<br><small>반복 재생되니까 수정하면서 들을 수 있어요.</small>',\n",
    "                anchor: 'play',\n",
    "                placement: 'top'\n",
    "            }\n",
    "        ];\n"
]

start_ts = -1
end_ts = -1
for i, line in enumerate(lines):
    if "const tutorialSteps = [" in line:
        start_ts = i
    if start_ts != -1 and i > start_ts and "];" in line:
        end_ts = i
        break

if start_ts != -1 and end_ts != -1:
    lines[start_ts:end_ts+1] = new_tutorial_lines
    print("OK: replaced tutorialSteps")

# 2. checkGuidedPractice 성공 후 모달 팝업 연결 (라인 2486 부근)
for i in range(len(lines)-20, 2400, -1):
    if i < len(lines) and "startIndependentCreation();" in lines[i] and i > 2470:
        lines[i] = "            // startIndependentCreation(); -> 모달에서 선택 시 이동\n"
        lines[i+1] = "            showToast('🎉 정답이에요! 예시를 완벽히 따라했어요!', true);\n"
        lines[i+2] = "            setTimeout(() => { const modal = document.getElementById('practiceSuccessChoiceModal'); if (modal) modal.classList.add('show'); }, 600);\n"
        print("OK: updated success toast & modal trigger")
        break

with open(index_path, "w", encoding="utf-8") as f:
    f.writelines(lines)

print("SUCCESSFULLY PATCHED INDEX.HTML!")
