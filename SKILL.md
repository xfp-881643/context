---
name: context-init
description: Bootstrap a project's persistent `.context/` knowledge base and root `AGENTS.md`. Use when a project has no `.context/` directory yet, or when asked to set up project memory/context files.
---

# context-init

This skill ships the canonical `.context/` knowledge base (rules, index, current state, structure) plus the root `AGENTS.md` entry file.

## What to do

- If the project already has `.context/`, do NOT copy anything. Read `.context/RULES.md`, `.context/INDEX.md`, and `.context/CURRENT.md` and follow them.
- If `.context/` is missing, run the bootstrap script from this skill directory:

  ```bash
  bash scripts/init-context.sh <project-dir>
  ```

- After bootstrapping, replace the `YYYY-MM-DD` placeholders in `.context/INDEX.md` and `.context/CURRENT.md` with today's date, then report the files created.

## Rules

- Never overwrite an existing `.context/` directory or an existing `AGENTS.md`.
- Keep context files human-readable Markdown; never store credentials, tokens, or secrets.
