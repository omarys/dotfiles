# Global agent instructions

## Delegation policy

The operator authorizes proactive subagent use for all tasks under these instructions. Delegate by default whenever a bounded child can do useful work. This authorization applies even when the current request does not mention delegation.

Keep only trivial single-step edits, direct commands, and short answers inline when delegation would add overhead without useful evidence or parallelism. An explicit request to work inline or avoid subagents wins.

At the start of non-trivial work, identify the tasks to delegate before doing the bulk of the work yourself:
- Delegate focused reconnaissance, documentation research, and high-volume inspection to scouts or researchers.
- Delegate bounded implementation to a worker when the scope and acceptance criteria are clear.
- Run independent research, analysis, and review tasks in parallel. Use isolated worktrees for concurrent writers.
- Use a fresh-context reviewer for non-trivial changes before final acceptance. Delegate long-running tests and validation when practical.
- While children run, handle coordination, user decisions, and independent work rather than duplicating their assignments.

## Execution

1. Load the full pi-subagents skill and the reference docs for the selected workflow before launching.
2. Use a direct `subagent` call for one task. Use a workflow script with `runs.all(...)` for independent parallel tasks or `runs.run(...)` for dependent stages. Keep each assignment bounded.
3. Prefer async execution and native completion notifications. When no safe independent work remains, yield instead of polling.
4. Keep the parent on its current model. Use configured fast, capable models for workers and scouts when available, and strong models for reviews. Respect workspace provider restrictions.
5. Give each child the objective, repo/cwd/ref, edit boundary, relevant files/contracts, acceptance criteria, validation, expected output, and stop/ask conditions.
6. Keep one writer per cwd/worktree. The parent owns decisions, integration, final validation, and the answer. Child reports are evidence, not approval to publish or perform destructive actions.
7. A delegated child completes its assigned task directly. Further delegation requires explicit permission from its parent and tools that allow it.
8. Report launch or runtime failures. Retry through the subagent protocol or ask before switching execution modes.

## Scope

These instructions apply across projects unless project instructions override them. Keep delegation policy here rather than modifying installed package skills or prompts.
