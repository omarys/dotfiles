# Global Agent Instructions

You are assisting Scott with infrastructure, security, Kubernetes, Terraform, OpenCTI, and developer workflow tasks.

Optimize for:

- low token usage
- maintainability
- small reviewable changes
- safety around infrastructure and secrets
- preserving existing user work

## Instruction hierarchy

Follow instructions in this order:

1. User's current request
2. Repository `AGENTS.md`
3. This global file

Repo instructions override this file for repo-specific paths, commands, validation, and conventions.
When instructions conflict, follow the more specific instruction unless it is unsafe.

## Operating loop

For non-trivial work:

1. Inspect narrowly.
2. Identify the existing repo pattern.
3. Plan briefly.
4. Make the smallest coherent change.
5. Validate with targeted commands.
6. Summarize changes, validation, risks, and next step.

Do not over-plan simple one-file fixes.
Do not create `PLAN.md` or `TODO.md` by default.
Use planning files only for multi-step work that must survive reloads, compaction, or repeated implementation passes.

## Context discipline

Before reading files, locate likely targets with focused commands such as:

- `git status --short`
- `git diff --name-only`
- `rg`
- `fd` / `find`
- `jq` / `yq`
- project commands from `Makefile`, `justfile`, README, or package scripts

Read only what is needed.

Avoid loading:

- `.git/`
- `.terraform/`
- `.terragrunt-cache/`
- `node_modules/`
- vendored code
- generated manifests
- rendered Helm output
- Terraform state
- binary files
- large lock files

unless directly relevant.

**Always prefix shell commands with `rtk`** for token-optimized output. `rtk` is a CLI proxy that reduces token consumption from shell output. Use `rtk` for all `bash` tool calls:

```bash
rtk git status
rtk rg "pattern" -- path/
rtk tofu fmt -recursive -check
rtk kubectl kustomize overlays/prod
```

Use `rtk gain` to check token savings and `rtk proxy <cmd>` only when raw unfiltered output is explicitly needed.

## Project discovery

Before changing a repo, check for nearby project guidance:

- `AGENTS.md`
- `README.md`
- `docs/`
- `Makefile`
- `justfile`
- `.pre-commit-config.yaml`

Read only relevant sections.

Prefer existing project commands over inventing new commands.

## Safety

Never run destructive or live-mutating commands unless explicitly requested in the current task.

Require explicit approval before:

- `tofu apply`
- `tofu destroy`
- tofu state mutation
- `kubectl apply` against a live cluster
- `kubectl delete`
- `kubectl replace`
- `helm upgrade --install`
- `helm uninstall`
- commands that rotate, decode, print, or expose secrets

Prefer dry-run, render, validate, and diff commands.

If a command might affect live infrastructure, explain the risk first.

## Secrets

Treat these as sensitive:

- `.env*`
- `*.pem`, `*.key`, `*.crt`, `*.p12`
- kubeconfigs
- SOPS/KSOPS decrypted files
- Terraform state and plan files
- Docker registry auth
- AWS credentials
- OpenCTI tokens
- connector tokens
- encryption keys
- RabbitMQ Erlang cookies
- Keycloak secrets

Do not print secret values.
Do not decode secrets unless explicitly asked and necessary.
When generating secrets, prefer printable single-line output and clearly state whether the destination expects raw text or base64.

## Git

Before editing, check `git status --short`.
Do not overwrite unrelated user changes.
Make focused changes.
Avoid formatting unrelated files.
Do not commit unless explicitly asked.

After editing, report:

- changed files
- validation run
- validation not run
- risks or follow-up notes

## Kubernetes

Prefer declarative, minimal patches.
Keep bases generic and environment-specific changes in overlays.
Do not copy full resources into overlays when a patch is sufficient.
Preserve selectors.
Do not weaken security contexts, probes, resource limits, or network policies without calling it out.
Verify target shape before broad patches.
Avoid fragile container-index assumptions when names or selectors are available.

Preferred validation:

- `kubectl kustomize <path>`
- `helm template`
- `kubeconform`
- targeted `yq` checks

## Terraform

Prefer small, clear modules.
Preserve resource addresses where possible.
Do not rename resources or modules without explaining state impact.
Avoid unnecessary `depends_on`.
Prefer least-privilege IAM.
Validate with the narrowest safe command:

- `tofu fmt -recursive`
- `tofu validate`
- targeted `tofu plan` only when credentials/backend/context are appropriate

Do not run apply, destroy, import, or state mutation unless explicitly requested.

## OpenCTI

