# File & Directory Reorganization (Plan-Only)

Find where file placement makes a project hard to navigate or change, and design the smallest useful behavior-preserving migration plan. **This workflow changes no project files** until the user approves the plan (Step 5).

**Scope boundary:** Moves, descriptive path names, and required import/config/build updates belong here. Responsibility/interface/dependency-direction changes are module-boundary work (`module-boundaries.md`); code-level cleanup is a separate change. Identify those needs separately without mixing them into a move map.

## 5-Step Workflow

### Step 1: Map the Area
1. Scope to the user's path/pain point, or inventory the repo at a high level and inspect trouble spots first. Keep an established layout when it works.
2. Identify languages, frameworks, app vs library, workspace/package boundaries, entry points, and build/test/package commands. Separate authored source, tests, resources, tooling, generated output, and vendored code (never relocate generated/vendored files; inspect their producers). Paths can be contracts: runtime discovery, package visibility, public imports, routing, and published artifacts may depend on them.
3. Use symbol-aware tools (LSP / code graph) when available; otherwise search and read source. Map directory roles, file clusters, cross-scope dependencies, and path-based discovery. Use imports and git co-change history (discounting bulk moves/formatting) as supporting evidence for what belongs together. Mark dynamic-reference or text-search gaps explicitly.
4. Load **only** the language references relevant to this scope:
   - TypeScript/JavaScript → `references/languages/typescript.md`
   - Go → `references/languages/go.md`
   - Other stacks → consult primary framework/language docs and cite scope without treating framework conventions as universal rules.

*Done when:* reviewed directories, their roles/constraints, and any inspection gaps are accounted for.

### Step 2: Assess
Look for mixed concerns in one folder, one feature scattered across unrelated folders, ambiguous catch-all locations, redundant nesting, and inconsistent placement. Read implicated files before reporting; every proposed directory needs a clear responsibility and placement rule.

For each finding, cite concrete paths, explain the navigation/change friction, and weigh benefit against churn and compatibility risk. If a cycle requires interface redesign, classify it as module-boundary work—moving folders will not fix it.

| Verdict | Action |
|---|---|
| **Healthy** | Explain why the current layout works and stop. |
| **Localized** | Present affected clusters and recommend the smallest useful reorganization. |
| **Systemic** | Rank independent candidates and propose an incremental starting area. |

Keep unresolved inspection gaps visible. Honor a specific user request on healthy code, but distinguish preference from defect. If a requested move violates a path contract, report the conflict and keep that candidate pending.

*Done when:* every candidate has evidence, a placement-level remedy, and a benefit justifying churn.

### Step 3: Choose and Design
1. Present candidates with stable IDs, affected paths, intended benefit, migration cost, and contract risks. Recommend one and ask the user to choose only when the repository or request cannot settle it.
2. For the chosen candidate, provide:
   - Before/after directory tree
   - Responsibility of each proposed directory
   - Placement rule for the next similar file (when to keep local vs move to shared)
3. Use project vocabulary and naming conventions. A feature folder is not automatically a new package, barrel file, public API, or architectural layer.
4. Resolve choices affecting public paths, framework discovery, or package boundaries before finalizing. Preserve contracts via existing entry points or concrete forwarding plans; if contract preservation requires architectural redesign, stop that candidate and escalate it as module-boundary work.

*Done when:* target layout, placement rules, and compatibility choices are settled.

### Step 4: Write the Migration Plan
Include all five sections so execution requires zero guesswork:

1. **Problem & target:** scope, evidence, before/after tree, directory responsibilities, and future placement rules.
2. **Move map:** every source → destination path (including tests and resources). Use a directory row only when all descendants keep relative paths; enumerate exceptions, conflicts, and case-only renames.
3. **Reference & contract updates:** importers, re-exports, manifests, aliases, discovery globs, resource paths, codegen producers, packaging, CI, scripts, and docs. Name preserved external paths, any forwarding shims, and dynamic references needing runtime checks.
4. **Migration sequence:** bounded steps pairing each move with its caller/config updates. Separate independent clusters; specify lifetime of any temporary forwarding files; never mix behavioral refactors or test deletions into moves.
5. **Verification:** discovered project commands, baseline status, and what failure each check catches (tests, type/build checks, runtime discovery, packaged entry points). Retain test assertions and verify test discovery counts match before/after. Record pre-existing failures and unavailable checks honestly.

Run cheap non-mutating checks if they settle uncertainty; defer mutating generation/auto-fix commands to execution.

*Done when:* every moved path has a destination, reference updates, compatibility handling, and a verification check.

### Step 5: Present & Wait for Approval
- Do not hand off an incomplete outline: if missing facts block a move, reference update, or check, resolve them or flag the plan as provisional.
- Present the complete plan in chat (unless the user asked for a saved file) and **wait for explicit user approval** before moving or editing any files.
- If the migration spans multiple sessions, preserve the exact **Move map** and preserved path contracts verbatim as authoritative requirements for the execution session.
