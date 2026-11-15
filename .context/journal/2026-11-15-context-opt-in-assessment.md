---
date: 2026-11-15
status: done
tags: [context, rules]
related: [DECISIONS.md#adr-001, DECISIONS.md#adr-003, DECISIONS.md#adr-005]
---

# 2026-11-15: 프로젝트별 context 규칙 적용 검토

## 목적
전역 자동 적용과 문서 줄 수 제한을 제거하는 제안의 영향을 검토한다.

## 확인 사항
- `alwaysApply` 제거 후 프로젝트 `AGENTS.md`에서 규칙 파일을 명시적으로 읽도록 해야 한다. 적용 범위와 서브에이전트 동작은 실제 세션 검증이 필요하다.
- 숫자 제한 외에도 `context.md`의 budget 초과 시 정리 지시와 `context-reference.md`의 300줄 분할 지시가 남아 있다.
- 기존 ADR-001, ADR-003, ADR-005와 README에는 현재 설계가 기록되어 있다.
- 앞선 조사에서 자동 주입은 규칙 준수를 강제하지 않는 것으로 확인됐다.

## 검증
규칙 원본, 설치본, README, ADR과 기존 조사 기록을 읽었다. 설정 변경이나 실행 검증은 하지 않았다.
