import sys

index_path = r"c:\Users\playv\OneDrive\바탕 화면\workplace\rhythm2\final-rhythm\index.html"

with open(index_path, "rb") as f:
    raw = f.read()

# Let's decode UTF-8 with replace
text = raw.decode("utf-8", errors="replace")

# Prepare replacement for tutorialSteps
old_tutorial_start = "const tutorialSteps = ["
start_pos = text.find(old_tutorial_start)
if start_pos != -1:
    end_pos = text.find("];", start_pos)
    if end_pos != -1:
        new_ts = """const tutorialSteps = [
            {
                title: '🎵 1단계: 음표 넣기',
                body: '아래 버튼에서 <strong>4분음표</strong>, <strong>8분음표</strong> 등 음표를 눌러 악보에 넣어요!<br><small>음표 = 소리가 나는 기호예요.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '🎵 2단계: 쉼표 넣기',
                body: '쉼표 버튼의 <strong>4분쉼표</strong>, <strong>8분쉼표</strong>를 누르면 쉬는 자리를 넣을 수 있어요!<br><small>쉼표 = 잠깐 쉬는 기호예요.</small>',
                anchor: 'noteRestButtons',
                placement: 'top'
            },
            {
                title: '✨ 3단계: 점(.) 붙이기',
                body: '음표나 쉼표를 선택한 뒤 <strong>[ . ] (점)</strong> 버튼을 눌러 보세요!<br>점을 붙이면 그 기호의 길이가 1.5배가 돼요!',
                anchor: 'dotButton',
                placement: 'top'
            },
            {
                title: '🔗 4단계: 붙임줄 만들기',
                body: '음표를 이어 붙이고 싶다면 <strong>[🔗 붙임줄]</strong> 버튼을 누른 뒤,<br>이어 붙일 첫 번째 음표 → 두 번째 음표 순서로 눌러 보세요!',
                anchor: 'tie',
                placement: 'top'
            },
            {
                title: '▶ 5단계: 내 리듬 들어보기',
                body: '아래 <strong>[▶ 이 마디 듣기]</strong> 버튼을 눌러 내가 만든 리듬을 들어봐요!<br><small>반복 재생되니까 수정하면서 들을 수 있어요.</small>',
                anchor: 'play',
                placement: 'top'
            }
        ];"""
        text = text[:start_pos] + new_ts + text[end_pos+2:]
        print("TUTORIAL STEPS REPLACED SUCCESSFULLY!")

with open(index_path, "wb") as f:
    f.write(text.encode("utf-8"))

print("FILE SAVED WITH UTF-8 ENCODING!")
