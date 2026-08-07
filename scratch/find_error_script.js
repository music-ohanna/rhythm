const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
const text = fs.readFileSync(filePath, 'utf8');
const lines = text.split('\n');

const scriptLines = [];
let scriptStartLine = 0;

for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('<script>')) {
        scriptStartLine = i + 1;
        for (let j = i + 1; j < lines.length; j++) {
            if (lines[j].includes('</script>')) break;
            scriptLines.push({ lineNum: j + 1, code: lines[j] });
        }
        break;
    }
}

// Test accumulating lines
let accum = '';
for (let i = 0; i < scriptLines.length; i++) {
    accum += scriptLines[i].code + '\n';
    try {
        new Function(accum);
    } catch (e) {
        if (!e.message.includes('Unexpected end of input') &&
            !e.message.includes('Unexpected token') &&
            !e.message.includes('is not defined') &&
            !e.message.includes('Identifier') &&
            !e.message.includes('const') &&
            !e.message.includes('let')) {
            console.log(`Line ${scriptLines[i].lineNum}: ${scriptLines[i].code.trim()}`);
            console.log(`Error: ${e.message}`);
        }
    }
}

// Check whole script syntax
const jsCode = scriptLines.map(s => s.code).join('\n');
try {
    new Function(jsCode);
    console.log('Full script syntax is VALID!');
} catch (e) {
    console.log('Full script error:', e.message);
}
