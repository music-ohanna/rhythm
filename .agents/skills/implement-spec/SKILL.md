---
name: implement-spec
description: collaboration/SPEC.md 명세를 읽고 안티그래비티 코딩 및 테스트 절차를 수행합니다.
---

# 🛠️ SPEC 구현 스킬 절차 (implement-spec)

## 1. 사전 점검
1. `collaboration/PROJECT_RULES.md`와 `collaboration/SPEC.md`, `collaboration/STATUS.md`를 읽는다.
2. `STATUS.md`의 상태가 `SPEC_APPROVED`인지 확인한다.
3. 상태를 `IN_PROGRESS`로 변경한다.

## 2. 코드 작업
1. `SPEC.md`에 명시된 기능 범위만 수정한다.
2. 기존 사용자 코드 및 V자 리듬 표기 로직을 보존한다.

## 3. 검증
1. 브라우저 및 반응형(데스크톱, 스마트폰 레이아웃) 확인.
2. 4/4, 6/8 박자 모드 및 오디오 재생 확인.

## 4. 완료 준비
1. 테스트 통과 확인 후 `prepare-handoff` 스킬을 호출하거나 핸드오프 작성을 준비한다.
