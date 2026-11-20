# GEMINI usage guidelines

## RTK shell output policy

Always prefix shell commands with `rtk` when using normal shell execution.

Examples:

```bash
rtk git status --short
rtk rg "pattern" -- path/
rtk kubectl kustomize overlays/prod
rtk tofu fmt -recursive -check
```

## context-mode — MANDATORY routing rules

context-mode MCP tools available. Rules protect context window from flooding. One unrouted command dumps 56 KB into context. Antigravity has NO hooks — these instructions are ONLY enforcement. Follow strictly.

## Think in Code — MANDATORY

Analyze/count/filter/compare/search/parse/transform data: **write code** via `mcp__context-mode__ctx_execute(language, code)`, `console.log()` only the answer. Do NOT read raw data into context. PROGRAM the analysis, not COMPUTE it. Pure JavaScript — Node.js built-ins only (`fs`, `path`, `child_process`). `try/catch`, handle `null`/`undefined`. One script replaces ten tool calls.

## BLOCKED — do NOT use

### curl / wget — FORBIDDEN

Do NOT use `curl`/`wget` via `run_command`. Dumps raw HTTP into context.
Use: `mcp__context-mode__ctx_fetch_and_index(url, source)` or `mcp__context-mode__ctx_execute(language: "javascript", code: "const r = await fetch(...)")`

### Inline HTTP — FORBIDDEN

No `node -e "fetch(..."`, `python -c "requests.get(..."` via `run_command`. Bypasses sandbox.
Use: `mcp__context-mode__ctx_execute(language, code)` — only stdout enters context

### Direct web fetching — FORBIDDEN

No `read_url_content` for large pages. Raw HTML can exceed 100 KB.
Use: `mcp__context-mode__ctx_fetch_and_index(url, source)` then `mcp__context-mode__ctx_search(queries)`

## REDIRECTED — use sandbox

### Shell (>20 lines output)

