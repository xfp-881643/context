# Context Management Rules

## 1. Purpose

Maintain persistent, project-specific knowledge in `.context/`.

This system must:
- Work across different AI agents and sessions.
- Use human-readable Markdown files.
- Preserve project history and reusable knowledge.
- Reduce repeated investigations and mistakes.
- Keep context synchronized with the actual source code.

## 2. Context Loading

At the beginning of every meaningful task:

1. Read INDEX.md.
2. Read CURRENT.md.
3. Read PROJECT.md and DEVELOPMENT.md when relevant.
4. Identify task-related keywords, modules, and technical dependencies.
5. Search and load only relevant context documents.
6. Review previous related tasks and unresolved issues.
7. Verify historical information against the current source code when necessary.

Do not load every historical document unnecessarily.

## 3. Context Collection During Work

Do not wait until task completion to remember everything.

Record important discoveries as they happen.

Preserve:
- Architectural decisions and their reasons.
- Technical constraints and implementation details.
- Verified solutions.
- Failed approaches and their causes.
- Important source code locations.
- Dependencies and side effects.
- User instructions that affect future development.
- Unresolved issues and possible next steps.

Do not record:
- Every command executed.
- Routine implementation details without future value.
- Unverified assumptions as facts.
- Temporary debugging output.
- Credentials, API keys, passwords, or tokens.

## 4. Task History

After every meaningful task, create or update:

`tasks/YYYY-MM-DD-task-name.md`

Each task record should contain:

- Objective
- Background and related context
- Implementation summary
- Modified files
- Important technical decisions
- Problems encountered
- Failed approaches
- Test and verification results
- Remaining issues
- Related documents

Preserve actual execution results. Never claim that tests passed unless they were executed successfully.

## 5. Current State Management

CURRENT.md represents the latest known project and task state.

Update it when:
- A task starts or changes direction.
- An important implementation milestone is completed.
- An issue blocks further progress.
- A task is completed.
- The next action becomes clear.

Maintain:
- Current focus
- Work in progress
- Recently completed work
- Unresolved issues
- Next recommended actions
- Relevant context document links

Do not use CURRENT.md as a replacement for historical task records.

When no work is in progress, explicitly indicate that status.

## 6. Knowledge Classification

Classify information before saving it.

### PROJECT.md
Project purpose, scope, architecture summary, and technology stack.

### DEVELOPMENT.md
Development environment, build commands, coding conventions, and project constraints.

### architecture/
System design, component relationships, and technical architecture.

### architecture/decisions/
Individual Architecture Decision Records (ADR).

Record:
- Context
- Decision
- Alternatives considered
- Reasons
- Consequences
- Status

Do not silently rewrite historical decisions. Create a new ADR when an important decision changes.

### modules/
Module-specific implementation details, responsibilities, interfaces, and dependencies.

### tasks/
Chronological work history.

### problems/
Errors, root causes, verified solutions, and known workarounds.

### knowledge/
Reusable patterns, lessons, and technical knowledge learned across multiple tasks.

### archive/
Obsolete or superseded context that may still be useful for historical reference.

## 7. Knowledge Promotion

Not all task history deserves to become long-term knowledge.

Promote information when:
- It is likely to be useful in future tasks.
- It explains a non-obvious implementation decision.
- It prevents a previously encountered mistake.
- It provides a verified solution to a recurring problem.
- It describes an important project constraint.
- It has been confirmed across multiple tasks.

Keep one-time implementation details in task history.

Avoid duplicating entire task records in long-term documents. Use relative links.

## 8. Problem and Failure Tracking

For each important problem, record:

- Symptoms
- Environment
- Root cause
- Investigation process
- Attempted solutions
- Successful solution
- Verification
- Related task links

Clearly classify each approach:

- VERIFIED: confirmed to work.
- FAILED: confirmed not to work.
- UNVERIFIED: not sufficiently tested.
- OBSOLETE: no longer applicable.

Never promote an unverified workaround as an established solution.

## 9. Knowledge Retrieval

When searching context:

1. Start from INDEX.md.
2. Search by topic, module, error message, or relevant file path.
3. Load the smallest relevant set of documents.
4. Follow related links when necessary.
5. Compare historical information with current source code.
6. Prefer verified and recent information when resolving conflicts.

Historical context is guidance, not an unquestionable source of truth.

## 10. Context Quality and Maintenance

Periodically identify:

- Duplicate information.
- Contradictory instructions.
- Outdated technical information.
- Broken document links.
- Missing INDEX entries.
- Completed issues still marked as unresolved.
- Knowledge that should be promoted from task history.
- Obsolete documents suitable for archiving.

Never delete valuable historical information without preserving its relevance.

Keep INDEX.md concise and useful.

## 11. Source of Truth

When information conflicts, use this priority:

1. Current source code and actual configuration.
2. Verified execution and test results.
3. Current explicit user instructions.
4. Current architecture and development documents.
5. Historical task records.
6. Unverified assumptions.

Do not blindly apply historical solutions to changed code or environments.

## 12. Task Completion Protocol

Before considering a meaningful task complete:

1. Review actual changes.
2. Verify tests and execution results.
3. Create or update the task history.
4. Update CURRENT.md.
5. Promote reusable knowledge.
6. Update problem, module, or architecture documents as necessary.
7. Synchronize INDEX.md.
8. Check relative links and consistency.
9. Report updated context files to the user.

If the task is incomplete, record its actual status and next action.

Never silently skip context maintenance.

## 13. Human Readability and Version Control

- Use clear Markdown.
- Use descriptive filenames.
- Prefer concise technical explanations.
- Include source paths and relevant identifiers.
- Use relative links.
- Keep records understandable without an AI agent.
- Store context in Git with the project.
- Never commit secrets or sensitive environment data.