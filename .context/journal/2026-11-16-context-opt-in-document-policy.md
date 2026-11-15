---
date: 2026-11-16
status: done
tags: [context, rules]
related: [DECISIONS.md#adr-007]
---

# 2026-11-16: 프로젝트별 context 규칙과 문서 정책 변경

## 목적
전역 자동 적용과 고정 줄 수 제한을 제거하고 프로젝트별 규칙 적용, 문서 언어 및 `STATE.md` 정책을 변경한다.

## 변경
- `context.md`의 `alwaysApply`, Budgets, Superseded 규칙을 제거했다.
- 프로젝트 `AGENTS.md`에서 규칙을 명시적으로 읽고 서브에이전트에도 전달하도록 했다.
- `STATE.md` 생성·갱신을 금지하고 관련 템플릿을 제거했다.
- `journal/`은 한국어, 그 밖의 `.context/` 문서는 영어로 작성하도록 규칙과 템플릿을 변경했다.
- 현재 세션의 상위 지침 때문에 기존 `.context/` 문서는 한국어로 유지했고 `STATE.md`를 갱신했다.
- `README.md`, 프로젝트 지침과 결정 기록을 변경하고 설치본을 갱신했다.

## 검증
- 임시 디렉터리 설치, 규칙 파일 일치, 기존 `skills/` 파일 보존 및 주요 규칙 내용 확인: 통과.
- `bash install.sh`: `/home/xfp/.agents` 설치 성공.
- 새 세션과 서브에이전트에서의 실제 규칙 적용은 검증하지 않았다.

## 남은 사항
- 상위 지침 갱신 후 기존 `.context/` 문서 언어와 `STATE.md`를 정리한다.
