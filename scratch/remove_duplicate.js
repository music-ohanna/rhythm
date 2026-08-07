const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

const targetDupStart = 'E html>\n<html lang="ko">';
const idxDupStart = text.indexOf(targetDupStart);

if (idxDupStart > 0) {
    const idxScript = text.indexOf('<script>', idxDupStart);
    if (idxScript > 0) {
        text = text.slice(0, idxDupStart) + '\n\n    ' + text.slice(idxScript);
        console.log('Successfully removed duplicate HTML block!');
    }
}

fs.writeFileSync(filePath, text, 'utf8');
