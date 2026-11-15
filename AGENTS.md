# Project Instructions

This project maintains its persistent knowledge in `.context/`.

Before meaningful work, read `~/.agents/rules/context.md` and follow it. If the file is unavailable, report that context rules could not be applied.

When delegating, instruct each subagent to read and follow `~/.agents/rules/context.md`. Collect their results and update shared `.context/` files in the main agent to avoid conflicting edits.

Preserve important discoveries and technical decisions, including verified solutions and failed approaches. Update `.context/INDEX.md` when documents are added, removed, or significantly changed.

## Important

- All persistent project context must be stored in `.context/`.
- Do not create another memory directory.
- Do not store credentials, API keys, tokens, or secrets.
- Context must remain human-readable and agent-independent.
