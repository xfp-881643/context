# Finding Classification, Severity, Status, and Fix Eligibility

This file is the single source of truth for classification, severity, confidence,
status vocabulary, finding IDs, and automatic-fix eligibility. `SKILL.md` and
`report-template.md` link here instead of restating these rules.

Classification describes the kind of finding. Severity describes potential impact.
Confidence describes the strength of evidence. Keep the three dimensions separate.

## Classification

### CONFIRMED

Evidence demonstrates that the implementation is incorrect, broken, unsafe, or
meaningfully wasteful relative to established requirements or behavior.

Examples:
- A caller invokes an interface that the implementation does not provide.
- A data conversion demonstrably corrupts values.
- A failure path leaks a resource or leaves an operation in an invalid state.
- An access-control check is missing on a protected operation.

### IMPROVEMENT

The current implementation may work, but evidence supports a meaningful improvement
in performance, reliability, consistency, operability, or maintainability.

Examples:
- Repeated work creates a clear and avoidable performance cost.
- Duplicate implementations have drifted and cause inconsistent behavior.
- A critical workflow lacks practical diagnostics or recovery handling.

Do not classify stylistic preferences or speculative modernization as improvements.

### REVIEW REQUIRED

The correct action depends on business intent, compatibility, product decisions,
operational constraints, or a potentially breaking change. Also use it for plausible
risks whose exploit or failure path is not demonstrated (typically MEDIUM or LOW
confidence).

Examples:
- A feature appears unused but may be called by an external consumer.
- A public interface change may affect clients not present in the repository.
- A data migration or deletion could affect retained records.
- Multiple architectural approaches are valid and trade off different requirements.
- Input reaches a sensitive sink, but reachability from an untrusted source is unproven.

## Severity

Judge severity from **impact** (what is lost or broken) and **likelihood** (how
realistic the trigger or exploit path is under the project's actual deployment).
Rate an unproven risk by its demonstrated reachability, not by worst-case imagination.

| Impact \ Likelihood | Realistic / routine | Possible, needs conditions | Remote / contrived |
|---|---|---|---|
| Severe (data loss, broad unauthorized access, critical outage) | CRITICAL | HIGH | MEDIUM |
| Significant (important workflow broken, integrity or serious security weakness) | HIGH | MEDIUM | LOW |
| Moderate (feature unreliable, material inefficiency, workaround exists) | MEDIUM | LOW | LOW |
| Minor (edge case, localized duplication, small inefficiency) | LOW | LOW | INFO |

The table is a guide; state the reasoning in the finding's Impact field.

### CRITICAL

A credible path exists to severe outcomes such as major data loss, broad unauthorized
access, compromise of a critical system, or complete failure of an essential service.

Response:
- Explain exposure, evidence, and immediate containment options.
- Do not perform a broad or destructive fix without approval.
- Escalate prominently at the top of the final response.

### HIGH

An important workflow is broken, significant data integrity is at risk, or a serious
security/reliability weakness has a realistic exploitation or failure path.

Response:
- Prioritize promptly.
- Apply only a narrow and demonstrably safe correction (and only in `fix` mode).
- Otherwise request review and explain mitigation options.

### MEDIUM

A meaningful feature or workflow is unreliable, or an efficiency/maintenance problem
has material impact but a workaround exists.

Response:
- Recommend a concrete correction.
- Automate only when the intended behavior and scope are unambiguous.

### LOW

A limited edge case, localized duplication, small inefficiency, or minor maintenance
issue has low practical impact.

Response:
- Batch related work where appropriate.
- Avoid broad refactoring solely to remove low-severity findings.

### INFO

A useful observation, documentation gap, or optional future opportunity without a
demonstrated defect.

Response:
- Do not modify automatically.
- Include only when it informs a meaningful future decision.

## Confidence

- `HIGH`: directly demonstrated by source, schema, tests, reproducible behavior, or
  authoritative project documentation.
- `MEDIUM`: strong evidence exists, but runtime behavior or an external contract is
  not fully known.
- `LOW`: plausible concern that requires more information or reproduction.

Low-confidence findings are normally `REVIEW REQUIRED` and must not be fixed
automatically.

## Status

Use exactly these values.

| Status | Meaning |
|---|---|
| `OPEN` | Issue remains and needs action. |
| `FIXED` | Changed during this audit; verification is recorded. |
| `NEEDS APPROVAL` | Requires a user decision before modification. |
| `DEFERRED` | Intentionally postponed by the user or by explicit scope. |
| `ACCEPTED` | User accepted the risk or behavior. Record who/when/why in the finding; optional review date. Do not re-report unless the underlying evidence changes or the review date passes. |
| `FALSE POSITIVE` | Investigated and shown not to be a defect. Keep the reasoning so it is not re-raised. |
| `RESOLVED` | A previously open finding is now verified as corrected (by someone other than this audit run, or by an earlier run). |
| `REGRESSED` | A previously resolved or fixed issue has returned. |
| `OBSOLETE` | The code, feature, or condition no longer exists, so the finding no longer applies. |

## Automatic-fix eligibility

Applies only in `fix` mode. Apply a change automatically only when every condition is
satisfied:

1. The finding is CONFIRMED with HIGH confidence.
2. Intended behavior is clear from requirements, documentation, tests, or established
   behavior.
3. The change is narrow and reversible: it touches only the lines needed, can be
   reverted independently of other fixes, and does not touch a file that already had
   uncommitted changes before the audit.
4. It does not alter business rules, public contracts, permissions, security policy
   semantics, file formats, schemas, or persistent data.
5. Appropriate verification is available and can be run safely (see the side-effect
   rules in `SKILL.md`).

Examples that may qualify, each subject to the five conditions above:
- Correcting a typo in a constant that is only referenced internally and whose
  intended value is stated by documentation, tests, or sibling usages.
- Fixing a local condition that contradicts its own adjacent comment, test, or
  documented rule.
- Removing an import that the language tooling reports unused and that has no side
  effects on import.
- Adding a guard where the same module already applies an established fallback for the
  identical case.

If any condition is not satisfied, leave the code unchanged, set the status to
`NEEDS APPROVAL` (or `OPEN`), and explain why.

## Sensitive findings

Applies to security, privacy, and exposed-secret findings, especially CRITICAL and HIGH.

- Describe the weakness class, location, and remediation. Do not include working exploit
  payloads, tokens, passwords, keys, or personal data. Reference secrets by file and
  key name only.
- Keep reproduction details to the minimum needed for the maintainer to confirm.
- An exposed credential is considered compromised: recommend rotation or revocation in
  addition to removal from the repository. Removing it from the working tree is not
  sufficient if it exists in history.
- State prominently in the final response that the report contains security findings,
  so the user can decide whether the report path is appropriate for the repository's
  visibility.

## Finding ID

Use `AUD-YYYYMMDD-NNN`, for example `AUD-20261124-001`.

- `YYYYMMDD` is the date the finding was first reported.
- `NNN` continues from the highest number already used for that date across existing
  reports, so same-day reruns never reuse an ID.
- Retain the original ID when tracking the same finding in later reports.
