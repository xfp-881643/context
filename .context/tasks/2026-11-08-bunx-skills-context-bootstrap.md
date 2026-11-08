# bunx skills 기반 .context 부트스트랩

## Objective
`bunx skills`를 설치 경로로 사용해 `.context/`와 `AGENTS.md`를 새 프로젝트에 배포한다. `.context/`가 이미 있으면 아무것도 하지 않는다.

## Background
- `skills` CLI(v1.7.6)는 임의 경로에 파일을 놓을 수 없다. 스킬 디렉터리(`.agents/skills/<name>`, `.claude/skills/<name>`, 루트 `skills/<name>`)에만 설치한다.
- 저장소 루트에 `SKILL.md`가 있으면 저장소 전체가 스킬로 복사되며 숨김 `.context/`도 포함된다. (검증됨)
- 중첩 `skills/` 하위 디렉터리는 페이로드에서 누락된다. 페이로드는 루트(`.context/`, `AGENTS.md`)에 둔다. (검증됨)

## Implementation
- `SKILL.md`: `context-init` 매니페스트.
- `scripts/init-context.sh`:
  1. `$TARGET/.context` 존재 시 즉시 exit 0.
  2. `bunx skills add <source> --skill context-init --agent <agent> --copy -y`.
  3. 설치된 스킬 디렉터리에서 `.context/`를 임시 디렉터리에 복사 후 `mv` (부분 복사 방지).
  4. `AGENTS.md`는 없을 때만 복사.
  5. 설치 전/후 디렉터리 스냅샷 차집합으로 이번 실행이 만든 디렉터리만 삭제, 빈 상위 디렉터리는 `rmdir` 정리.

## Technical decisions
- 스킬 설치는 전달 수단으로만 사용한다. 스킬을 남기면 `.context/`가 두 벌 존재하므로 기본 제거, `--keep-skill`로 유지 가능.
- 소스 기본값은 스크립트 상위 디렉터리(로컬 저장소). 원격은 `-s owner/repo` 또는 `CONTEXT_SKILL_SOURCE`.

## Findings (remote source, agent prompt)
- `-y`는 확인 프롬프트만 건너뛴다. 에이전트 선택 프롬프트는 `-a/--agent`가 있어야 생략된다.
- `-a claude-code` → `.claude/skills/context-init`에만 설치. `.agents/`는 생성되지 않는다.
- `-a '*'` → 79개 에이전트 디렉터리에 복사. `.agents/skills`는 이 경우에만 쓰이는 공용 저장소.
- 사용자가 본 빈 `.agents/skills`는 이전 전체 설치/삭제 후 남은 빈 디렉터리다.

## Bug found in skills v1.7.6
`bunx skills remove <skill>`이 "Successfully removed"를 출력하면서도 `.agents/skills/<skill>`, 루트 `skills/<skill>`, `skills-lock.json` 항목을 남긴다. 스크립트는 `remove` 대신 직접 정리한다.

## Verification
| 시나리오 | 결과 |
| --- | --- |
| 빈 디렉터리 (`claude-code`) | `.context/` + `AGENTS.md`만 남음, exit 0 |
| `-a codex` | `.context/` + `AGENTS.md`만 남음 |
| `-a '*'` | 79개 에이전트 디렉터리 전부 정리됨 |
| `--keep-skill` | `.claude/skills/context-init` + lockfile 유지 |
| `.context` 존재 | 복사 없이 skip, exit 0, 기존 파일 보존 |
| `AGENTS.md`만 존재 | `.context` 생성, 기존 `AGENTS.md` 보존 |
| 기존 `skills-lock.json` | 보존, 수동 정리 안내 출력 |

## Remaining
- 원격 `https://github.com/xfp-881643/context.git` 설치 검증 완료. 스크립트 변경분은 아직 커밋 전.

## Update: template 분리

에이전트가 프로젝트 루트 `.context/`를 수정하면 배포본이 오염되므로 페이로드를 `template/`로 분리했다.

- 추가: `template/.context/`, `template/AGENTS.md` (배포 전용, 에이전트는 수정 금지)
- 스크립트: `<skill>/template/.context`와 `<skill>/template/AGENTS.md`에서만 복사
- 템플릿은 스타터 상태 유지: `template/.context/tasks/` 제외, INDEX/CURRENT의 날짜·기록 placeholder 복원, STRUCT에서 패키지 파일 항목 제거
- `die` 경로에서도 설치 디렉터리/lockfile 정리되도록 trap 기반 cleanup으로 변경

### Verification
| 시나리오 | 결과 |
| --- | --- |
| 로컬 소스 신규 설치 | `template/.context` 및 `template/AGENTS.md`와 `diff -r` 동일 |
| 원격 소스(template 미푸시) | exit 1, 실패 후 설치 흔적 없음 |
| `.context` 존재 | skip, exit 0 |
| 기존 `AGENTS.md` | 보존 |
| `--keep-skill` / `-a '*'` | 각각 유지 / 전체 정리 확인 |

## Update: bunx skills → curl install.sh

`bunx skills`는 v1.7.6에서 `.claude/skills`를 반드시 생성하며 이를 막는 옵션이 없다. 설치 경로를 통제할 수 없어 전달 수단을 GitHub tarball로 교체했다.

- `install.sh` 추가: `curl -fsSL .../install.sh | bash`
  - 스크립트 파일로 실행하면 자기 디렉터리의 `template/` 사용 (네트워크 없음)
  - 파이프 실행이면 `https://github.com/<repo>/archive/<ref>.tar.gz` 다운로드 후 `template/` 추출
  - `-s/--source`, `--repo`, `--ref`, `CONTEXT_TARBALL_URL` 지원
- `scripts/init-context.sh` 삭제 (bunx skills 의존 제거)
- `SKILL.md`는 선택 경로로 유지, 실행 명령을 `install.sh`로 변경

### Verification
| 시나리오 | 결과 |
| --- | --- |
| `bash install.sh <dir>` | `template/`와 `diff -r` 일치, exit 0 |
| 파이프 + tarball | 동일 결과, exit 0 |
| 잘못된 URL | exit 1, 잔여물 없음 |
| 기존 `.context` | skip, exit 0 |
| 기존 `AGENTS.md` | 보존 |

## Update: SKILL.md 삭제

전달 경로가 `install.sh` 하나로 정리되어 스킬 매니페스트는 불필요해졌다. `SKILL.md` 삭제, README/STRUCT의 저장소 구조 갱신.
