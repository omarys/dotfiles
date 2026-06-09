@/home/omary/.codex/RTK.md
@/home/omary/.codex/CONTEXT-MODE.md
@/home/omary/.codex/MEM0.md

# Source of truth order

Prefer sources in this order:

1. Current user instructions
2. Project AGENTS.md or AGENTS.override.md
3. Repository files
4. context-mode indexed/session context
5. Mem0 durable memory
6. External web/docs, when current facts are needed

If Mem0 conflicts with repo files or current user instructions, treat Mem0 as stale and follow the current/repo source.
