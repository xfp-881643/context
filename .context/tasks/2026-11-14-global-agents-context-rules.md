# 전역 `.agents` 컨텍스트 규칙 전환

## Objective
`template/`에 있던 정적 컨텍스트 규칙(`AGENTS.md`, `RULES.md`, `STRUCT.md` 등)을 `home/.agents/`로 옮기고, `install.sh` 실행 시 `~/.agents/`에 복사되도록 변경한다. 대상 프로젝트 `.context/`에는 에이전트가 작업하면서 작성하는 동적 파일만 남긴다.

## Background and related context
- `omp`의 `agents` discovery provider(우선순위 70)는 opt-in 없이 `~/.agents/rules/*.md`와 `~/.agents/AGENTS.md`를 자동 로드한다.
- `~/.agents/AGENTS.md`는 사용자 전역 슬롯 1개만 유지되어 `~/.omp/agent/AGENTS.md`에 가려질 수 있고, task 서브에이전트에서는 `AGENTS.md`가 제외된다.
- `~/.agents/rules/context.md`에 `alwaysApply: true`를 설정하면 모든 프로젝트의 메인 세션과 서브에이전트 요청마다 규칙이 주입된다.

## Implementation summary
- `home/.agents/rules/context.md` 작성:
  - 기존 `template/AGENTS.md`, `template/.context/RULES.md`, `template/.context/STRUCT.md`의 규칙과 `INDEX.md`/`CURRENT.md` 스타터 스키마를 통합.
  - 프로젝트 루트에 `.context/`가 없으면 작업 시작 시 `INDEX.md`, `CURRENT.md`를 먼저 생성하도록 명시.
  - 프로젝트에 정적 파일(`AGENTS.md`, `RULES.md`, `STRUCT.md`)을 복사하지 않도록 명시(기존 프로젝트에 `.context/RULES.md`가 있으면 함께 참고).
- `template/` 디렉터리 삭제 (`template/AGENTS.md`, `template/.context/*`).
- `install.sh` 수정:
  - `home/.agents/`를 기본 대상 `~/.agents`(또는 인자 `target-dir`)에 복사 (`cp -Rf "$STAGING/.agents/." "$TARGET/"`).
  - 기존 `~/.agents/skills/`, `.skill-lock.json` 등 무관한 파일 보존, 재실행 시 규칙 파일 덮어쓰기.
  - 로컬 체크아웃(`-s/--source` 또는 스크립트 위치) 및 원격 tarball(`CONTEXT_TARBALL_URL` 포함) 모두 지원.
- `README.md`, `.context/STRUCT.md` 갱신.

## Modified files
- `home/.agents/rules/context.md` (신규)
- `template/` (삭제)
- `install.sh` (수정)
- `README.md` (수정)
- `.context/STRUCT.md` (수정)
- `.context/CURRENT.md` (수정)
- `.context/INDEX.md` (수정)
- `.context/tasks/2026-11-14-global-agents-context-rules.md` (신규)

## Important technical decisions
- `home/.agents/AGENTS.md` 대신 `home/.agents/rules/context.md` (`alwaysApply: true`) 채택: `~/.omp/agent/AGENTS.md`와의 1-slot shadowing 회피 및 task 서브에이전트 상속 보장.
- `install.sh`에서 디렉터리 통째 심볼릭 링크/덮어쓰기 대신 스테이징 후 `cp -Rf "$STAGING/.agents/." "$TARGET/"` 사용: 기존 `~/.agents/skills/`와 `.skill-lock.json` 보호.

## Problems encountered
- 없음.

## Failed approaches
- 없음.

## Test and verification results
| 시나리오 | 결과 |
| --- | --- |
| `bash install.sh <tmp>/.agents` (기존 `skills/`, `.skill-lock.json` 포함) | `rules/context.md` 일치, 기존 파일 보존, exit 0 |
| 동일 대상 재실행 (오래된 `rules/context.md` 덮어쓰기) | `home/.agents/rules/context.md`와 일치, exit 0 |
| `cat install.sh \| CONTEXT_TARBALL_URL=file://... bash -s -- <tmp>/.agents` | tarball 추출 및 설치 일치, exit 0 |
| 잘못된 `CONTEXT_TARBALL_URL` | exit 1, 대상 디렉터리 잔여물 없음 |
| `bash install.sh` (실제 `/home/xfp/.agents` 설치) | `/home/xfp/.agents/rules/context.md` 생성, `skills/`·`.skill-lock.json` 보존 |
| 빈 git repo에서 `omp -p --no-session --cwd <tmp>` 실행 | `.context/CURRENT.md`, `.context/INDEX.md`, `.context/tasks/2026-11-14-hello-file.md` 자동 생성, `AGENTS.md`/`RULES.md` 미생성 확인 |

## Remaining issues
- 원격 GitHub 저장소에 커밋·푸시 후 `curl ... | bash` 경로 최종 확인 필요(로컬 push 전).

## Related documents
- [STRUCT.md](../STRUCT.md)
- [RULES.md](../RULES.md)
