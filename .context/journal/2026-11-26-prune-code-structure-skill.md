---
date: 2026-11-26
status: done
tags: [skills, code-structure, cleanup]
related: [2026-11-26-merge-code-structure-skill.md]
---

# `code-structure` 스킬 중복·충돌 항목 정리

## 목표
`home/.agents/skills/code-structure/`에서 파일 간 중복, 다른 스킬과의 충돌, 교과서 내용을 제거한다.

## 변경
- `SKILL.md`: Audit 모드와 P0~P2 심각도를 제거하고 전체 감사는 `project-audit`으로 넘겼다(심각도 체계 이중화 방지). Supporting References 표를 Operating Modes 표에 합쳤고, 중복 Checklist 항목과 "Evidence over speculation"을 제거했다. `code-quality.md`에서 살린 DRY 예외와 Middle Man 판단은 "Tier 3 Judgment" 절로 옮겼다.
- `references/code-quality.md`: 삭제. "Delete dead code immediately"가 `karpathy-guidelines`와 충돌했고, 나머지 SOLID/스멜 표는 교과서 내용이었다.
- `references/module-boundaries.md`: Architecture Compliance Pass 섹션, 운영 관점 원칙(Individual scale, Deployment independence, Observability, Fail independence), 원칙과 겹치는 위반 항목, 8단계 중 7·8단계를 제거했다(10원칙 → 6원칙, 8위반 → 5위반, 8단계 → 6단계).
- `references/file-reorganization.md`: SKILL.md와 겹치는 Placement Principles 섹션을 제거하고, 고유 내용(경로 계약, co-change 근거, 디렉터리 책임)은 Step 1·2에 녹였다. 승인 대기 문구를 Step 5 한 곳으로 모았다.
- `references/languages/typescript.md`: Angular 문단을 제거했다.

## 검증
- `grep`으로 삭제된 `code-quality.md`와 P0~P2 참조가 남지 않았음을 확인했다.
- 전체 크기: 28014 → 19938 bytes.
- `bash install.sh` 실행 후 `diff -rq`로 `~/.agents/skills/code-structure`가 저장소와 일치함을 확인.

## 남은 작업
없음.
