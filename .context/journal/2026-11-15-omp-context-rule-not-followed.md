# omp가 전역 `.context` 규칙을 따르지 않은 원인 분석

## Objective
`/mnt/works/deb-package`에서 omp로 `-build` 스크립트 작업을 할 때 `~/.agents/rules/context.md`의 `.context/` 관리 규칙이 자동으로 지켜지지 않은 원인을 규명한다.

## Background and related context
- 규칙 파일: `~/.agents/rules/context.md` (5,236 bytes, 118줄, `alwaysApply: true`). 저장소의 `home/.agents/rules/context.md`와 내용 동일.
- omp 버전: 세션 당시 18.20.0, 현재 18.20.1.
- 대상 세션: `~/.omp/agent/sessions/--mnt-works-deb-package--/2026-11-14T16-49-16-594Z_01a1daf6-9932-7673-a3dc-65c7354d1eaa.jsonl`
- 사용 모델: `openrouter/~deepseek/deepseek-flash-latest` → `openrouter/google/gemini-4-hydrogen` (17:17 전환).

## Investigation
1. **규칙 발견**: omp 18.20.0과 18.20.1의 `loadCapability("rules", { cwd: "/mnt/works/deb-package" })`를 직접 호출.
   - 결과: `{ name: "context", alwaysApply: true, path: "/home/xfp/.agents/rules/context.md" }`, warnings 없음.
2. **프롬프트 주입**: `omp -p`에 "시스템 프롬프트에 `<generic-rules>`가 있으면 첫 120자를 그대로 인용하고, 없으면 `NONE`" 요청.
   - 기본 실행: `# Project Context Management (`.context/`)` … 인용.
   - `--no-rules`: `NONE`.
3. **프롬프트 digest 비교** (`system-prompt-digest`):
   - TUI: 규칙 있음 `5518ce8471ad52bb`, `--no-rules` `f7e4e8252eaa2556`.
   - print: 규칙 있음 `e0f933346536bb45`, `--no-rules` `cdec10baa5eb9442`.
4. **세션 transcript 확인**:
   - 첫 행동은 `ls -la` / `find`였고, `.context/` 확인·생성은 없었음.
   - `.context/` 생성은 17:32, 사용자가 "`~/.agents/rules/context.md` 파일을 읽고 규칙대로 작업을 해줘"라고 명시한 뒤에야 발생.
   - 같은 세션에서 `write` 호출 4회가 잘못된 content(11/11/241/21 bytes)로 `.bin/-build`를 덮어써 `git checkout`으로 복구.
   - provider 오류 반복: `OpenAI responses stream stalled`, gemini `MALFORMED_RESPONSE`.
5. **규칙 크기**: `omp toks ~/.agents/rules/context.md` → 1,197 tokens (deepseek-v3 encoding).

## Findings
- 규칙 파일, 설치 경로, discovery, 시스템 프롬프트 주입은 모두 정상이다. omp는 `alwaysApply: true` 규칙 본문을 `<generic-rules>`에 자동 주입한다.
- 문제는 **강제성 부재**다. omp는 규칙을 조언(advisory)으로만 넣고, `.context/`를 읽었는지/갱신했는지 검사하거나 차단하지 않는다.
- 해당 세션의 모델은 flash 계열이었고 도구 호출 품질도 낮았다(위 4번). 규칙 준수 실패는 모델 행동 문제와 일치한다.
- 규칙 본문이 5.2KB로 길고, 74개 스킬 목록 뒤에 위치해 작은 모델에서 salience가 낮다.

## Root cause
`alwaysApply` 규칙은 시스템 프롬프트에 주입될 뿐 실행 시점 강제가 없다. 모델이 "작업 시작 전 `.context/` 확인/생성" 단계를 건너뛰었고, omp는 이를 감지·차단하지 않는다.

## Recommendations
1. 규칙 준수가 중요한 작업에는 상위 모델 사용 (`modelRoles.default` 조정 또는 `--model`).
2. omp hook(`before_agent_start`, `agent_end`)으로 짧은 리마인더를 주입하고 `.context/` 갱신 여부를 검사.
3. 규칙을 짧은 체크리스트(alwaysApply)와 상세 스키마(rulebook/skill)로 분리해 salience를 높임.
4. (선택) 프로젝트 루트 `AGENTS.md`에 한 줄 포인터 — 단, "프로젝트에 정적 규칙 파일을 두지 않는다"는 설계와 충돌.

## Verification
- 위 1~3, 5번 명령을 실제 실행해 출력 확인.
- `--no-rules` 실행에서만 `NONE`이 나오는 것으로 주입 경로 확인.

## Remaining issues
- 세션 당시 시스템 프롬프트 원문은 세션 파일에 저장되지 않는다. 18.20.0 세션의 주입 여부는 동일 discovery provider·동일 설정을 쓰는 현재 버전의 검증으로 대체했다.
- hook 기반 강제는 아직 구현하지 않았다.

## Related documents
- [CONVENTIONS.md](../CONVENTIONS.md)
- [ARCHITECTURE.md](../ARCHITECTURE.md)
- [2026-11-14-global-agents-context-rules.md](2026-11-14-global-agents-context-rules.md)

## Update: 컨텍스트 규칙 재설계

- `home/.agents/rules/context.md`를 오리엔테이션 중심으로 재작성 (5,236 → 2,498 chars, 1,197 → 668 tokens).
- `home/.agents/rules/context-reference.md` 추가 (rulebook, 영어, 템플릿/스키마).
- 구조: `INDEX`, `PROJECT`, `ARCHITECTURE`, `GLOSSARY`, `STATE`, `CONVENTIONS`, `DECISIONS.md`, `modules/`, `journal/`.
- `tasks/` → `journal/YYYY-MM-DD-task-name.md` + `journal/INDEX.md`.
- `archive/` 제거; superseded는 `status: superseded`로 제자리 표시.
- 모든 `.context/` 문서는 한국어.
- `decisions/ADR-*.md` + `decisions/INDEX.md` → 단일 `DECISIONS.md` (에이전트가 바로 읽음).
- README/STRUCT 갱신.
- 검증: `discoverRuleFromMarkdown`으로 `context.md` alwaysApply, `context-reference.md` rulebook 파싱 확인.
- 남은 작업: `~/.agents`에 `bash install.sh` 적용, 빈 프로젝트에서 새 레이아웃 검증. 이 저장소 `.context/` 마이그레이션은 완료.
