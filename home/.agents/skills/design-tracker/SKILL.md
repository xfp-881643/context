---
name: design-change-tracker
description: >
  Track design changes in Figma or FigCraft across iterations.
  Capture design snapshots, compare them with previous versions,
  identify added, modified, removed, moved, and unchanged elements,
  and implement only the changes while preserving existing code.
---

# Design Change Tracker

## 1. Purpose

This skill manages the lifecycle of design changes between Figma/FigCraft designs and application code.

The agent must not assume that the current design is a completely new design.

Before implementing a design, it must:

1. Check whether a previous design snapshot exists.
2. Retrieve the current design.
3. Compare the current design against the previous snapshot.
4. Identify exactly which elements have changed.
5. Investigate the corresponding implementation.
6. Implement only the necessary changes.
7. Record the analysis and implementation results.

The primary goal is to avoid repeatedly implementing the entire design when only a small portion has changed.

## 2. Storage Structure

All persistent design context must be stored under the project root `.context/`.

```text
.context/
└── design-tracking/
    ├── README.md
    ├── sources/
    │   └── design-sources.json
    ├── snapshots/
    │   ├── latest.json
    │   ├── history/
    │   │   ├── 2026-11-16T120000.json
    │   │   └── ...
    │   └── assets/
    ├── reports/
    │   ├── latest.md
    │   └── history/
    │       └── ...
    └── pending/
        └── changes.json
```

### File responsibilities

| File | Purpose |
|---|---|
| `design-sources.json` | Design source and page/frame identifiers |
| `latest.json` | Latest successfully captured design snapshot |
| `history/` | Immutable historical snapshots |
| `assets/` | Relevant exported design assets |
| `latest.md` | Latest design change report |
| `changes.json` | Changes awaiting implementation or verification |

Never overwrite historical snapshots.

Do not store large image files unnecessarily. Prefer references, hashes, and exported assets only when needed.

## 3. Design Source Detection

Support the following design sources:

- Figma
- FigCraft
- Other compatible design tools when their MCP interfaces are available

First inspect the available MCP servers and tools.

Determine the appropriate source adapter based on the available capabilities.

Do not assume that Figma and FigCraft expose identical APIs.

Use the available tools to retrieve:

- File/project identifier
- Page identifier
- Frame/node identifier
- Node name and type
- Parent-child hierarchy
- Position and dimensions
- Layout properties
- Typography
- Colors and fills
- Borders and shadows
- Spacing and constraints
- Component and instance relationships
- Relevant assets
- Text content

Prefer structured design data over screenshots.

Use screenshots or rendered previews as supplementary evidence for visual comparisons.

If a source does not expose a particular property, record it as unavailable rather than inventing a value.

## 4. Initial Snapshot

When no previous snapshot exists:

1. Identify the target design.
2. Retrieve the complete relevant page/frame hierarchy.
3. Capture the available design properties.
4. Save a normalized snapshot.
5. Create an initial report.
6. Record the source identifiers for future retrieval.

The first snapshot is the baseline.

All subsequent comparisons must use this baseline or its latest successfully captured successor.

## 5. Snapshot Schema

Normalize source data into a consistent structure.

Example:

```json
{
  "schema_version": 1,
  "source": {
    "type": "figma",
    "file_id": "FILE_ID",
    "page_id": "PAGE_ID",
    "frame_id": "FRAME_ID"
  },
  "captured_at": "2026-11-16T12:00:00+09:00",
  "design": {
    "id": "FRAME_ID",
    "name": "Dashboard",
    "type": "FRAME",
    "properties": {
      "width": 1440,
      "height": 900,
      "background": "#FFFFFF"
    },
    "children": []
  }
}
```

Each design node should retain:

- Original source ID
- Name
- Node type
- Parent ID
- Child hierarchy
- Relevant visual properties
- Text and component information
- Normalized property hash

Do not discard original IDs during normalization.

## 6. Change Detection

Compare the current snapshot against the previous snapshot.

Classify changes into the following categories.

| Change | Meaning |
|---|---|
| ADDED | New design element |
| MODIFIED | Existing element with changed properties |
| REMOVED | Element no longer exists |
| MOVED | Element position or hierarchy changed |
| RENAMED | Element name changed |
| REORDERED | Child order changed |
| UNCHANGED | No meaningful change |

A single element may have multiple change types.

### 6.1 Element matching

Use the following matching priority:

1. Exact source node ID
2. Component or instance identity
3. Parent identity and node type
4. Name and structural hierarchy
5. Similarity of properties and neighboring elements

Do not classify an element as removed and added simply because its name or position changed.

When identity cannot be established confidently, mark it as `UNCERTAIN`.

### 6.2 Property comparison

