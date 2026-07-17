# Context-mode

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
