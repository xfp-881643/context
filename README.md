# context

공유 AI 규칙(`home/.agents/`)을 `~/.agents/`에 설치하고, 프로젝트별 `AGENTS.md`에서 선택적으로 활성화해 `.context/`를 관리한다.

- `home/.agents/rules/context.md`는 자동 주입되지 않는다. 적용할 프로젝트에서 명시적으로 읽도록 지시한다.
- 상세 템플릿은 `home/.agents/rules/context-reference.md`(rulebook)로 분리되어 필요할 때 `rule://context-reference`로 읽는다.
- 설치 시 프로젝트에 파일을 복사하지 않으며, 기존 `~/.agents/skills/` 등 다른 파일은 보존된다.

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
│           ├── context.md            # 프로젝트별로 선택하는 컨텍스트 규칙
│           └── context-reference.md  # 템플릿/스키마 (rulebook)
└── .context/                  # 이 저장소 자체 작업 컨텍스트
```

## 워크플로

규칙을 사용할 프로젝트의 `AGENTS.md`에 다음 지시를 추가한다. 파일이 없으면 규칙을 적용할 수 없으므로 에이전트가 이를 알린다.

```markdown
Before meaningful work, read `~/.agents/rules/context.md` and follow it. If it is unavailable, report that context rules could not be applied.
When delegating, instruct each subagent to read and follow the same rule. Collect results and update shared `.context/` files in the main agent.
```

상세 템플릿은 `context-reference.md`(rulebook)에서 필요할 때 읽는다.

1. 프로젝트 루트에 `.context/`가 없으면 `INDEX.md`, `PROJECT.md`, `ARCHITECTURE.md`, `GLOSSARY.md`를 만든다.
2. 작업 시작 시 위 4개 문서를 읽고, `modules/`, `DECISIONS.md`는 필요할 때만 읽는다.
3. 작업 중 바뀐 사실(목적, 구조, 용어, 결정)만 해당 문서에 반영한다.
4. 작업 완료 시 `journal/YYYY-MM-DD-task-name.md`를 만들고 `journal/INDEX.md`에 행을 추가한다.
5. `journal/` 문서는 한국어로, 나머지 `.context/` 문서는 영어로 작성한다. 과거 기록은 조사할 때만 읽는다.
