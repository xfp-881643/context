# Project Instructions

This project maintains its persistent knowledge in `.context/`.

Before meaningful work, read `~/.agents/rules/context.md` and follow it. If the file is unavailable, report that context rules could not be applied.

When delegating, instruct each subagent to read and follow `~/.agents/rules/context.md`. Collect their results and update shared `.context/` files in the main agent to avoid conflicting edits.

## Important

- Do not create another memory directory.
- Context must remain human-readable and agent-independent.

## Restricted Files (Do Not Read or Modify)
- `.env`, `.env.*` (Refer to `.env.example` instead)
- `*.pem`, `*.key`
- `.ssh/`
- `.docker/`
