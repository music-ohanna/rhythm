const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '..', 'index.html');
let text = fs.readFileSync(filePath, 'utf8');

const targetStart = 'function setTempo(value) {';
const targetEnd = 'function setMetronomeEnabled(enabled) {';

const idxStart = text.indexOf(targetStart);
const idxEnd = text.indexOf(targetEnd);

if (idxStart > 0 && idxEnd > idxStart) {
    const cleanFn = `function setTempo(value) {
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
        }

        `;
    text = text.slice(0, idxStart) + cleanFn + text.slice(idxEnd);
    console.log('Fixed setTempo function replacement successfully!');
}

fs.writeFileSync(filePath, text, 'utf8');
