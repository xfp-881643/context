---
alwaysApply: true
description: Persistent project context management in .context/
---

# Project Context Management (`.context/`)

Every project maintains persistent, human-readable, agent-independent knowledge in `<project-root>/.context/`.
Do not copy static instruction/rule files (`AGENTS.md`, `RULES.md`, `STRUCT.md`) into projects; keep only project-specific context files written during work.

## 1. Initialization & Context Loading

Before starting any meaningful task:

1. If `.context/disabled` exists in the project root, skip all `.context/` creation, loading, and maintenance for this project.
2. If `.context/` does not exist in the project root, create `.context/` with starter `INDEX.md` and `CURRENT.md` first.
3. Read `.context/INDEX.md` and `.context/CURRENT.md` (plus `.context/RULES.md` only if the project already has one).
4. Read only task-relevant files (`PROJECT.md`, `DEVELOPMENT.md`, `architecture/`, `modules/`, `problems/`, `knowledge/`, related `tasks/`). Do not load every historical document unnecessarily.
5. Verify historical notes against current source code before acting.

## 2. During Work

Record important discoveries as they happen—do not wait until the end.

Preserve:
- Architectural decisions and reasons
- Technical constraints, dependencies, and side effects
- Verified solutions, failed approaches, and root causes
- Important source paths and identifiers
- User instructions affecting future work
- Unresolved issues and next steps

Do not record:
- Routine commands or implementation details without future value
- Unverified assumptions as facts
- Temporary debugging output
- Credentials, API keys, passwords, tokens, or secrets

## 3. Directory & File Classification

Create subdirectories and files only when needed:

- `INDEX.md`: Concise index of context files, recent tasks (latest 5–10), active issues, and maintenance review date.
- `CURRENT.md`: Latest project state (`Status`: `IDLE` | `IN_PROGRESS` | `BLOCKED`, `Current Focus`, `Recent Progress`, `Work In Progress`, `Unresolved Issues`, `Next Actions`, `Important Context`, `Last Updated`). Update when a task starts, changes direction, hits a blocker, completes a milestone, or finishes. Do not replace task history with `CURRENT.md`.
- `PROJECT.md`: Project purpose, scope, architecture summary, tech stack.
- `DEVELOPMENT.md`: Environment, build/test commands, coding conventions, constraints.
- `architecture/overview.md` & `architecture/decisions/ADR-NNN.md`: System design and ADRs (`Context`, `Decision`, `Alternatives considered`, `Reasons`, `Consequences`, `Status`). Never silently rewrite historical decisions; add a new ADR on change.
- `modules/<name>.md`: Module responsibilities, interfaces, dependencies.
- `tasks/YYYY-MM-DD-<task-name>.md`: Chronological task records (`Objective`, `Background and related context`, `Implementation summary`, `Modified files`, `Important technical decisions`, `Problems encountered`, `Failed approaches`, `Test and verification results`, `Remaining issues`, `Related documents`). Never claim tests passed unless actually executed.
- `problems/<topic>.md`: Bugs/errors (`Symptoms`, `Environment`, `Root cause`, `Investigation process`, `Attempted solutions`, `Successful solution`, `Verification`, `Related task links`). Classify each approach as `VERIFIED`, `FAILED`, `UNVERIFIED`, or `OBSOLETE`. Never promote unverified workarounds.
- `knowledge/<topic>.md`: Reusable patterns and lessons confirmed across tasks. Link from task records with relative paths rather than duplicating text.
- `archive/`: Superseded documents kept for historical reference.

## 4. Starter Templates (New `.context/`)

When creating `INDEX.md` in a project without `.context/`:

```markdown
# Project Context Index

## Current Status
- [Current Work and Handoff](CURRENT.md)

## Recent Tasks
<!-- Keep the latest 5-10 meaningful tasks here. -->

## Active Issues
<!-- Link unresolved issues here. -->
```

When creating `CURRENT.md`:

```markdown
# Current Project State

## Status
IDLE

## Current Focus
No active task.

## Recent Progress

## Work In Progress
None.

## Unresolved Issues
- None.

## Next Actions
- No pending actions.

## Last Updated
YYYY-MM-DD
```

## 5. Source of Truth

When information conflicts, use this priority:
1. Current source code and actual configuration
2. Verified execution and test results
3. Current explicit user instructions
4. Current architecture and development documents
5. Historical task records
6. Unverified assumptions

## 6. Task Completion Protocol

Before considering a meaningful task complete:

1. Review actual changes and verify tests/execution results.
2. Create or update `tasks/YYYY-MM-DD-<task-name>.md`.
3. Update `CURRENT.md` (if incomplete, record actual status and next action).
4. Promote reusable knowledge and update `PROJECT.md`, `DEVELOPMENT.md`, `architecture/`, `modules/`, or `problems/` as needed.
5. Synchronize `INDEX.md` and check relative links (remove duplicates, outdated info, or broken links).
6. Report updated `.context/` files to the user.

Never silently skip context maintenance. Keep all `.context/` files in Git, use clear Markdown with relative links, and never create a second memory directory.
