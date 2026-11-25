---
date: 2026-11-25
status: done
tags: [skills, rules, cleanup]
related: []
---

# 2026-11-25: 규칙·스킬 불필요 항목 정리 및 ~/.agents 동기화

## 목표
`AGENTS.md`와 `home/.agents/`(rules, skills)에서 미사용 파일, 중복 규칙, 특정 프로젝트 하드코딩을 제거하고 `~/.agents`에 동기화한다.

## 변경
- `home/.agents/skills/opera-analyzer/`:
  - 설치본(`~/.agents/skills/opera-analyzer`)의 `applause`/`silence` 프롬프트 및 `KIND_KO` 변경을 저장소로 동기화.
  - 미사용/중복 파일 삭제: `README.md`, `prompts/review.md`(및 빈 `prompts/`), `.env.example`.
  - `SKILL.md`를 실행·환경변수·출력·사후검수 중심으로 슬림화 (79줄 → 38줄).
  - `scripts/analyze.ts` 미사용 import(`readdir`, `dirname`, `extname`) 및 미사용 변수(`oldLength`, `newLength`) 제거.
- `home/.agents/skills/design-sync/SKILL.md`: 특정 Vue 프로젝트 하드코딩(`home.vue`, `src/router/index.ts`, `<script setup>`/`api<T>()`)과 구형 `.agent/design/`·`xd://`·중복 문구 제거.
- `home/.agents/skills/paseo-loop/SKILL.md`: 5회 반복되던 heredoc/셸 이스케이핑 설명과 중복 안전 규칙을 통합·압축 (220줄 → 136줄).
- `home/.agents/skills/project-audit/`: `SKILL.md` (276 → 112줄), `checklist.md` (179 → 31줄), `severity.md` (189 → 68줄), `report-template.md` (186 → 175줄) 압축 및 파일 간 중복 제거.
- `AGENTS.md`, `home/.agents/rules/context.md`, `home/.agents/rules/context-reference.md`: 중복 문장 정리.
- `bash install.sh`로 `~/.agents`에 반영하고 설치본의 삭제 대상 파일(`opera-analyzer/README.md`, `prompts/`, `.env.example`)도 제거.

## 검증
- `bun build --no-bundle --target=bun`으로 `analyze.ts` 문법/번들 체크 통과.
- `diff -rq`로 `home/.agents/{rules,skills/*}`와 `~/.agents/{rules,skills/*}` 일치 확인.

## 남은 작업
없음.
