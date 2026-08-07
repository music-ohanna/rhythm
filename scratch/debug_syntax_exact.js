const fs = require('fs');
const path = require('path');
const vm = require('vm');

const filePath = path.join(__dirname, '..', 'index.html');
const text = fs.readFileSync(filePath, 'utf8');
const lines = text.split('\n');

const scriptLines = [];
for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('<script>')) {
        for (let j = i + 1; j < lines.length; j++) {
            if (lines[j].includes('</script>')) break;
            scriptLines.push({ lineNum: j + 1, code: lines[j] });
        }
        break;
    }
}

// Binary search for error line
let low = 0;
let high = scriptLines.length - 1;
let errorLineNum = -1;

while (low <= high) {
    const mid = Math.floor((low + high) / 2);
    // Comment out lines after mid
    const codeChunk = scriptLines.map((s, idx) => idx <= mid ? s.code : '// ' + s.code).join('\n');
    try {
        new vm.Script(codeChunk);
        // Valid so far, error is later
        low = mid + 1;
    } catch (e) {
        if (e.message.includes('Unexpected identifier') || e.message.includes('SyntaxError')) {
            errorLineNum = scriptLines[mid].lineNum;
            high = mid - 1;
        } else {
            low = mid + 1;
        }
    }
}

console.log('Error found near line:', errorLineNum);
if (errorLineNum > 0) {
    for (let l = Math.max(1, errorLineNum - 5); l <= Math.min(lines.length, errorLineNum + 5); l++) {
        console.log(`${l}: ${lines[l - 1]}`);
    }
}
