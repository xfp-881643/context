---
date: 2026-11-26
status: done
tags: [skills, code-structure]
related: [2026-11-26-prune-code-structure-skill.md]
---

# `code-structure`를 코딩 중 파일 분리 규칙으로 전환

## 목표
사용자 의도: 코딩 작업 시 파일 하나에 전부 넣는 것을 막고, 기능별로 파일을 분리하며 비슷한 것끼리 같은 디렉토리에 모은다. 기존 스킬은 리뷰·계획 중심이라 일반 코딩 요청에서는 로드되지 않았다.

## 변경
- `home/.agents/skills/code-structure/SKILL.md` 재작성:
  - description을 "코드 작성·추가 시" 트리거로 변경.
  - "While Writing Code" 절차: 작성 전 위치 결정 → 1파일 1책임(분리 조건, ~300줄 정지 신호) → 기능 디렉토리로 모으기(`utils/` 등 catch-all 금지, feature-first) → 과분할 금지 → 기존 대형 파일은 새 기능만 새 파일로, 기존 파일 재구성은 보고 후 요청 시 → 완료 체크리스트.
  - Go/TS 언어 제약 요약, 재구성·모듈 경계는 references로 위임.
  - 3-Tier Triage, Operating Modes 제거.
- `references/file-reorganization.md`, `references/module-boundaries.md`: SKILL.md에서 사라진 Tier 용어를 일반 표현으로 교체.

## 결정
- 기존 대형 파일은 부수적으로 재구성하지 않는다(`karpathy-guidelines`의 surgical change와 충돌 방지). 새 코드만 분리하고 기존 파일은 보고한다.
- 줄 수는 분리 판단의 정지 신호로만 쓰고, 분리 기준은 책임이다.

## 검증
- `grep`으로 references에 Tier/`code-quality.md` 참조가 남지 않았음을 확인.
- 실제 코딩 세션에서의 로드·준수 여부는 미검증.
- `bash install.sh` 실행 후 `diff -rq`로 `~/.agents/skills/code-structure` 일치 확인.

## 남은 작업
없음.
