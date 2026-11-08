# 저장소 구조

## 배포 저장소 (bunx skills 패키지)

```
context/
│
├── SKILL.md                     # context-init 매니페스트
├── scripts/
│   └── init-context.sh          # 부트스트랩 스크립트
│
├── template/                    # 배포 페이로드 (에이전트 수정 금지)
│   ├── AGENTS.md
│   └── .context/
│       ├── RULES.md
│       ├── INDEX.md
│       ├── CURRENT.md
│       └── STRUCT.md
│
└── .context/                    # 이 저장소 자체 작업 컨텍스트
    ├── RULES.md
    ├── INDEX.md
    ├── CURRENT.md
    ├── STRUCT.md
    └── tasks/
        └── 2026-11-08-bunx-skills-context-bootstrap.md
```

## 설치 결과 (새 프로젝트)

```
project/
├── AGENTS.md                    # template/AGENTS.md 복사
└── .context/                    # template/.context 복사
```

`scripts/init-context.sh`는 대상 프로젝트에 `.context/`가 없을 때만 복사한다.
