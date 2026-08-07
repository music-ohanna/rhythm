const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');
const lines = text.split('\n');

// Line 1111 (index 1110) contains "</div>E html>" - the corruption starts here
// Line 1112 (index 1111) begins the second full HTML document
// The second HTML document ends just before line 2214: "    <script>"
// We need to:
// 1. Fix line 1111 from "    </div>E html>" to "    </div>"
// 2. Remove lines 1112 through 2213 (the second html doc) entirely

// Find the corruption line
const corruptLineIdx = lines.findIndex(l => l.includes('</div>E html>'));
console.log('Corruption at 0-based index:', corruptLineIdx, '(line', corruptLineIdx+1, ')');

// Find the real <script> tag after the duplicate section
let scriptLineIdx = -1;
for (let i = corruptLineIdx + 1; i < lines.length; i++) {
    if (lines[i].trim() === '<script>') {
        scriptLineIdx = i;
        break;
    }
}
console.log('Real <script> at 0-based index:', scriptLineIdx, '(line', scriptLineIdx+1, ')');

if (corruptLineIdx >= 0 && scriptLineIdx > corruptLineIdx) {
    // Fix the corruption line: remove "E html>" suffix
    lines[corruptLineIdx] = lines[corruptLineIdx].replace('E html>', '');
    
    // Remove all lines between corruption and real script (exclusive)
    lines.splice(corruptLineIdx + 1, scriptLineIdx - corruptLineIdx - 1);
    
    const result = lines.join('\n');
    fs.writeFileSync(filePath, result, 'utf8');
    
    // Verify
    const check = fs.readFileSync(filePath, 'utf8');
    const htmlTags = (check.match(/<html/g) || []).length;
    const scriptTags = (check.match(/<script>/g) || []).length;
    console.log('Done! <html> tags:', htmlTags, '(should be 1), <script> tags:', scriptTags, '(should be 1)');
    console.log('Total lines now:', check.split('\n').length);
} else {
    console.error('Could not locate boundaries! corruptLine:', corruptLineIdx, 'scriptLine:', scriptLineIdx);
}
