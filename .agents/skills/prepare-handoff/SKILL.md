---
name: prepare-handoff
description: 작업 완료 후 HANDOFF.md를 작성하고 STATUS.md를 READY_FOR_AUDIT로 변경하며 Codex 감사 프롬프트를 생성합니다.
---

# 📋 핸드오프 작성 스킬 (prepare-handoff)

## 1. HANDOFF.md 작성
`collaboration/HANDOFF.md`에 아래 정보를 정확히 기록한다:
- 변경된 파일 목록 및 핵심 변경 함수
- 반응형 테스트 (데스크톱, 모바일) 결과
- 박자 테스트 (4/4, 6/8) 결과
- 커밋 해시 및 커밋 메시지

## 2. STATUS.md 상태 변경
`collaboration/STATUS.md`의 항목 업데이트:
- 현재 상태: `READY_FOR_AUDIT`
- 현재 담당자: `Codex`
- 다음 작업: `Codex 감사 진행`

## 3. 감사 프롬프트 안내
사용자가 Codex에게 전달할 감사 요청 프롬프트를 출력한다.
