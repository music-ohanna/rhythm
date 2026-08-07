const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

const replacements = [
    // 4/4 button
    ['🥁 4/4 8분음표 기본 리듬', '🥁 4/4 예시 리듬'],
    ['4/4박 8분음표 리듬 예시', '4/4박자'],
    // 3/4 button
    ['🔔 3/4 쿵짝짝 리듬', '🔔 3/4 예시 리듬'],
    ['3/4박 왈츠 형태 리듬', '3/4박자'],
    // 6/8 button
    ['🪘 6/8 붓듬 겹박자 리듬', '🪘 6/8 예시 리듬'],
    ['6/8 겹박자 리듬 예시', '6/8박자'],
];

let count = 0;
for (const [from, to] of replacements) {
    if (text.includes(from)) {
        text = text.replace(from, to);
        count++;
    } else {
        console.warn('NOT FOUND:', from);
    }
}

fs.writeFileSync(filePath, text, 'utf8');
console.log(`Done. ${count}/${replacements.length} replacements applied.`);