`run_command` ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`.
Otherwise: `mcp__context-mode__ctx_batch_execute(commands, queries)` or `mcp__context-mode__ctx_execute(language: "shell", code: "...")`

### File reading (for analysis)

Reading to **edit** → `view_file`/`replace_file_content` correct. Reading to **analyze/explore/summarize** → `mcp__context-mode__ctx_execute_file(path, language, code)`.

### Search (large results)

Use `mcp__context-mode__ctx_execute(language: "shell", code: "grep ...")` in sandbox.

## Tool selection

1. **GATHER**: `mcp__context-mode__ctx_batch_execute(commands, queries)` — runs all commands, auto-indexes, returns search. ONE call replaces 30+. Each command: `{label: "header", command: "..."}`.
2. **FOLLOW-UP**: `mcp__context-mode__ctx_search(queries: ["q1", "q2", ...])` — all questions as array, ONE call.
3. **PROCESSING**: `mcp__context-mode__ctx_execute(language, code)` | `mcp__context-mode__ctx_execute_file(path, language, code)` — sandbox, only stdout enters context.
4. **WEB**: `mcp__context-mode__ctx_fetch_and_index(url, source)` then `mcp__context-mode__ctx_search(queries)` — raw HTML never enters context.
5. **INDEX**: `mcp__context-mode__ctx_index(content, source)` — store in FTS5 for later search.

## Parallel I/O batches

For multi-URL fetches or multi-API calls, **always** include `concurrency: N` (1-8):

- `mcp__context-mode__ctx_batch_execute(commands: [3+ network commands], concurrency: 5)` — gh, curl, dig, docker inspect, multi-region cloud queries
- `mcp__context-mode__ctx_fetch_and_index(requests: [{url, source}, ...], concurrency: 5)` — multi-URL batch fetch

**Use concurrency 4-8** for I/O-bound work (network calls, API queries). **Keep concurrency 1** for CPU-bound (npm test, build, lint) or commands sharing state (ports, lock files, same-repo writes).

GitHub API rate-limit: cap at 4 for `gh` calls.

## Output

Write artifacts to FILES — never inline. Return: file path + 1-line description.
Descriptive source labels for `search(source: "label")`.

## ctx commands

| Command       | Action                                                                        |
| ------------- | ----------------------------------------------------------------------------- |
| `ctx stats`   | Call `stats` MCP tool, display full output verbatim                           |
| `ctx doctor`  | Call `doctor` MCP tool, run returned shell command, display as checklist      |
| `ctx upgrade` | Call `upgrade` MCP tool, run returned shell command, display as checklist     |
| `ctx purge`   | Call `purge` MCP tool with confirm: true. Warns before wiping knowledge base. |

After /clear or /compact: knowledge base and session stats preserved. Use `ctx purge` to start fresh.

## Context and memory policy

Use repository files and project instructions as the source of truth. Use context-mode and rekal as supporting context sources, not as replacements for repo files.

### Context-mode

Use context-mode as the primary tool for repo/session context.

Prefer context-mode when:

- locating relevant files before broad reads
- searching prior indexed/session context
- analyzing large command output, logs, JSON, YAML, Terraform plans, rendered manifests, or generated files
- preserving useful task context across long sessions
- deriving facts from data without loading raw output into the conversation

When output may be large or noisy, use context-mode tools to filter, summarize, search, or index it before reasoning over it.

Use context-mode for Kubernetes, Terraform, OpenCTI, Docker, IAM, and CI/security finding work when repo context or large output is involved.

Do not paste large raw logs, manifests, scan results, Terraform plans, or generated files into the conversation when context-mode can process them.

### rekal

Use rekal only for durable cross-session memory (`~/.rekal/memory.db`).

Call `memory_build_context` when the task may depend on:

- stable user preferences
- recurring workflow conventions
- long-lived project or architecture decisions
- repeated troubleshooting lessons
- durable deployment or security assumptions

Save with `memory_store` only when the fact is likely to remain useful for weeks or months.

Good rekal candidates:

- user workflow preferences
- stable project conventions
- durable architecture decisions
- repeated troubleshooting lessons
- long-lived deployment/security assumptions

Do not save to rekal:

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

When saving to rekal, save a concise summary, not raw data. Pass `replaces=<old_id>` when updating existing knowledge to prevent duplicate entries.

### Source precedence

Prefer sources in this order:

1. Current user request
2. Project instruction files
3. Repository files
4. context-mode indexed/session context
5. rekal durable memory
6. External docs or web sources when freshness is required

If rekal conflicts with the current user request, project instructions, or repository files, treat rekal as stale.

## Model Selection Policy: Planning vs Implementation

- **Planning Mode (`/plan` / Architecture / Analysis)**:
  - Formulate all plans, system design, and requirements discovery using **Gemini 4 Argon** (`gemini-4-argon-medium`).
  - When delegating planning, security review, or complex exploration tasks to subagents, explicitly specify `Model: 'pro'`.
  - When presenting an implementation plan artifact for approval, include a quick note reminding the user to switch the session model to **Gemini 4 Neon** (via the UI model selector or `/model gemini-4-neon-medium`) before clicking Proceed / starting execution.
- **Implementation Mode (Execution / Editing / Testing)**:
  - Execute all code generation, refactoring, bug fixes, file edits, and verification using **Gemini 4 Neon** (`gemini-4-neon-medium`).
  - When delegating routine execution or repetitive coding subtasks to subagents, specify `Model: 'flash'` or `'flash_lite'`.

## Subagent & Swarm Delegation Policy

To minimize token burn when the primary session runs on Gemini 4 Neon, delegate scoped workloads to the right orchestration and execution tools:

- **Tool Selection (Subagent vs Swarm vs Workflow)**:
  - **Single scoped task** → `invoke_subagent` with the matching specialized agent (`fast-recon`, `iac-k8s-worker`, `build-test-worker`, `aws-env-worker`, `deep-audit`, `sec-hardening-audit`).
  - **Parallel independent work or author + verifier pipelines** → `swarm` (`workspace: "share"` for parallel editors/builders, `inherit` for readers/verifiers; apply the **Swarm Model Routing Policy** below).
  - **Programmatic fan-out / staged aggregation** → `run_workflow`.
- **Swarm Model Routing Policy** *(standing user override for `/swarm`)*:
  - **Simple / mechanical / read-only tasks** (recon, log/diff filtering, formatting/validation, boilerplate, `narrator`/`monitor`) → pass `model: "gemini-3.8-flash-medium"` (or `"gemini-4-neon-low"`).
  - **Standard implementation & verification** → pass `model: "gemini-4-neon-medium"` (or omit `model` to inherit when the coordinator is on Neon).
  - **Complex / high-risk tasks** (architecture, deep security/root-cause audits, cross-cutting refactors) → decompose into smaller scoped tasks first; if a single worker still needs deeper reasoning, pass `model: "gemini-4-neon-high"` or `"gemini-4-argon-medium"`.
- **Broad Reconnaissance & Log/Cluster Inspection (`fast-recon` - `flash` tier)**:
  - Delegate broad file searches, log parsing, cluster inspection, and noisy CLI checks (`kubectl`, `tofu`, `docker`, `git diff`) to `fast-recon` instead of pulling raw outputs into the primary context.
- **Isolated IaC & Kubernetes Manifest Edits (`iac-k8s-worker` - `flash` tier)**:
  - Delegate isolated Terraform/OpenTofu boilerplate, manifest rendering, and formatting/validation loops (`tofu fmt`, `tofu validate`, `tofu plan`, `kustomize`, `helm template`) to `iac-k8s-worker`.
- **Deep Security Audits & Multi-File Architecture (`deep-audit` - `inherit` tier)**:
  - Offload complex multi-file refactoring, container hardening audits, IAM/security policy analysis, and root-cause debugging to `deep-audit` when context isolation will prevent main-thread bloat.
- **Delegation Protocol**:
  - Pass narrow, self-contained prompts to subagents and swarm workers.
  - Subagents must pipe noisy CLI commands through `rtk` (or `context-mode` / compact filters) and are strictly forbidden from returning uncompacted raw output dumps into the parent context.

## Ultra 5x Delegation & Context Hygiene Policy

Optimized for Google AI Ultra 5x multi-model sessions (alternating between Gemini 4 Argon, Carbon, Hydrogen, and Neon):

- **Flash Tier Delegation**:
  - Keep all broad file discovery, `tofu`/`helm` validation, `cargo`/`dotnet` test loops, and AWS state checks off the primary thread. Delegate to the specialized `flash` workers:
    - `fast-recon`: Read-only codebase and log reconnaissance.
    - `iac-k8s-worker`: OpenTofu/Terraform formatting and validation, Helm/Kustomize manifest rendering, and YAML edits (strictly non-mutating / no `tofu apply` or mutating `kubectl apply`).
    - `build-test-worker`: Compilation, linting, and test loops (`cargo check`/`test`, `dotnet build`/`test`, container builds).
    - `aws-env-worker`: Read-only AWS commercial and GovCloud (`us-gov-west-1`) state queries honoring active `AWS_PROFILE` and `AWS_REGION` from `direnv`.
- **Inherit Tier Delegation (Isolated Reasoning Context)**:
  - Delegate isolated security, container hardening, Keycloak ICAM, and network policy compliance reviews to `sec-hardening-audit` (`inherit` tier) to ensure thorough multi-file audits never bloat the main conversation context.
- **Context Hygiene & Compaction Standard**:
  - Every subagent prompt must be tightly scoped and self-contained.
  - Every subagent response must be pre-compacted, high-signal, and under ~400 words unless full file diffs are explicitly requested.

