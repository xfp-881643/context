---
last_verified: 2026-11-15
---

# Decisions

| ID | 날짜 | 상태 | 결정 |
|---|---|---|---|
| ADR-001 | 2026-11-14 | accepted | 전역 규칙은 `~/.agents/AGENTS.md`가 아니라 `~/.agents/rules/context.md`(`alwaysApply: true`)로 둔다. |
| ADR-002 | 2026-11-14 | accepted | 배포는 `bunx skills`가 아니라 `install.sh`(curl/tarball)로 한다. |
| ADR-003 | 2026-11-15 | accepted | `.context/`를 작업 일지가 아니라 오리엔테이션 중심으로 재설계한다. |
| ADR-004 | 2026-11-15 | accepted | 히스토리는 `journal/YYYY-MM-DD-task-name.md` + `journal/INDEX.md`로 두고 `archive/`는 두지 않는다. |
| ADR-005 | 2026-11-15 | accepted | ADR은 `decisions/ADR-*.md`가 아니라 단일 `DECISIONS.md`로 둔다. |
| ADR-006 | 2026-11-15 | accepted | 규칙·템플릿 파일은 영어, `.context/` 문서는 한국어로 쓴다. |

## ADR-001: 전역 규칙 위치

### Context
`~/.agents/AGENTS.md`는 사용자 전역 슬롯 1개만 유지되어 `~/.omp/agent/AGENTS.md`에 가려질 수 있고, task 서브에이전트에서는 `AGENTS.md`가 제외된다.

### Decision
`~/.agents/rules/context.md`에 `alwaysApply: true`를 설정해 모든 프로젝트의 메인 세션과 서브에이전트 요청에 주입한다.

### Alternatives
- `~/.agents/AGENTS.md`: 슬롯 충돌과 서브에이전트 제외 문제.
- 프로젝트마다 `AGENTS.md` 복사: 프로젝트 오염과 drift.

### Consequences
- 규칙이 전역으로 적용된다.
- 규칙 파일이 시스템 프롬프트 토큰을 차지하므로 짧게 유지해야 한다.

### Status
accepted

## ADR-002: 배포 방식

### Context
`bunx skills` v1.7.6은 `.claude/skills`를 강제로 생성하고 설치 경로를 통제할 수 없다.

### Decision
`install.sh`가 `home/.agents/`를 스테이징한 뒤 `~/.agents/`로 복사한다. 로컬 체크아웃과 원격 tarball을 모두 지원한다.

### Alternatives
- `bunx skills`: 설치 경로 통제 불가.
- 수동 복사: 재현성과 검증 부족.

### Consequences
- 기존 `~/.agents/skills/`와 `.skill-lock.json`을 보존한다.
- `curl | bash`와 로컬 실행 모두 지원한다.

### Status
accepted

## ADR-003: 오리엔테이션 중심 재설계

### Context
기존 `.context/`는 `CURRENT.md`와 `tasks/` 중심의 작업 일지에 가까워, 목적·전체 구조·용어를 한 번에 파악하기 어렵고 파일이 무한히 쌓인다.

### Decision
항상 읽는 orientation layer(`INDEX`, `PROJECT`, `ARCHITECTURE`, `GLOSSARY`, `STATE`)와 필요할 때 읽는 reference layer(`CONVENTIONS`, `DECISIONS`, `modules/`), 과거 조사 때만 읽는 history layer(`journal/`)로 나눈다.

### Alternatives
- 기존 `CURRENT.md` + `tasks/` 유지: 누적과 탐색 비용 문제.
- 단일 `CONTEXT.md`: 크기와 갱신 충돌 문제.

### Consequences
- 새 에이전트가 소스 없이 목적·구조·용어·현재 작업을 파악할 수 있다.
- 각 파일에 budget을 두어 누적을 제한한다.

### Status
accepted

## ADR-004: journal과 archive

### Context
`tasks/`와 `archive/`는 둘 다 히스토리 저장소라 역할이 겹친다. 사용자는 완료된 작업을 사람이 보는 용도로 쓴다.

### Decision
`journal/YYYY-MM-DD-task-name.md` 1 task = 1 파일, `journal/INDEX.md`에 전체 목록을 둔다. `archive/`는 두지 않고 superseded 문서는 `status: superseded`로 제자리에 표시한다.

### Alternatives
- `tasks/` + `archive/`: 역할 중복과 이동 비용.
- 월별 `journal/YYYY-MM.md`: 파일 수는 줄지만 동시 수정 충돌이 커진다.

### Consequences
- 오래된 task도 `journal/INDEX.md`에서 찾을 수 있다.
- superseded 문서가 제자리에 남아 검색 시 함께 보인다.

### Status
accepted

## ADR-005: 단일 DECISIONS.md

### Context
`decisions/INDEX.md` + `ADR-*.md`는 에이전트가 인덱스와 ADR 파일을 두 번 읽어야 한다.

### Decision
`.context/DECISIONS.md` 단일 파일에 전체 결정 표와 ADR별 섹션을 둔다. 300줄을 넘으면 연도별 `decisions/YYYY.md`로 분리하고 `DECISIONS.md`는 인덱스로 유지한다.

### Alternatives
- `decisions/` 디렉터리 + 인덱스: 2-hop 탐색.
- ADR을 rule로 등록: 프로젝트 컨텍스트와 전역 규칙의 경계가 흐려짐.

### Consequences
- 에이전트가 한 파일에서 모든 결정을 찾는다.
- 결정이 많아지면 분할 규칙이 필요하다.

### Status
accepted

## ADR-006: 문서 언어

### Context
에이전트가 읽는 규칙·템플릿은 토큰 효율과 지시 정확성이 중요하고, 사람이 읽는 `.context/` 문서는 한국어가 자연스럽다.

### Decision
규칙·템플릿 파일(`context.md`, `context-reference.md`)은 영어, `.context/` 문서는 한국어로 쓴다. 코드 식별자·경로·명령·외부 API 이름은 원문을 유지한다.

### Alternatives
- 전부 한국어: 규칙 토큰 증가와 번역 drift.
- 전부 영어: 사람이 읽는 컨텍스트의 가독성 저하.

### Consequences
- 규칙은 간결하고, 프로젝트 기록은 읽기 쉽다.
- 템플릿의 제목은 한국어로 두어 출력 형식을 맞춘다.

### Status
accepted
