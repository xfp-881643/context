---
name: code-structure
description: >
  Keeps code split by feature while writing it: one responsibility per file,
  related files grouped in a feature directory, no catch-all files. Use whenever
  writing or adding code (features, modules, components, handlers, scripts),
  deciding where new code goes, or when a file is growing large. Also covers
  reorganizing existing files/folders (plan first) and module split/merge decisions.
---

# Code Structure

Goal: no file that holds everything. Split code by feature and responsibility as you write it, and keep related files together in one directory.

## While Writing Code

### 1. Place before you write
Before adding code, decide its home:
1. Follow the project's existing layout and naming first (inspect sibling directories). Established conventions beat the defaults below.
2. Name the feature or responsibility the code serves (e.g. `orders`, `auth`, `csv-export`).
3. If that feature has a directory, put the code there. If not and the feature will have 2+ files, create one directory named after the feature.
4. A feature with a single file needs no directory; place the file next to its closest related code.

### 2. One file, one responsibility
A file holds one cohesive unit: one feature's logic, one component, one route/handler group, one data-access module, or one feature's types.

Split into separate files when any of these holds:
- The file would contain 2+ features that change for different reasons.
- Layers are mixed: UI/transport (HTTP handler, CLI, component), business rules, and persistence/external I/O in one file.
- A helper, type, or constant block is used independently of the rest of the file.
- The file passes ~300 lines of authored code. Stop and split by responsibility, unless it is one cohesive unit (a state machine, a parser, a lookup table); then state why it stays whole.

Split by responsibility, never by line count alone: `part1.ts` or `helpers2.go` are wrong names.

### 3. Group similar things together
- A feature's files live in its directory: logic, types, helpers, and tests where the toolchain allows.
- Code used by one feature stays in that feature's directory. Move it to a shared directory only when 2+ features use it, and name the directory by purpose (`date-format/`, `http-client/`), never `utils/`, `common/`, `misc/`, or `helpers/`.
- Prefer feature-first directories (`orders/`, `users/`) over type-first ones (`controllers/`, `services/`, `models/`) unless the project already uses type-first or the framework requires it.
- Flatten needless nesting: a directory holding one file, or a chain of single-child directories.

### 4. Don't over-split
- No file per tiny function; each file must make sense on its own.
- No barrel/index files, path aliases, or packages added only to shorten imports.
- No empty layer directories created for future use.

### 5. Existing large files
When the task touches a file that already mixes many features:
- Put the new feature's code in a new file in the right place instead of growing the old one.
- Do not reorganize the existing file as a side effect. Report it (path, mixed features, proposed split) and split it only when the user asks, using `references/file-reorganization.md`.

### 6. Before finishing
- [ ] Each new or changed file has one nameable responsibility.
- [ ] New files sit with related code; no new catch-all files or directories.
- [ ] Imports, build, and tests pass after splits; public import paths and runtime-discovered paths are unchanged.

## Language Constraints

- **Go:** a directory is a package. Group a feature as several files in one package; create a subdirectory only for a real package with its own API. See `references/languages/go.md`.
- **TypeScript/JavaScript:** framework-reserved paths (e.g. Next.js routes) come first. See `references/languages/typescript.md`.
- **Other stacks:** follow the framework's discovery and import rules before choosing paths.

## Other Tasks

| Task | Read |
|---|---|
| Reorganizing existing files/folders | `references/file-reorganization.md` (plan first; change nothing until approved) |
| Module boundaries, bounded contexts, splitting or merging modules | `references/module-boundaries.md` |
