const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// Find the corruption point: "</div>E html>" on line 1111
// The second full html document runs from there until just before the <script> tag
const corruptionMarker = '</div>E html>\r\n<html lang="ko">';
const idxCorrupt = text.indexOf(corruptionMarker);

if (idxCorrupt < 0) {
    // Try alternative line endings
    const alt = '</div>E html>\n<html lang="ko">';
    const idxAlt = text.indexOf(alt);
    if (idxAlt < 0) {
        console.error('Corruption marker not found!');
        process.exit(1);
    }
}

const idxStart = text.indexOf('E html>');
console.log('Corruption starts at char:', idxStart, '(approx line ~1111)');

// The second HTML block ends just before <script> (which is the real script)
// We need to find where the duplicate body ends and the real <script> begins
// The duplicate has its own </body></html> sequence before the real <script>
const idxScript = text.indexOf('\n    <script>', idxStart);
console.log('Real <script> starts at char:', idxScript);

if (idxStart > 0 && idxScript > idxStart) {
    // Replace from "E html>" through just before "\n    <script>" 
    // with just "</div>\n" to close the helpSimpleModal properly
    const before = text.slice(0, idxStart - 5); // remove "</div>" that got corrupted too, keep it clean
    // Actually, we need to keep the </div> that closes helpSimpleModal
    // The line was: "    </div>E html>\r\n"
    // So before the corruption, we should have: "    </div>\n"
    const cleanBefore = text.slice(0, idxStart) + '\n';
    const after = text.slice(idxScript + 1); // skip the leading \n before <script>
    text = cleanBefore + '    ' + after.trimStart();
    console.log('Successfully removed duplicate HTML block');
    console.log('New total chars:', text.length);
} else {
    console.error('Could not locate boundaries!');
    process.exit(1);
}

fs.writeFileSync(filePath, text, 'utf8');

// Verify
const check = fs.readFileSync(filePath, 'utf8');
const htmlCount = (check.match(/<html/g) || []).length;
const scriptCount = (check.match(/<script>/g) || []).length;
console.log('Remaining <html> tags:', htmlCount, '(should be 1)');
console.log('Remaining <script> tags:', scriptCount, '(should be 1)');
