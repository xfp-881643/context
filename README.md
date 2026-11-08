# context

프로젝트별 지속 컨텍스트(`.context/`)와 AI 진입 규칙(`AGENTS.md`)을 새 프로젝트에 부트스트랩한다.

- `.context/`에는 규칙, 색인, 현재 상태, 구조 문서가 들어 있다.
- 대상 프로젝트에 `.context/`가 이미 있으면 아무것도 하지 않는다.
- 배포본은 `template/`에 있으므로, 에이전트가 프로젝트의 `.context/`를 수정해도 원본은 오염되지 않는다.

## 설치

### 원격 (권장)

```bash
curl -fsSL https://raw.githubusercontent.com/xfp-881643/context/master/install.sh | bash
```

대상 디렉터리 지정:

```bash
curl -fsSL https://raw.githubusercontent.com/xfp-881643/context/master/install.sh | bash -s -- /path/to/project
```

### 로컬 체크아웃

```bash
git clone https://github.com/xfp-881643/context.git
bash context/install.sh /path/to/project
```

로컬 실행은 `template/`을 직접 사용하므로 네트워크가 필요 없다.

## 옵션

```bash
install.sh [options] [target-dir]
```

| 옵션 | 설명 |
| --- | --- |
| `-s, --source <dir>` | 다운로드 대신 로컬 체크아웃 사용 (`<dir>/template` 필요) |
| `--repo <owner/name>` | GitHub 저장소 (기본 `xfp-881643/context`) |
| `--ref <ref>` | 브랜치/태그 (기본 `master`) |
| `-h, --help` | 도움말 |

환경 변수 `CONTEXT_TARBALL_URL`로 tarball URL을 통째로 덮어쓸 수 있다 (미러, `file://` 테스트 등).

## 동작

1. `<target>/.context`가 존재하면 `skip` 출력 후 종료 코드 0.
2. `template/.context/`를 임시 디렉터리에 복사한 뒤 `mv` → 부분 복사가 남지 않는다.
3. `template/AGENTS.md`는 대상에 없을 때만 복사한다.
4. 실패 시 다운로드/임시 파일을 정리하고 종료 코드 1로 끝난다.

설치 후 프로젝트 구조:

```
project/
├── AGENTS.md
└── .context/
    ├── RULES.md
    ├── INDEX.md
    ├── CURRENT.md
    └── STRUCT.md
```

## 요구사항

- Bash (`set -euo pipefail` 사용)
- 원격 설치 시 `curl`, `tar`

## 저장소 구조

```
context/
├── install.sh        # 설치 스크립트
├── template/         # 배포 페이로드 (수정 금지)
│   ├── AGENTS.md
│   └── .context/
├── SKILL.md          # bunx skills 사용자를 위한 선택 매니페스트
└── .context/         # 이 저장소 자체 작업 컨텍스트
```

`template/`은 새 프로젝트에 그대로 배포되므로, 이 저장소에서 작업할 때는 루트 `.context/`를 수정한다.

## 워크플로

설치 후 에이전트는 `.context/RULES.md` 절차를 따른다.

1. 작업 시작 시 `INDEX.md`, `CURRENT.md`를 읽는다.
2. 작업 중 발견한 결정·실패를 기록한다.
3. 작업 완료 시 `tasks/YYYY-MM-DD-*.md`를 추가하고 `CURRENT.md`, `INDEX.md`를 갱신한다.
