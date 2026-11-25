# Project Audit Checklist

A discovery aid, not a form to fill in. Adapt it to the project and skip what does not
apply.

## How to record coverage

Record one row per **section** in the report's coverage table (see `report-template.md`),
not one mark per item:

| Status | Meaning |
|---|---|
| `PASS` | Applicable items were inspected and no issue was found. Name what was examined (files, workflows, commands) as evidence. "Looks fine" is not evidence. |
| `ISSUE` | One or more findings; list their IDs. |
| `NOT APPLICABLE` | The project has nothing of this kind. Say why in a few words. |
| `NOT VERIFIED` | Applicable, but not inspected or not verifiable (time, access, tooling, network). Say what is missing. |

Sections 12-14 are conditional modules: use them only when the project contains that
kind of artifact.

## 1. Project understanding and architecture

- Project purpose and important user/business workflows are understood.
- Entry points, runtime components, and deployment units are identified.
- Module, package, and service responsibilities are reasonably clear.
- Dependencies flow in a coherent direction.
- Circular dependencies or initialization-order hazards are absent or understood.
- Shared code has clear ownership and scope.
- There are no conflicting sources of truth.
- Architecture and implementation documentation are reasonably aligned.
- Existing conventions are followed consistently.
- Generated, vendored, archived, and external code is distinguished from maintained source.

## 2. Correctness and behavior

- Critical workflows behave as documented or intended.
- Boundary conditions and empty inputs are handled.
- Invalid input is rejected or handled safely.
- Null, missing, default, and optional values are treated consistently.
- State transitions are valid and recoverable.
- Error paths are handled as deliberately as success paths.
- Async, concurrent, and parallel operations handle ordering and failure correctly.
- Retries and duplicate requests do not cause unintended side effects.
- Resource cleanup occurs on success, failure, and cancellation.
- Time, locale, encoding, precision, and serialization assumptions are explicit.
- Behavior is consistent across supported platforms and environments.

## 3. Component and integration contracts

- Callers and implementations agree on names, types, and required fields.
- Public interfaces and consumers are compatible.
- Data passed between components is validated at appropriate boundaries.
- Error formats and status semantics are consistent.
- Authentication and identity context are propagated safely.
- Configuration values agree across components and environments.
- File, message, event, and data formats match their producers and consumers.
- External integrations handle timeouts, failures, rate limits, and unexpected responses.
- Versioning and backward compatibility are considered where required.

## 4. Data and persistence (if applicable)

- Application assumptions match actual stored data and schemas.
- Keys, relationships, constraints, and nullability are intentional.
- Queries and data access are parameterized and validated.
- Transactions cover operations that must be atomic.
- Concurrency and consistency requirements are handled.
- Indexes and access patterns are appropriate for observed workloads.
- Migrations and schema evolution are ordered and reviewed.
- Backup, restore, retention, and recovery expectations are documented.
- Sensitive data is protected and retained only as needed.

## 5. Security and privacy

- Authentication is implemented at the correct trust boundary.
- Authorization is checked for each protected operation.
- Untrusted input is validated and safely handled.
- Injection, cross-site, request-forgery, path, and deserialization risks are considered where relevant.
- Secrets are not committed, exposed, or logged. Check tracked files, ignore rules, and
  version-control history; do not open files the project marks as restricted (see
  `SKILL.md`, principle 9).
- Sensitive data is excluded from unnecessary responses and diagnostics.
- Permissions follow least privilege.
- File access, uploads, and downloads are constrained where applicable.
- Network interfaces and service exposure match deployment needs.
- Security-sensitive defaults are safe.
- Personal data handling matches any stated policy or regulatory requirement.
- Dependency and supply-chain risks are assessed proportionately.

## 6. Performance and resource use

- Expensive work is not repeated unnecessarily.
- Data access avoids obvious N+1 or excessive round-trip patterns.
- Large inputs and outputs are bounded or streamed where appropriate.
- Caching is correct and invalidation is understood.
- Memory, CPU, storage, network, and connection use are reasonable.
- Resources, handles, listeners, and background tasks are released.
- Startup and shutdown behavior is reliable.
- Usage-based costs (metered APIs, storage, egress) are bounded where relevant.
- Performance claims are based on measurements or a clear, defensible mechanism.
- Optimization does not compromise correctness or maintainability.

## 7. Maintainability and code health

- Names and abstractions communicate intent.
- Functions and modules have coherent responsibilities.
- Similar behavior is not implemented inconsistently in multiple places.
- Abstractions reduce complexity rather than merely relocating it.
- Comments and documentation are accurate and useful.
- Dead code and unused assets are verified using the Step 4 rules in `SKILL.md`.
- Compatibility layers and legacy paths have a clear purpose.
- Error messages and logs support diagnosis.
- Technical debt is recorded with impact and context.
- Style differences are not misreported as defects.

## 8. Dependencies and configuration

- Dependencies are actually needed by maintained code.
- Direct and transitive dependencies are understood where relevant.
- Versions and lockfiles are consistent with the package manager or build system.
- Runtime and development-only dependencies are distinguished.
- Deprecated or unsupported APIs and dependencies are identified.
- Known vulnerabilities in locked versions are checked, or `NOT VERIFIED` is recorded.
- Licenses are compatible with the project's stated policy.
- Build and deployment configurations agree.
- Environment-specific settings are explicit.
- Defaults are safe and reproducible.
- Upgrades are treated as separate, reviewed changes.

## 9. Tests and delivery

- Critical behavior has meaningful automated tests.
- Tests cover important failure and boundary cases.
- Tests are deterministic and sufficiently isolated.
- Integration boundaries are tested where practical.
- Test fixtures do not conceal real behavior.
- Static analysis, formatting, and type checks are available where appropriate.
- Build, packaging, and deployment checks are reproducible.
- Release and rollback procedures are understood where relevant.
- Commands documented in the README or setup guide actually work.

## 10. Operational readiness (if applicable)

- Health checks and useful diagnostics exist.
- Logs and metrics support troubleshooting without leaking secrets.
- Failure, restart, and recovery behavior is understood.
- Backups and restore procedures are tested or their status is known.
- Resource limits and capacity assumptions are reasonable.
- Deployment configuration and runtime configuration are aligned.
- Operational documentation is current enough to use.

## 11. Documentation accuracy

- README, setup, and architecture documents describe what the code actually does.
- Documented configuration keys, commands, endpoints, and environment variables exist.
- Project context records (for example `.context/`) match the code they describe, and
  stale ones are flagged.

## 12. CI/CD and build pipeline (conditional)

- Pipeline permissions and tokens follow least privilege.
- Third-party actions, images, and scripts are pinned or otherwise controlled.
- Secrets are injected safely and not echoed into logs or artifacts.
- Pull-request or fork workflows cannot reach privileged secrets or deployments.
- Pipeline steps match the documented build, test, and release process.

## 13. Infrastructure as code and containers (conditional)

- Images and manifests do not run as root or expose ports and volumes unnecessarily.
- Base images and tags are pinned and maintained.
- Resource limits, health probes, and restart policies are defined where expected.
- Infrastructure definitions agree with application configuration.
- Network exposure, storage access, and IAM permissions follow least privilege.

## 14. User-facing interfaces (conditional)

- Accessibility basics hold for the supported interfaces (labels, keyboard use, contrast).
- User-visible text is localizable where the project supports multiple locales.
- Error and empty states are handled and understandable.
- Client-side validation agrees with server-side validation.
