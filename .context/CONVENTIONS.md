---
last_verified: 2026-11-15
verified_against: 82ce1c0
---

# Conventions

## Build
- 빌드 없음. `install.sh`는 bash 스크립트.

## Test
- `bash -n install.sh`
- 임시 디렉터리에 설치 후 `diff -r`로 `home/.agents/`와 비교.
- 원격 tarball 경로는 `CONTEXT_TARBALL_URL=file://...`로 검증.

## Style
- Bash: `set -euo pipefail`, `die`/`log` 함수, 변수 인용.
- `.context/` 문서: 한국어. 코드 식별자·경로·명령은 원문.
- 규칙·템플릿 파일(`context.md`, `context-reference.md`): 영어.

## Constraints
- `~/.agents/skills/`, `.skill-lock.json` 등 기존 파일을 보존한다.
- 프로젝트에 정적 규칙 파일(`AGENTS.md`, `RULES.md`, `STRUCT.md`)을 복사하지 않는다.
- `context.md`는 700 tokens 이하, `context-reference.md`는 on-demand.
