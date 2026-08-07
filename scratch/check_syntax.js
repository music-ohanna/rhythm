const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
const text = fs.readFileSync(filePath, 'utf8');
const lines = text.split('\n');

lines.forEach((l, idx) => {
    if (l.includes('$')) {
        // check if l contains malformed template literal like $timeSignature
        if (l.includes('$timeSignature') || l.includes('${') && l.includes('`') === false && !l.includes('const') && !l.includes('let')) {
            console.log(`Line ${idx+1}: ${l}`);
        }
    }
});
