# Finding Classification, Severity, Status, and Fix Eligibility

Single source of truth for classification, severity, confidence, status vocabulary, finding IDs, automatic-fix eligibility, and sensitive findings. Keep classification (kind), severity (impact × likelihood), and confidence (evidence strength) separate.

## Classification

- **`CONFIRMED`**: Evidence shows the implementation is broken, incorrect, unsafe, or meaningfully wasteful relative to established behavior/requirements (e.g., broken interface call, data corruption, resource leak on error path, missing authz check).
- **`IMPROVEMENT`**: Works today, but evidence supports a clear gain in performance, reliability, consistency, operability, or maintainability (e.g., avoidable repeated work, drifted duplicate logic, missing recovery/diagnostics). Never use for style preferences or speculative modernization.
- **`REVIEW REQUIRED`**: Correct action depends on product/business intent, external compatibility, operational constraints, or unproven reachability (typically `MEDIUM`/`LOW` confidence, e.g., potentially externally used code, public API/schema change, data deletion).

## Severity

Judge from **impact** and **likelihood** under the project's actual deployment (rate unproven risks by demonstrated reachability, not worst-case imagination):

| Impact \ Likelihood | Realistic / routine | Possible, needs conditions | Remote / contrived |
|---|---|---|---|
| Severe (data loss, broad unauthorized access, critical outage) | `CRITICAL` | `HIGH` | `MEDIUM` |
| Significant (important workflow broken, integrity or serious security weakness) | `HIGH` | `MEDIUM` | `LOW` |
| Moderate (unreliable feature, material inefficiency, workaround exists) | `MEDIUM` | `LOW` | `LOW` |
| Minor (edge case, localized duplication, small inefficiency) | `LOW` | `LOW` | `INFO` |

- `CRITICAL`: Escalate at top of final response; explain exposure and containment; never apply a broad/destructive fix without approval.
- `HIGH`: Prioritize promptly; apply only narrow, demonstrably safe fixes in `fix` mode.
- `MEDIUM`: Concrete recommendation; automate only when scope and intent are unambiguous.
- `LOW`: Batch related work; avoid broad refactoring for low-severity items.
- `INFO`: Observation or doc gap without a defect; never modify automatically.

## Confidence

- `HIGH`: Directly demonstrated by source, schema, tests, repro, or authoritative docs.
- `MEDIUM`: Strong evidence, but runtime behavior or external contract is not fully known.
- `LOW`: Plausible concern needing more info or reproduction (normally `REVIEW REQUIRED`; never auto-fix).

## Status

| Status | Meaning |
|---|---|
| `OPEN` | Remains and needs action. |
| `FIXED` | Changed during this audit with recorded verification. |
| `NEEDS APPROVAL` | Requires user decision before modification. |
| `DEFERRED` | Intentionally postponed by user or scope. |
| `ACCEPTED` | User accepted risk/behavior (record who/when/why, optional review date). Skip re-reporting unless evidence changes or review date passes. |
| `FALSE POSITIVE` | Shown not to be a defect (record reasoning so it is not re-raised). |
| `RESOLVED` | Previously open finding verified fixed outside this run. |
| `REGRESSED` | Previously fixed/resolved issue returned. |
| `OBSOLETE` | Code/feature/condition no longer exists. |

## Automatic-fix eligibility (`fix` mode only)

All 5 conditions must hold (in `apply` mode, explicit user decision replaces conditions 1–2):
1. `CONFIRMED` with `HIGH` confidence.
2. Intended behavior is unambiguous from docs, tests, or established code.
3. Narrow and independently revertible; does not touch files with pre-existing uncommitted changes.
4. Does not alter business rules, public contracts, auth/security policy, file formats, schemas, or persisted data.
5. Safe verification (per `SKILL.md` Step 1b) is available and run.

Otherwise leave code unchanged, mark `NEEDS APPROVAL` (or `OPEN`), and explain why.

## Sensitive findings

For security, privacy, and exposed-secret findings:
- Describe weakness class, location, and remediation without exploit payloads, tokens, passwords, keys, or personal data (cite secrets by file and key name only).
- Treat exposed credentials as compromised: recommend rotation/revocation in addition to removal (working-tree removal is insufficient if in git history).
- Flag prominently in the final response so the user can decide whether the report path fits repository visibility.

## Finding ID

`AUD-YYYYMMDD-NNN` (e.g. `AUD-20261124-001`): `YYYYMMDD` is first-reported date; `NNN` increments past the highest ID for that date across existing reports. Retain the original ID in later reports.
