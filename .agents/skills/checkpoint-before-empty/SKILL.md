---
name: checkpoint-before-empty
description: Context budget guardrail. Use when the context window or token budget is nearly exhausted (roughly 20% usage remaining or less) — also before starting new work on a task, or after long tool-heavy stretches — stop work, write a checkpoint with the handoff skill, and tell the user where to resume.
---

Keep every session resumable. The checkpoint discipline: when context usage hits ~20% remaining — enough to finish current work, never enough to start new work — stop and record where you left off.

Steps:

1. **Assess.** Estimate context usage (input + output consumed across the session, plus any session token budget). Re-check at natural pauses: after tool calls, before starting new work on the task. The threshold is hit when ~20% or less remains.

2. **Stop.** At the threshold, stop: no new work, no state-changing tool calls, no "one more thing". Leave the workspace as-is.

3. **Checkpoint.** Invoke the `handoff` skill, passing an argument describing what the next session will focus on. The handoff document it writes is the resume point: progress so far, what is incomplete, and the next steps, including a suggested skills section. The handoff skill saves to the OS temp dir; move the document it created into the current project's `docs/` directory (create it if missing) so the checkpoint survives a restart. Only treat the handoff as successful once the document is in place there — if the handoff skill fails or the move cannot be completed, report the failure rather than claiming a checkpoint exists.

4. **Report.** Tell the user the final checkpoint path (the copy in `docs/`), what was stopped where, and the first step the next session should take to resume.

Scope: every agent process — main session, subagents, background runs. Each hits the threshold on its own clock: a subagent that runs low stops, writes its own checkpoint, and hands the path back to its parent instead of truncating mid-work.