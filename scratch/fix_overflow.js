const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

const startTarget = 'function showMeasureOverflowWarning() {';
const endTarget = 'function plainSpecForDuration(beats) {';

const idxStart = text.indexOf(startTarget);
const idxEnd = text.indexOf(endTarget);

if (idxStart > 0 && idxEnd > idxStart) {
    const cleanFn = `function showMeasureOverflowWarning() {
            initAudio();
            const sig = \`\${timeSignature.top}/\${timeSignature.bottom}\`;
            const msg = \`
                <div style="font-size: 15px; font-weight: 800; margin-bottom: 8px; color: #fef08a;">
                    ⚠️ \${sig} 마디의 길이를 넘었습니다
                </div>
                <div style="font-size: 14px; line-height: 1.65; font-weight: 600;">
                    <strong>원인:</strong> 넣으려는 음표(쉼표) 길이가 마디에 남은 박보다 길어요.<br><br>
                    <strong>수정 방법:</strong><br>
                    • 더 짧은 음표나 쉼표를 골라 넣어보세요.<br>
                    • 이미 마디가 다 찼다면 <strong>오른쪽 화살표( > )</strong>를 눌러 다음 마디로 이동하세요.<br>
                    • 중간의 특정 음표를 지우고 싶다면 <strong>악보 위 음표를 더블클릭</strong>하거나 <strong>[🏷️ 선택 삭제]</strong>를 사용하세요.
                </div>
            \`;
            showValidationAlert(msg);
        }

        `;
    text = text.slice(0, idxStart) + cleanFn + text.slice(idxEnd);
    console.log('Fixed function replacement successfully!');
}

fs.writeFileSync(filePath, text, 'utf8');
