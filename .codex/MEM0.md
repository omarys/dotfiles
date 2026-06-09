# Mem0

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