Compare individual properties rather than treating the entire node as modified.

Example:

```json
{
  "node_id": "button-123",
  "name": "Primary Button",
  "status": "MODIFIED",
  "changes": {
    "width": {
      "before": 120,
      "after": 160
    },
    "background": {
      "before": "#3366FF",
      "after": "#2255DD"
    }
  }
}
```

Ignore irrelevant metadata such as retrieval timestamps.

Normalize equivalent values before comparison.

For example:

- Equivalent color representations
- Floating-point precision differences
- Default properties versus explicitly specified defaults

Never ignore meaningful visual differences.

## 7. Change Impact Analysis

After identifying design changes, determine their impact on the existing implementation.

For each changed element:

1. Find the corresponding Vue component, page, or CSS selector.
2. Inspect the existing implementation.
3. Determine whether the change requires markup, styling, behavior, or asset modifications.
4. Identify shared components that may affect other screens.
5. Estimate the scope of the modification.

Classify implementation impact:

- STYLE: CSS or visual properties
- STRUCTURE: DOM/component hierarchy
- CONTENT: Text or images
- BEHAVIOR: Interaction or functionality
- COMPONENT: Shared component changes
- ASSET: Image, icon, or other resource

Do not recreate an existing component just because its design has changed.

Prefer modifying the existing implementation.

## 8. Change Report

Generate a report before modifying application code.

The report must contain:

### Summary
- Design source
- Previous snapshot
- Current snapshot
- Total changed elements
- Total added, modified, removed, and moved elements

### Detailed changes

For each change, include:

- Node ID
- Element name
- Page/frame
- Change classification
- Before and after values
- Visual impact
- Related implementation candidates
- Confidence level

### Implementation plan

Separate changes into:

- Required changes
- Optional improvements
- Uncertain changes requiring human confirmation

Do not mix unrelated changes into the implementation plan.

## 9. Implementation Rules

After the change report is generated:

1. Read the existing source code.
2. Map design nodes to existing components.
3. Implement only necessary changes.
4. Preserve existing application behavior.
5. Preserve unrelated styles and components.
6. Avoid unnecessary refactoring.
7. Check for regressions in affected components.
8. Verify the result against the current design when possible.

For removed design elements:

- Determine whether the corresponding application element is obsolete.
- Check whether it is reused elsewhere.
- Do not delete shared components without confirming their dependencies.

For uncertain changes:

- Do not make destructive assumptions.
- Record the uncertainty.
- Request human confirmation when necessary.

## 10. Snapshot Lifecycle

Maintain two separate concepts:

- Design capture status
- Implementation status

A design snapshot can be successfully captured even when implementation is incomplete.

After a successful comparison:

1. Save the new snapshot into `history/`.
2. Update `latest.json`.
3. Save the comparison report.
4. Add unresolved implementation tasks to `pending/changes.json`.

Never lose pending tasks when the next design version arrives.

When new changes are detected, preserve previous pending changes and reconcile them with the latest design.

A pending change may be:

- PENDING
- IN_PROGRESS
- COMPLETED
- SUPERSEDED
- NEEDS_REVIEW

Only mark a change COMPLETED after verifying the implementation.

## 11. Failure Handling

If the design source cannot be accessed:

- Do not overwrite the previous snapshot.
- Do not claim that no changes occurred.
- Report the source access failure.

If only partial design data can be retrieved:

- Mark the snapshot as partial.
- Identify missing nodes or properties.
- Avoid treating missing data as deleted elements.

If node matching is uncertain:

- Preserve both the old and new references.
- Mark the change as UNCERTAIN.
- Do not automatically delete the old implementation.

If the comparison fails:

- Keep the previous baseline intact.
- Save diagnostic information.
- Retry only after resolving the source or data issue.

## 12. Execution Checklist

Before implementation:

- [ ] Identify design source.
- [ ] Identify target page and frames.
- [ ] Read previous snapshot.
- [ ] Capture current design.
- [ ] Compare snapshots.
- [ ] Generate change report.
- [ ] Map changed nodes to source code.
- [ ] Identify shared component impact.
- [ ] Resolve uncertain changes.

After implementation:

- [ ] Implement only required changes.
- [ ] Verify affected UI.
- [ ] Check regressions.
- [ ] Update implementation status.
- [ ] Preserve unresolved tasks.
- [ ] Ensure the latest snapshot and report are saved.

## 13. Default Behavior

Whenever the user requests design implementation or design updates:

**Always perform design change detection first.**

Do not ask the user to manually identify changed areas if the previous snapshot and current design are accessible.

The agent is responsible for determining what changed, where it changed, and what code needs modification.

The user should only be asked when design intent or element identity cannot be reliably determined.