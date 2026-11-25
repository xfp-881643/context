---
name: design-sync
description: >
  Find what changed between a FigCraft/Figma design and the implemented UI
  without the user listing it, then implement only the delta. Per-screen pixel
  hashes find WHICH screens changed; a stored node tree per screen finds WHAT
  changed. Use for "디자인 적용", "디자인 수정 반영", "뭐가 바뀌었는지 모르겠어",
  design QA, or when a design file was edited again.
---

# design-sync

Design keeps changing; the user will not always say what changed. Detect the delta, report it, implement only it.

## State

Per subproject, in its own `.context/` (see `~/.agents/rules/context.md` Scopes). A design applies to one subproject; never write this state to the root `.context/`.

```text
<subproject>/.context/design/
  screens.json   # source + per-screen hashes, status
  nodes/<id>.json  # normalized node tree of each screen at last capture
  shots/         # PNG renders; MUST be gitignored
```

`screens.json`:

```json
{
  "doc": {"name": "", "path": "<.figcraft/.fig path>", "pageId": 2, "frameId": 3},
  "export": {"format": "png", "scale": 0.2, "docScale": 0.05},
  "docSha": "",
  "screens": [{
    "id": 34550, "label": "", "file": "src/views/home.tsx",
    "sha": "<last captured>", "appliedSha": "<last implemented>", "confirm": false
  }]
}
```

- `sha != appliedSha` → design captured but not implemented yet. This is the pending list. It survives later captures.
- `file` is relative to the subproject. `confirm: true` only after the user confirms the mapping; until then `file` is a guess.
- Write a journal entry per `context.md` (Korean, `<subproject>/.context/journal/`) after each apply. A task spanning 2+ subprojects goes to the root journal.

## Ready check

1. Read `.context/design/screens.json`. Missing → **baseline**.
2. MCP `figcraft` is `figcraft-cli mcp` (headless). Call `open_file` with `doc.path` first; headless has no document otherwise.
3. Optional: edit the document in the live app. Start `figcraft --control 7979 "<doc.path>"` and run the MCP as `figcraft-cli mcp --attach 7979`. Without a reachable server calls fail with `MCP server not connected: figcraft`.

## check: what changed

For each screen, re-export at `export.scale` and hash:

```js
for (const s of screens) {
  await tool.mcp__figcraft_export({ids:[s.id], format:'png', scale:0.2,
    path:`<repo>/.context/design/shots/${s.id}.png`});
}
```

`sha256sum` the PNGs; also export `frameId` at `docScale` for `docSha`. Report `id | label | file | changed?`.

- screen `sha` differs → **changed**.
- `docSha` differs, no screen differs → layer added, moved outside a screen, or new screen: run **discover**.
- id in the document absent from `screens.json` → **new screen**: run **discover**.
- Never report "no changes" from `docSha` alone.
- Source unreachable or export fails → report the failure. Never overwrite the stored state and never claim "no changes".

### what changed inside a changed screen

`get_node` the screen and normalize (id, name, type, parent, x/y/width/height, layout, fills, strokes, effects, typography, text, component/instance ref; mark unavailable properties as unavailable, never invent). Diff against `nodes/<id>.json`.

Match nodes by: source id → component/instance identity → parent + type → name + position. If none is confident, mark `UNCERTAIN`; never turn it into removed+added.

| Class | Meaning |
|---|---|
| ADDED / REMOVED | node appeared / disappeared |
| MODIFIED | list each property `before → after` |
| MOVED / REORDERED | parent or position / child order changed |
| RENAMED | name only |

Ignore float noise and equivalent color notations. No stored tree (first run, or huge screen) → fall back to eye review of the render.

Save the new `sha` and `nodes/<id>.json` after the report. Leave `appliedSha` alone. Partial capture → say so and do not treat missing nodes as removed.

## discover: new or moved screens

`inspect_document` / `get_node` responses over ~500 lines are elided; do not read 400+ children in one call.

1. `tool.mcp__figcraft_screenshot({})`, or export the frame at 0.05.
2. A screen is a visually separated block. Get its id from `get_node` of a known neighbour, or select it on the canvas.
3. Export candidates at scale 0.2, view them, add each with `label`, `file`, `sha`, `confirm: false`.
4. Many candidates: render a `contact.html` grid of `shots/`, serve with `bun`, screenshot once.

## review: design vs running UI

Changed screens only (`sha != appliedSha`).

1. Start the app's dev server and navigate to the screen's route.
2. Capture with chrome-devtools MCP at 1440x900; view the design render of the same screen.
3. List differences, one row each: design value vs current value.
4. Check against the subproject's `design.md` / `CONVENTIONS.md`. Design contradicts it (new field, renamed term) → ask which wins before editing.

Split findings into required, optional, uncertain. Do not put unrelated items in one plan.

## apply: minimal change

Order: tokens → shared components → one view per change.

- Edit existing components; never recreate one because its design changed.
- Shared component touched → list other screens that use it and check them.
- Design removed an element → check it is not reused before deleting.
- Uncertain item: record it, do not guess destructively, ask.
- Update the written contract (`design.md`) in the same change.
- Obey the subproject's coding conventions (`CONVENTIONS.md`).
- Verify: project checks (e.g. `npm run type-check && npm run build && npm run lint`) and compare the affected screens visually.
- Only after verification set `appliedSha = sha` for those screens.

## baseline

1. `open_file` the document; `inspect_document`: record `name`, `path`, `pageId`, frame id and size.
2. Identify screens (**discover**), export each at 0.2, hash, save trees, write `screens.json` with `docSha`.
3. If the UI already matches the design, set `appliedSha = sha`; else leave it unset so everything shows as pending.

## Limits

- Exports are deterministic (same document and scale → same sha256). Changing `scale` invalidates all hashes. If every screen changes after switching between headless and the app, fonts differ: re-baseline.
- SVG-imported documents have no layer names or text layers; screen identity is positional and needs one human confirmation.
- Hidden or off-canvas layers still change the `docSha`.
