const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

// 1. setTempo real-time playback speed update
const targetFnTempo = 'function setTempo(value) {';
const idxTempo = text.indexOf(targetFnTempo);
if (idxTempo > 0) {
    const endTempo = text.indexOf('}', idxTempo) + 1;
    const newSetTempo = `function setTempo(value) {
            tempo = Math.max(40, Math.min(160, Number(value) || 60));
            const tempoValue = document.getElementById('tempoValue');
            if (tempoValue) tempoValue.textContent = \`♩ = \${tempo}\`;
            updatePlayButtonLabel();

            if (isPlaying && !isCountingIn) {
                // 실시간 빠르기 조절: 연주 중 슬라이더 변경 시 즉시 연주 속도 갱신
                playTimeouts.forEach(t => clearTimeout(t));
                playTimeouts = [];
                scheduledAudioNodes.forEach(node => { try { node.stop(); } catch(e){} });
                scheduledAudioNodes.clear();
                cancelAnimationFrame(playbackAnimFrame);

                const beatDuration = 60 / tempo;
                if (isProjectPlaying) {
                    executeProjectPlayback(beatDuration, audioCtx.currentTime + 0.03);
                } else {
                    const totalBeats = getVisibleTimelineBeats();
                    executeCorePlayback(notes, beatDuration, totalBeats, audioCtx.currentTime + 0.03);
                }
            }
        }`;
    text = text.slice(0, idxTempo) + newSetTempo + text.slice(endTempo);
    console.log('1. setTempo updated successfully');
}

// 2. showMeasureOverflowWarning student-friendly layout
const targetOverflowFn = 'function showMeasureOverflowWarning() {';
const idxOverflow = text.indexOf(targetOverflowFn);
if (idxOverflow > 0) {
    const endOverflow = text.indexOf('}', idxOverflow) + 1;
    const newOverflowFn = `function showMeasureOverflowWarning() {
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
        }`;
    text = text.slice(0, idxOverflow) + newOverflowFn + text.slice(endOverflow);
    console.log('2. showMeasureOverflowWarning updated successfully');
}

fs.writeFileSync(filePath, text, 'utf8');
console.log('Patch 2 complete!');
