---
last_verified: 2026-11-15
verified_against: 82ce1c0
---

# Glossary

| 용어 | 정의 | Source of truth |
|---|---|---|
| alwaysApply | 시스템 프롬프트에 본문이 자동 주입되는 rule | `home/.agents/rules/context.md` frontmatter |
| rulebook | 이름·설명만 프롬프트에 노출되고 필요할 때 `rule://`로 읽는 rule | `home/.agents/rules/context-reference.md` |
| orientation layer | 항상 읽는 작은 컨텍스트 묶음 (`INDEX`, `PROJECT`, `ARCHITECTURE`, `GLOSSARY`, `STATE`) | `home/.agents/rules/context.md` |
| reference layer | 필요할 때 읽는 문서 (`CONVENTIONS`, `DECISIONS`, `modules/`) | `home/.agents/rules/context.md` |
| history layer | 과거 작업 기록 (`journal/`) | `home/.agents/rules/context.md` |
| journal | 완료된 작업을 사람이 보기 위한 기록 | `journal/INDEX.md` |
| `DECISIONS.md` | 비자명한 결정과 이유를 모은 단일 파일 | `DECISIONS.md` |
| `.context/disabled` | 존재하면 `.context/` 관리를 건너뛰는 마커 | `home/.agents/rules/context.md` |
