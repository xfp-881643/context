# Current Project State

## Status
IDLE

Possible values:
- IDLE
- IN_PROGRESS
- BLOCKED

## Current Focus
No active task.

## Recent Progress
- 2026-11-08: `bunx skills` 전달 방식의 `.context` 부트스트랩 추가 (`SKILL.md`, `scripts/init-context.sh`). 4가지 시나리오 검증 완료.
- 2026-11-08: 페이로드를 `template/`로 분리(에이전트 수정 격리), 실패 시에도 설치 흔적 정리.
- 2026-11-08: README.md 사용법 추가.
- 2026-11-08: `bunx skills` 대신 `install.sh`(curl 파이프)로 설치 경로 전환. `.claude` 강제 생성 문제 제거.
- 2026-11-08: 원격 소스 검증. `--agent` 옵션 추가, `skills remove` 잔여물 버그 우회(스냅샷 차집합 정리). `claude-code`/`codex`/`*` 모두 루트에 `.context`+`AGENTS.md`만 남는 것 확인.

## Work In Progress
None.

## Unresolved Issues
- None.

## Next Actions
- No pending actions.

## Important Context
- [Project Overview](PROJECT.md)
- [Architecture](architecture/overview.md)

## Last Updated
YYYY-MM-DD