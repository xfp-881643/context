---
date: 2026-11-26
status: done
tags: [skills, code-structure]
---

# `code-structure` 통합 스킬 생성

## 배경
`tmp/`에 있던 3개 스킬(`modular-design-principles`, `improve-file-structure`, `engineering-standards`)을 하나로 합쳐 `home/.agents/skills/code-structure/`에 배치했다.

## 변경 사항
- `home/.agents/skills/code-structure/SKILL.md`: 3계층(Tier 1 모듈 경계 / Tier 2 파일 배치 / Tier 3 코드 품질) Triage, 공통 원칙, 3가지 실행 모드(Review·Audit / Design·Split-Merge / Plan-only File Reorganization), P0~P2 심각도 기준 작성.
- `home/.agents/skills/code-structure/references/module-boundaries.md`: `modular-design-principles`의 10원칙(에이전트 규칙 포함), 위반 패턴, 바운디드 컨텍스트 8단계, 6기준 분할/병합, 내부 서브유닛, 컴플라이언스 점검 통합.
- `home/.agents/skills/code-structure/references/file-reorganization.md`: `improve-file-structure`의 5단계 Plan-only 워크플로우와 Move Map 템플릿을 이식하고 외부 하네스 명령 참조(`/implement`, `/supermatt:*`, `/to-spec` 등) 제거.
- `home/.agents/skills/code-structure/references/code-quality.md`: `engineering-standards`에서 교과서 정의와 `refactoring-catalog.md`를 제거하고, 적용 우선순위·DRY 예외·관찰 신호·스멜 표만 유지.
- `home/.agents/skills/code-structure/references/languages/{typescript,go}.md`: 언어별 경로·패키징 제약 이식.

## 비고
- `tmp/` 원본 디렉토리는 삭제하지 않고 그대로 두었다.
