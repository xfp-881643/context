---
date: 2026-11-26
status: done
tags: [skills, cleanup]
related: [2026-11-25-prune-rules-and-skills.md]
---

# 저장소 스킬 중복 정리 (project-audit, paseo-loop, design-sync, opera-analyzer)

## 목표
`home/.agents/skills/`의 나머지 스킬에서 공용 규칙(`AGENTS.md`, `context.md`)과 겹치는 문장, 파일 내부 중복, 하드코딩 값을 정리한다.

## 변경
- `project-audit/SKILL.md`: `verify` 모드 삭제, `dependencies`/`security`/`performance` 모드를 `<area>`로 통합. Untrusted content·Secrets 항목 병합, `AGENTS.md` 읽기 지시와 `.context` 범위·언어 규칙은 `context.md` 참조로 대체.
- `project-audit/report-template.md`: Architecture overview를 `ARCHITECTURE.md` 링크 + 누락 사실만 기록으로 축소, finding 필드와 겹치는 Changes made 표와 Remaining risks 섹션 삭제, After changes 표에서 per-fix 행 제거. 섹션 9개 → 7개.
- `project-audit/checklist.md`: Operational readiness, CI/CD, IaC & containers를 한 항목으로 통합 (14 → 12).
- `paseo-loop/SKILL.md`: `AGENTS.md`/`.context` 읽기 지시 제거, "ID는 `paseo ls`에서 제목으로 찾기" 3회 → 1회, untracked 파일 명령 중복 제거.
- `design-sync/SKILL.md`: `0.2`/`0.05` 하드코딩을 `export.scale`/`export.format`/`export.docScale`로 교체(scale 변경 시 hash 무효화 위험), `context.md`와 겹치는 journal 문장과 일반 원칙 2개 제거.
- `opera-analyzer/SKILL.md`: 스크립트가 읽지만 문서에 없던 `OPERA_CHUNK_SECONDS`, `OPERA_OVERLAP_SECONDS` 추가.

## 결정
- `paseo-loop`는 유지. Paseo 내장 worker/verifier loop는 getpaseo/paseo PR #3053(2026-08)에서 제거되어 대체 수단이 없다. 설치된 paseo 계열 스킬(advisor, committee, handoff)도 Worker→Verifier 반복을 제공하지 않는다.

## 검증
- `grep`으로 남은 `verify` 모드, 하드코딩 scale, 삭제된 섹션 참조가 없음을 확인.
- `paseo` CLI가 이 환경에 없어 `paseo-loop`의 플래그는 미검증.
- 크기: 53389 → 51853 bytes.
- `bash install.sh` 실행 후 `diff -rq`로 `~/.agents/skills/` 반영 확인.

## 남은 작업
- `~/.agents/.skill-lock.json`의 디렉터리 없는 `ponytail` 항목은 저장소 밖이라 건드리지 않음.
