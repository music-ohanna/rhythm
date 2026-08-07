const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

const targetStart = 'for (const sampleKey of getInstrumentSampleKeys(rhythmInstrument)) {';
const idxStart = text.indexOf(targetStart);

if (idxStart > 0) {
    const startTry = text.lastIndexOf('try {', idxStart);
    const endCatch = text.indexOf('}', text.indexOf('return;', idxStart)) + 1;
    if (startTry > 0 && endCatch > startTry) {
        const replacement = `try {
                for (const sampleKey of getInstrumentSampleKeys(rhythmInstrument)) {
                    const assetUrl = rhythmSampleUrls[sampleKey];
                    if (!assetUrl || assetUrl.startsWith('data:')) continue;
                    try {
                        const dataUri = await fetchAudioAsDataUri(assetUrl);
                        html = html.split(assetUrl).join(dataUri);
                    } catch (e) {
                        console.warn('Sample fetch skipped:', e);
                    }
                }
            } catch (error) {
                console.warn('제출 파일 실음 포함 경고 (웹 오디오 실음 연주 엔진 기본 활성화됨):', error);
            }`;
        text = text.slice(0, startTry) + replacement + text.slice(endCatch);
        console.log('Fixed downloadPlayableScoreHtml audio sample handling via index slice!');
    }
}

fs.writeFileSync(filePath, text, 'utf8');
