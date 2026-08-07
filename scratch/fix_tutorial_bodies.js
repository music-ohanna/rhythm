const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// Map of old subjective body text -> clean factual body text
const replacements = [
    // Step 1
    [
        `body: '지금부터 앱이 직접 음표를 넣으며 리듬을 만드는 시범을 보여드립니다!'`,
        `body: '앱이 직접 음표를 입력하며 4/4박자 한 마디를 완성합니다.'`
    ],
    // Step 3 (16th note)
    [
        `body: '<strong>16분음표</strong>를 눌러 촘촘하고 리드미컬한 소리를 넣습니다.'`,
        `body: '<strong>16분음표</strong>를 입력합니다. 1박을 4등분한 길이입니다.'`
    ],
    // Step 4 (dot)
    [
        `body: '음표 입력 후 <strong>[ . ] (점)</strong> 버튼을 누르면 점음표(부점 리듬)로 변합니다.'`,
        `body: '음표 입력 후 <strong>[ . ] (점)</strong> 버튼을 누르면 점음표로 바뀝니다. 원래 길이의 1.5배가 됩니다.'`
    ],
    // Step 5 (triplet)
    [
        `body: '<strong>셋잇단음표</strong> 버튼을 누르면 1박을 3등분한 화려한 리듬이 들어갑니다.'`,
        `body: '<strong>셋잇단음표</strong>를 입력합니다. 1박을 3등분한 길이입니다.'`
    ],
    // Step 6 (tie)
    [
        `body: '<strong>[⌒ 붙임줄]</strong> 기능으로 두 음표를 이어서 부드럽게 연주할 수 있어요.'`,
        `body: '<strong>붙임줄</strong>로 연결된 두 음표는 한 번에 이어서 연주됩니다.'`
    ],
    // Step 7 (tempo)
    [
        `body: '빠르기 슬라이더를 이동해 연주 속도를 <strong>♩ = 80</strong>으로 신나게 높여봅니다.'`,
        `body: '빠르기 슬라이더로 연주 속도를 조절합니다. 지금은 <strong>♩ = 80</strong>으로 변경합니다.'`
    ],
    // Step 8 (play)
    [
        `body: '<strong>[▶ 이 마디 듣기]</strong>를 눌러 완성된 시범 리듬을 들어봅니다!'`,
        `body: '<strong>[▶ 이 마디 듣기]</strong>를 눌러 입력한 리듬을 재생합니다.'`
    ],
    // Step 9 (finish)
    [
        `body: '시범이 완료되었습니다! 이제 자유롭게 나만의 멋진 리듬을 만들어 보세요! 🎉'`,
        `body: '시범이 끝났습니다. 이제 직접 리듬을 만들어 보세요.'`
    ]
];

let count = 0;
for (const [from, to] of replacements) {
    if (text.includes(from)) {
        text = text.replace(from, to);
        count++;
    } else {
        console.warn('NOT FOUND:', from.slice(0, 60));
    }
}

fs.writeFileSync(filePath, text, 'utf8');
console.log(`Done. ${count}/${replacements.length} replacements applied.`);
