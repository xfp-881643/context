# 저장소 구조

## 배포 저장소

```
context/
│
├── install.sh                   # ~/.agents 설치 스크립트 (local 실행 / curl 파이프)
├── README.md                    # 사용법
├── AGENTS.md                    # 이 저장소 자체 진입 규칙
│
├── home/
│   └── .agents/
│       └── rules/
│           └── context.md       # 전역 alwaysApply 컨텍스트 규칙
│
└── .context/                    # 이 저장소 자체 작업 컨텍스트
    ├── RULES.md
    ├── INDEX.md
    ├── CURRENT.md
    ├── STRUCT.md
    └── tasks/
        ├── 2026-11-08-bunx-skills-context-bootstrap.md
        └── 2026-11-14-global-agents-context-rules.md
```

## 설치 결과 (`~/.agents`)

```
~/.agents/
└── rules/
    └── context.md               # home/.agents/rules/context.md 복사 (기존 skills/ 등 보존)
```

프로젝트에는 정적 규칙을 복사하지 않으며, 에이전트가 작업 시 `.context/`(`INDEX.md`, `CURRENT.md`, `tasks/` 등)를 직접 작성·유지한다.
