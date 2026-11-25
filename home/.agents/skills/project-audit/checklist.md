# Project Audit Checklist

Discovery aid, not a form. Adapt to the project and skip inapplicable sections.

## Coverage status

Record one row per **section** in the report's coverage table (`report-template.md`):

| Status | Meaning |
|---|---|
| `PASS` | Inspected, no issue found; cite files/workflows/commands checked. |
| `ISSUE` | One or more findings; list IDs. |
| `NOT APPLICABLE` | Project has nothing of this kind (brief reason). |
| `NOT VERIFIED` | Applicable, not inspected or unverifiable (state what is missing). |

## Sections

1. **Architecture & boundaries**: entry points, module/service ownership, dependency direction, circular deps, conflicting sources of truth, generated/vendored separation.
2. **Correctness & behavior**: critical workflows, edge/empty/invalid inputs, nullability, state transitions, error paths, async/concurrency ordering, idempotency/retries, resource cleanup, time/locale/encoding/serialization.
3. **Integration contracts**: caller/callee type and field agreement, boundary validation, error/status semantics, auth context propagation, cross-environment config, producer/consumer formats, external timeouts/retries/rate limits, backward compatibility.
4. **Data & persistence** *(if applicable)*: schema vs code assumptions, constraints/nullability, parameterized queries, transaction atomicity, concurrency/locking, indexes/query patterns, migration order, backup/retention, sensitive data protection.
5. **Security & privacy**: authn/authz at trust boundaries, untrusted input validation, injection/XSS/CSRF/path/deserialization, secrets hygiene (check tracked files, `.gitignore`, git history without opening restricted files), least privilege, safe defaults, sensitive data in logs/responses.
6. **Performance & resources**: redundant work, N+1 queries, unbounded memory/payloads, cache correctness/invalidation, handle/listener/connection leaks, startup/shutdown, metered-API cost bounds.
7. **Maintainability**: coherent responsibilities, drifted duplicate implementations, misleading abstractions, dead code (verified per `SKILL.md` Step 3), legacy/compat justification, diagnostic quality of errors/logs.
8. **Dependencies & configuration**: unused deps, lockfile consistency, runtime vs dev split, deprecated/vulnerable deps (via lockfile tools or `NOT VERIFIED`), license conflicts, build/deploy config parity, safe reproducible defaults.
9. **Tests & delivery**: critical path & failure-mode coverage, determinism/isolation, static analysis/lint/type checks, reproducible build/package, working README commands.
10. **Operational readiness** *(if applicable)*: health checks, secret-free logs/metrics, failure/restart recovery, resource limits, deploy vs runtime config alignment.
11. **Documentation accuracy**: README/architecture/setup vs actual code, documented flags/env vars/endpoints exist, `.context/` matches code and flags stale docs.
12. **CI/CD pipeline** *(conditional)*: least-privilege tokens, pinned third-party actions/images, safe secret injection, fork/PR isolation, parity with documented build/test/release.
13. **IaC & containers** *(conditional)*: non-root images, minimal exposed ports/volumes, pinned base images, resource limits/probes/restart policies, IAM/network least privilege, config parity.
14. **User-facing interfaces** *(conditional)*: basic accessibility (labels, keyboard, contrast), localization (if multi-locale), error/empty states, client/server validation agreement.
