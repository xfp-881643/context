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
- 배포 규칙: `.context/journal/` 문서는 한국어, 나머지 `.context/` 문서는 영어. 코드 식별자·경로·명령은 원문.
- 규칙·템플릿 파일(`context.md`, `context-reference.md`): 영어.

## Constraints
- `~/.agents/skills/`, `.skill-lock.json` 등 기존 파일을 보존한다.
- 프로젝트에서 규칙을 사용하려면 `AGENTS.md`에 명시적으로 읽기 지시를 둔다.
- `context-reference.md`는 on-demand로 읽는다.
