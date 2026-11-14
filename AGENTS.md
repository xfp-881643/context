# Project Instructions

This project maintains its persistent knowledge in `.context/`.

## Mandatory Context Initialization

Before starting any meaningful task:

1. Read `.context/INDEX.md`.
2. Read `.context/PROJECT.md`, `.context/ARCHITECTURE.md`, `.context/GLOSSARY.md`, `.context/STATE.md`.
3. Read `.context/CONVENTIONS.md` and `.context/DECISIONS.md` when relevant.
4. Check `.context/journal/INDEX.md` for related work before implementing changes.

## Mandatory Context Maintenance

During work:
- Preserve important discoveries and technical decisions.
- Record verified solutions and failed approaches.

After meaningful work:
- Create `.context/journal/YYYY-MM-DD-task-name.md` and add a row to `.context/journal/INDEX.md`.
- Rewrite `.context/STATE.md`.
- Update `PROJECT.md`, `ARCHITECTURE.md`, `GLOSSARY.md`, or `DECISIONS.md` only when a fact changed.
- Update `.context/INDEX.md` when documents are added, removed, or significantly changed.

## Important

- All persistent project context must be stored in `.context/`.
- Follow the global `~/.agents/rules/context.md` for detailed procedures.
- Do not create another memory directory.
- Do not store credentials, API keys, tokens, or secrets.
- Context must remain human-readable and agent-independent.
