---
date: 2026-11-16
status: blocked
tags: [context, rules]
related: [DECISIONS.md#adr-007]
---

# 2026-11-16: context 문서 규칙 적용

## 목적
현재 배포된 context 규칙에 맞춰 기존 `.context/` 문서를 정리한다.

## 변경
- 존재하지 않는 `alwaysApply` frontmatter를 출처로 삼은 용어 항목을 제거했다.
- `DECISIONS.md`의 분할 가능성과 `STATE.md`의 필수 문서 제외를 현재 규칙에 맞췄다.
- 현재 세션의 상위 지침과 영어 전환 요구의 충돌을 `STATE.md`에 기록했다.

## 검증
`INDEX.md`의 상대 문서 링크와 변경한 정책 설명을 Python으로 확인했다. 모두 통과했다.

## 남은 사항
현재 세션은 `.context/` 문서를 한국어로 작성하도록 요구한다. 상위 지침이 갱신된 환경에서 `journal/` 외 문서를 영어로 전환해야 한다.
