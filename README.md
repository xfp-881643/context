# context

전역 AI 규칙(`home/.agents/`)을 `~/.agents/`에 설치해, 어떤 프로젝트에서든 `.context/` 기반의 지속 컨텍스트 관리가 동일하게 동작하도록 한다.

- `home/.agents/rules/context.md` (`alwaysApply: true`)가 전역 규칙으로 로드된다.
- 상세 템플릿은 `home/.agents/rules/context-reference.md`(rulebook)로 분리되어 필요할 때 `rule://context-reference`로 읽는다.
- 프로젝트 루트에는 정적 규칙 파일(`AGENTS.md`, `RULES.md`, `STRUCT.md`)을 복사하지 않고, 에이전트가 작업 중 작성·갱신하는 `.context/` 파일만 둔다.
- 설치 시 기존 `~/.agents/skills/` 등 다른 파일은 보존된다.

## 설치

### 원격 (권장)

```bash
curl -fsSL https://raw.githubusercontent.com/xfp-881643/context/master/install.sh | bash
```

설치 대상 디렉터리 지정 (기본값 `~/.agents`):

```bash
curl -fsSL https://raw.githubusercontent.com/xfp-881643/context/master/install.sh | bash -s -- /path/to/.agents
```

### 로컬 체크아웃

```bash
git clone https://github.com/xfp-881643/context.git
bash context/install.sh
```

로컬 실행은 `home/.agents/`를 직접 사용하므로 네트워크가 필요 없다.

## 옵션

```bash
install.sh [options] [target-dir]
```

| 옵션 | 설명 |
| --- | --- |
| `-s, --source <dir>` | 다운로드 대신 로컬 체크아웃 사용 (`<dir>/home/.agents/` 필요) |
| `--repo <owner/name>` | GitHub 저장소 (기본 `xfp-881643/context`) |
| `--ref <ref>` | 브랜치/태그 (기본 `master`) |
| `-h, --help` | 도움말 |

환경 변수 `CONTEXT_TARBALL_URL`로 tarball URL을 통째로 덮어쓸 수 있다 (미러, `file://` 테스트 등).

## 동작

1. `home/.agents/`를 임시 스테이징 디렉터리에 복사해 무결성(`rules/context.md` 존재)을 확인한다.
2. 대상 디렉터리(기본 `~/.agents`)에 `rules/context.md` 등을 복사한다. 기존 무관한 파일(`skills/` 등)은 건드리지 않는다.
3. 실패 시 다운로드/임시 파일을 정리하고 종료 코드 1로 끝난다.

## 요구사항

- Bash (`set -euo pipefail` 사용)
- 원격 설치 시 `curl`, `tar`

## 저장소 구조

```text
context/
├── install.sh                 # ~/.agents 설치 스크립트 (로컬 / curl 파이프)
├── README.md                  # 사용법
├── AGENTS.md                  # 이 저장소 자체 진입 규칙
├── home/
│   └── .agents/
│       └── rules/
│           ├── context.md            # 전역 alwaysApply 컨텍스트 규칙
│           └── context-reference.md  # 템플릿/스키마 (rulebook)
└── .context/                  # 이 저장소 자체 작업 컨텍스트
```

## 워크플로

`omp`가 시작되면 `~/.agents/rules/context.md`가 자동으로 주입된다. 상세 템플릿은 `context-reference.md`(rulebook)로 분리되어 필요할 때 `rule://context-reference`로 읽는다.

1. 프로젝트 루트에 `.context/`가 없으면 `INDEX.md`, `PROJECT.md`, `ARCHITECTURE.md`, `GLOSSARY.md`, `STATE.md`를 만든다.
2. 작업 시작 시 위 5개 문서를 읽는다. `modules/`, `DECISIONS.md`는 작업이 건드릴 때만 읽는다.
3. 작업 중 바뀐 사실(목적, 구조, 용어, 결정)만 해당 문서에 반영한다.
4. 작업 완료 시 `journal/YYYY-MM-DD-task-name.md`를 만들고 `journal/INDEX.md`에 행을 추가한다. `STATE.md`는 덮어쓴다.
5. `journal/`은 완료된 작업을 사람이 보기 위한 기록이며, 에이전트는 과거 조사 때만 읽는다.
