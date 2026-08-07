const fs = require('fs');
const path = require('path');
const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

text = text.replace('let isPresetScore = false;\r\n        let isPresetScore = false;', 'let isPresetScore = false;');
text = text.replace('let isPresetScore = false;\n        let isPresetScore = false;', 'let isPresetScore = false;');

fs.writeFileSync(filePath, text, 'utf8');
console.log('Cleaned duplicate declaration');
