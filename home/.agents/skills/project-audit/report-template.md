# Report Template

Use the **full report** for first audits, full-project audits, and runs that fix code. Use the **short report** for focused/incremental audits (`<area>`, `since`, `apply`) with few findings: omit section 3. Always keep section 1's counts and coverage table.

Classification, severity, confidence, status values, and ID rules are defined in
`severity.md`; do not restate them here.

---

## Full report: `.context/audits/YYYY-MM-DD.md`

(Same-day reruns: `YYYY-MM-DD-2.md`, `-3.md`, ...)

```markdown
---
last_verified: YYYY-MM-DD
verified_against: <commit hash, or "uncommitted" / "no VCS">
---

# Project Audit Report — YYYY-MM-DD

## 1. Executive summary

- **Project / repository:**
- **Branch / revision:**
- **Working tree before audit:** clean / list of pre-existing modified files
- **Mode and scope:** read-only | fix | apply | since <rev> | <area>
- **Overall status:** Healthy / Attention required / High risk
- **Findings by severity:** Critical __ / High __ / Medium __ / Low __ / Info __
- **Findings by classification:** Confirmed __ / Improvement __ / Review required __
- **Fixes applied:** __
- **Awaiting user decision:** __
- **Contains sensitive findings:** yes / no

### Summary

Concise, evidence-based overview. Separate confirmed defects from risks, improvements,
and optional observations.

## 2. Scope and approach

- **Included areas:**
- **Excluded areas:**
- **Technologies and major components discovered:**
- **Documentation and instructions reviewed:**
- **Assumptions made:**
- **Known limitations:**

### Coverage

| Area / checklist section | Depth (in-depth / skimmed / not examined) | Status (PASS / ISSUE / NOT APPLICABLE / NOT VERIFIED) | Evidence or finding IDs |
|---|---|---|---|
| ... | ... | ... | ... |

## 3. Architecture notes

Link `.context/ARCHITECTURE.md`; do not copy it. Record only facts the findings depend on that it lacks or gets wrong (and flag those as documentation findings).

## 4. Findings

### [AUD-YYYYMMDD-NNN] Descriptive title

- **Classification:**
- **Severity:**
- **Confidence:**
- **Status:**
- **Location:** file, symbol, interface, data object, or configuration key
- **Evidence:** what was observed and how it was verified
- **Impact:** realistic consequence and conditions
- **Recommendation:** smallest appropriate action
- **Change made:** exact summary, or `None`
- **Verification:** commands/checks and observed result, or what is still required

Repeat per finding. Keep unrelated issues separate. Apply "Sensitive findings" from
`severity.md` to security and secret findings.

## 5. Verification

### Baseline (before any change)

| Check | Command or method | Result | Notes |
|---|---|---|---|
| ... | `...` | PASS / FAIL / NOT RUN | pre-existing failures, reason for NOT RUN |

### After changes

Project-level checks after all fixes; per-fix checks go in each finding's **Verification** field.

| Check | Command or method | Result | Notes |
|---|---|---|---|
| Static analysis / type check | `...` | PASS / FAIL / NOT RUN | ... |
| Full test suite | `...` | PASS / FAIL / NOT RUN | ... |
| Build / package | `...` | PASS / FAIL / NOT RUN | ... |
| Integration / manual check | `...` | PASS / FAIL / NOT RUN | ... |

Exact commands where possible. State unavailable services, tools, credentials, or
environment limitations. A passing build does not prove runtime correctness.

## 6. Review required

For each decision needing user input:

- Finding ID and the decision to make.
- Why automatic modification was unsafe.
- Options, with benefits, risks, and compatibility impact.
- Recommended option, if evidence supports one.
- How to approve: `project-audit apply AUD-...` with the chosen option.

Make the decision understandable without requiring the user to rediscover the issue.

## 7. Previous audit comparison

| Finding ID | Previous status | Current status | Evidence / notes |
|---|---|---|---|
| AUD-YYYYMMDD-001 | OPEN | RESOLVED | ... |

List newly discovered findings and regressions. Retain original IDs. First audit:
write "Baseline report; no previous audit."
```

---

## `latest.md` format: `.context/audits/latest.md`

A pointer plus a register. Never copy report prose into it (one fact, one place).

```markdown
---
last_verified: YYYY-MM-DD
verified_against: <commit hash, or "uncommitted" / "no VCS">
---

# Latest Project Audit

- **Latest report:** [YYYY-MM-DD](YYYY-MM-DD.md)
- **Scope:** ...
- **Overall status:** Healthy / Attention required / High risk

## Unresolved findings

| ID | Severity | Status | Location | Title | First reported | Report |
|---|---|---|---|---|---|---|
| AUD-YYYYMMDD-001 | HIGH | OPEN | `path/or/key` | ... | YYYY-MM-DD | [link](YYYY-MM-DD.md) |

Includes `OPEN`, `NEEDS APPROVAL`, `DEFERRED`, and `REGRESSED`.

## Accepted and false-positive findings

| ID | Status | Location | Reason | Decided by / date | Review by |
|---|---|---|---|---|---|

Kept so later audits do not re-raise them. Remove a row only when its location no
longer exists (status `OBSOLETE`, noted in the next report).
```