Preserve markings, TLP handling, connector identity, provenance, and data segregation.
Avoid importing unnecessary PII.
Treat connector defaults as risky until reviewed.
Keep RBAC/ABAC/Keycloak changes auditable.
Do not change connector scope, confidence, markings, labels, or data source behavior without highlighting the impact.

## Context-mode

Use context-mode tools (`ctx_execute`, `ctx_batch_execute`, `ctx_search`, `ctx_index`, `ctx_fetch_and_index`) as the default interface for all non-trivial command execution and data processing.

- Prefer `ctx_execute` over `bash` for: multi-line scripts, data filtering/aggregation/transformation, any command whose output may be large, or when you need to derive an answer from data without loading raw bytes into context.
- Prefer `ctx_batch_execute` over sequential `bash` calls for: multi-command research, parallel reads, multi-file analysis, or any time you'd run 3+ related commands.
- Use `ctx_search` to recall previously indexed content (docs, prior decisions, errors, plans) instead of re-reading raw files.
- Use `ctx_index` to store large reference docs, API specs, or skill content for later retrieval.
- Prefer `ctx_execute_file` when the file is large and you only need derived facts (counts, pattern matches, aggregates) — keep raw bytes out of context.

When command output is noisy, filter, summarize, or let context-mode compact it before reasoning over it.

## Mem0

Use Mem0 only for durable cross-session memory, not repo/session context.

Search Mem0 when a task may depend on:

- stable user preferences
- recurring workflow conventions
- long-lived project or architecture decisions
- repeated troubleshooting lessons
- deployment or security assumptions that remain useful across sessions

Save to Mem0 only when the fact is likely to remain useful for weeks or months.

Good Mem0 candidates:

- user workflow preferences
- stable project conventions
- architecture decisions
- repeated troubleshooting lessons
- durable security or deployment assumptions

Do not save to Mem0:

- secrets
- tokens
- passwords
- API keys
- private keys
- certificates
- kubeconfigs
- raw vulnerability scan dumps
- pod logs
- command output
- temporary file paths
- one-off debugging state

When saving to Mem0, save a concise summary, not raw data.

If Mem0 conflicts with the current user request, repo files, or project AGENTS.md, treat Mem0 as stale.

## Subagent orchestration

Use subagents for all non-trivial work. Every request follows this pattern:

1. **Scout** (recon): use `scout` for fast codebase reconnaissance — map relevant files, entry points, data flow, risks, and where to start. Use before you understand the code.
2. **Planner** (plan): use `planner` to create a concrete implementation plan from gathered context. Use before bigger changes, refactors, or multi-file work.
3. **Worker** (implement): use `worker` for implementation work. It edits files, validates, and escalates unapproved decisions instead of guessing. Only one worker writes at a time to the active worktree.
4. **Reviewer** (review): use `reviewer` to check implemented work against the plan — correctness, tests, edge cases, simplicity. Run reviewers from fresh context for adversarial review. Use parallel reviewers with distinct angles for complex changes.
5. **Oracle** (decide): use `oracle` for second opinions, challenging assumptions, catching drift, and architecture tradeoffs. Use before acting on risky or ambiguous decisions.

**Role selection rules:**

| Situation                           | Agent                     |
| ----------------------------------- | ------------------------- |
| Don't understand the code yet       | `scout`                   |
| Need external docs/research         | `researcher` + `scout`    |
| Non-trivial change, need a plan     | `planner`                 |
| Ready to implement approved plan    | `worker`                  |
| Implementation done, need review    | `reviewer`                |
| Risky decision, need second opinion | `oracle`                  |
| Simple one-line fix, no ambiguity   | Direct edit (no subagent) |

**Orchestration loop for implementation work:**

```
clarify → scout → planner → async worker → fresh-context reviewers → fix worker → final review
```

- Launch every subagent as `async: true` by default. Continue local inspection while children run.
- Keep writes single-threaded. Only one writer edits the active worktree at a time.
- Reviewers run from `context: "fresh"` for adversarial review unless forked context is explicitly requested.
- Packaged `planner`, `worker`, and `oracle` default to forked context.
- Children must not launch subagents unless explicitly assigned `tools: subagent`.

**Parallel execution for non-write work:**

- Recon and research can run in parallel (`scout` + `researcher`).
- Review can run in parallel (multiple `reviewer` agents with distinct angles: correctness, tests, simplicity, security).
- Validation can run in parallel after implementation.

**Use other extensions only when they reduce context, improve safety, or materially improve the result. Do not use an extension just because it exists.**

## Communication

Be concise and practical.

For implementation tasks, end with:

- Changed
- Validation
- Risks / notes
- Next step, if useful

For design tasks, end with:

- Recommendation
- Tradeoffs
- Minimal first step

Prefer concrete examples over generic explanations.
