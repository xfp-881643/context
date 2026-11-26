# Module Boundaries & Architecture

## Layered Mental Model

- **Composition roots** (apps, hosts, runners): wire modules together; keep orchestration thin.
- **Modules / bounded contexts**: cohesive units of behavior and data ownership, understandable and testable on their own.
- **Shared kernels** (use sparingly): only stable, truly cross-cutting concepts—never a grab-bag of "everything everyone needs."

Physical layout (monorepo, multirepo, packages, folders) is a **delivery choice**, not the definition of modularity.

## Principles

| # | Principle | Rule for Agents |
|---|---|---|
| 1 | **Well-defined boundaries** | Keep a small, intentional public surface; everything else is internal. Preserve or shrink exports—never widen them for convenience. Repositories, internal services, and persistence models are not public API. |
| 2 | **Composability** | Modules work alone or combined without hidden assumptions like "only works if module B is present" (express those as optional plugin/port contracts). |
| 3 | **Independence** | No hidden shared mutable state or ambient globals across boundaries. Pass dependencies explicitly so modules are testable with fakes at their ports. |
| 4 | **Explicit communication** | Cross-module calls use documented contracts (APIs, events, versioned schemas)—never import another module's internal persistence DTOs. |
| 5 | **Replaceability** | Express boundary dependencies through narrow interfaces/protocols ("clock", "notifier", "payment gateway") so implementations can swap without leaking vendor types inward. |
| 6 | **State isolation** | Each module owns its authoritative store and naming. Treat reach-through persistence (reading/writing another module's tables/buckets/docs) as a design defect unless explicitly contracted. |

**Principle 6 (State isolation)** is the most frequent source of "works until it doesn't" integration bugs.

## Typical Violations

1. **Colliding concepts** — same name/schema for different meanings across modules, or duplicated global definitions that diverge.
2. **Centralized data ownership** — one persistence layer registering and exposing all stores for all modules.
3. **Logic at the edge** — business rules inside HTTP/UI/CLI adapters, or adapters calling persistence directly, instead of domain/application layers.
4. **Unscoped transactions** — writes spanning boundaries without clear transaction ownership (saga, outbox, or single-owner rule).
5. **Fat facades** — public entry points embedding querying, mapping, or policy instead of delegating.

## Creating a Bounded Context

Use when introducing a new cohesive domain area or extracting one:

1. **Scope & language** — Name the context; list core nouns/verbs (ubiquitous language). Reject vague names that collide with other contexts.
2. **Responsibilities** — State what decisions happen *only* here and what is explicitly *out* of scope.
3. **State ownership** — Identify authoritative facts and their conceptual store.
4. **Public contract** — Define operations/events other contexts may use; plan intentional evolution.
5. **Integrations** — For each neighbor, specify sync call, async message, shared read model, or batch sync, plus consistency (immediate vs eventual) and failure behavior.
6. **Invariants & lifecycles** — State what must always hold inside the boundary and what starts/completes lifecycles.

Prefer minimal contracts, explicit timeouts/retries/idempotency for async flows, and zero "temporary" direct store shortcuts.

## When to Split or Merge

**Default:** fewer boundaries until real pain appears. Splitting adds coordination, versioning, and operational cost.

### Six-Criteria Test (favor split when several hold)

| # | Criterion | Question |
|---|---|---|
| 1 | **Language** | Do sub-areas use different vocabulary or conflicting meanings for the same word? |
| 2 | **Rate of change** | Do parts change on different cadences or for unrelated reasons? |
| 3 | **Scale / SLO** | Do parts need different throughput, latency, or availability targets? |
| 4 | **Consistency** | Do they require separate transaction boundaries? |
| 5 | **Ownership** | Would clearer team/code ownership lines reduce conflict and review churn? |
| 6 | **Pain signal** | Is there observable integration pain: ripple effects, fear of change, unclear bug ownership? |

**Do not split (or merge back) when:**
- The only motivation is "files got big" or folder aesthetics.
- Boundaries are artificial (same language, same lifecycle, constant chatty cross-calls).
- Splitting duplicates logic/data without a clear single-writer rule.
- The team cannot yet own the extra contracts, versioning, and operations.

## Sub-Units Inside a Bounded Context

When one outer boundary is right but contains named sub-areas:
- Each sub-unit owns its slice of model and persistence—avoid one monolithic "registers everything" persistence layer inside the context.
- Prefer internal application APIs or thin internal facades over peers importing each other's storage types.
- For async flows, pass enriched payloads instead of chatting back across sub-units.
