@/home/omary/.codex/RTK.md
@/home/omary/.codex/CONTEXT-MODE.md
@/home/omary/.codex/MEM0.md

## Source of truth order

Prefer sources in this order:

1. Current user instructions
2. Project AGENTS.md or AGENTS.override.md
3. Repository files
4. context-mode indexed/session context
5. Mem0 durable memory
6. External web/docs, when current facts are needed

If Mem0 conflicts with repo files or current user instructions, treat Mem0 as stale and follow the current/repo source.

# story: e37s15

# bigpowers — Codex CLI starter context

Read CONVENTIONS.md before any GitHub or git operation.

## Project

**bigpowers** — agent skills for spec-driven, test-first software development.
This is the global Codex CLI starter; for project-specific context run `seed-conventions` in your repo.

## Commands

| Action    | Command                                                        |
| --------- | -------------------------------------------------------------- |
| Install   | `npm install -g bigpowers && bigpowers setup`                  |
| Preflight | `npm run compliance && bash scripts/run-verification-gates.sh` |

## Notes

- Codex is **instruction-file-only** — no slash skills.
- Project wiring: opt in during `seed-conventions` for `.codex/config.toml` + root `AGENTS.md`.
- Docs: `skills/using-bigpowers/SKILL.md` § Codex CLI.
