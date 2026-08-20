# Instructions

## Source of Truth Order

Prefer sources in this order:

1. Current user instructions
2. Project AGENTS.md or AGENTS.override.md
3. Repository files
4. context-mode indexed/session context
5. Mem0 durable memory
6. External web/docs, when current facts are needed

If Mem0 conflicts with repo files or current user instructions, treat Mem0 as stale and follow the current/repo source.

## Context-mode

Use context-mode as the primary repo/session context tool.

Prefer context-mode when:

- locating relevant files before broad filesystem reads
- searching prior session decisions, summaries, or indexed content
- handling large command output, logs, JSON, YAML, Terraform plans, Kubernetes manifests, or generated files
- preserving useful session state before compaction
- recovering context after compaction or a resumed session

Do not paste large logs or manifests directly into the prompt when a context-mode tool can index, summarize, or search them.

Before reading many files manually, first ask context-mode to identify the likely relevant files or prior context.

For Kubernetes, Terraform, OpenCTI, Docker, IAM, and CI findings work:

- use context-mode for repo-aware search and large-output handling
- keep raw scan output, pod logs, Terraform plans, and generated manifests out of long-term memory unless explicitly asked

## Mem0

Use Mem0 only for durable cross-session facts.

Search Mem0 at the start of work when the task may depend on:

- user preferences
- stable project architecture decisions
- recurring repo conventions
- long-lived deployment/security assumptions
- prior decisions that are not obvious from the current repo files

Store a Mem0 memory only when the fact is likely to remain useful for weeks or months.

Good Mem0 candidates:

- user workflow preferences
- stable project conventions
- architecture decisions
- repeated troubleshooting lessons
- durable security or deployment assumptions

Do not store in Mem0:

- secrets, tokens, passwords, API keys, private keys, certificates, cookies, or kubeconfigs
- raw vulnerability scan dumps
- raw pod logs or command output
- one-off debugging state
- temporary file paths
- sensitive operational details that are not needed later

When saving to Mem0, write a concise summary, not raw data.

## RTK - Rust Token Killer (Codex CLI)

**Usage**: Token-optimized CLI proxy for shell commands.

### Rule

Always prefix shell commands with `rtk`.

Examples:

```bash
rtk git status
rtk cargo test
rtk npm run build
rtk pytest -q
```

### Meta Commands

```bash
rtk gain            # Token savings analytics
rtk gain --history  # Recent command savings history
rtk proxy <cmd>     # Run raw command without filtering
```

### Verification

```bash
rtk --version
rtk gain
which rtk
```
