---
last_verified: 2026-11-15
verified_against: 82ce1c0
---

# Project

## Why
여러 AI 에이전트가 같은 프로젝트 컨텍스트를 공유하도록, `.context/` 기반의 지속 컨텍스트 관리 규칙을 전역(`~/.agents/rules/`)으로 배포한다.

## Users
- omp, Claude Code, Codex 등 여러 에이전트를 함께 쓰는 개발자.
- 프로젝트를 오가며 같은 컨텍스트 규칙을 유지하려는 사용자.

## Scope
- `home/.agents/rules/context.md` (`alwaysApply: true`)와 `context-reference.md` (rulebook) 배포.
- `install.sh`로 `~/.agents`에 설치.
- 새 프로젝트의 `.context/` 레이아웃과 작성·갱신 프로토콜 정의.

## Non-goals
- 특정 언어·프레임워크의 코딩 규칙 배포.
- 프로젝트 소스 코드 생성.
- 에이전트별 전용 설정 관리.

## Direction
- Now: 오리엔테이션 중심 `.context/` 레이아웃 정착.
- Next: 기존 프로젝트 마이그레이션 가이드와 검증.
- Later: hook 기반 강제(선택).

## Success criteria
- 새 프로젝트에서 에이전트가 `.context/`만으로 목적·구조·용어·현재 작업을 파악한다.
- `context.md`가 세션당 700 tokens 이하로 유지된다.
- `install.sh`가 기존 `~/.agents/skills/`와 `.skill-lock.json`을 보존한다.
