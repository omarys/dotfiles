@/home/omary/.codex/RTK.md
@/home/omary/.codex/CONTEXT-MODE.md
@/home/omary/.codex/REKAL.md

## Source of truth order

Prefer sources in this order:

1. Current user instructions
2. Project AGENTS.md or AGENTS.override.md
3. Repository files
4. `context-mode` indexed/session context
5. `rekal` durable memory
6. External web/docs, when current facts are needed

If `rekal` conflicts with repo files or current user instructions, treat Rekal
as stale and follow the current or repository source.

## Notes

- Codex is **instruction-file-only** — no slash skills.

## Model selection for delegated work

When delegation is authorized by the user or applicable instructions, use
`simple_worker` for bounded tasks with clear inputs and completion criteria,
such as mechanical edits, field extraction, targeted searches, and routine
verification. Give it the relevant files, expected output, and validation step.

Keep planning, ambiguous debugging, architecture decisions, and correctness or
security reviews on Sol. General sub-agents inherit the parent's model and
reasoning effort; use high effort for deeper investigations. Use `reviewer`
for delegated correctness, regression, and security reviews on Sol with high effort.
Use `researcher` on Terra for source gathering, documentation checks, factual
extraction, and visual evidence. Keep complex synthesis and final conclusions
on Sol. Give the researcher a specific question and require source references.

Review the worker's actual changes and validation before accepting its result.
If a simple task reveals ambiguity or requires design decisions, return it to
Sol with the evidence collected so far. These model preferences do not by
themselves authorize spawning sub-agents.
