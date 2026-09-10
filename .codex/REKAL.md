# Rekal

Rekal stores durable knowledge that remains useful across sessions. Current
user instructions, project instructions, and repository files take precedence
over Rekal memories.

## Recall memories

Relevant memories are injected automatically under `## rekal memory`. Use that
injected context when it applies.

Call `memory_build_context` only when the injected block is absent and the task
depends on prior knowledge. Use `project` for repository-specific recall. Leave
`project` unset only for user-wide preferences or conventions.

## Store memories

Call `memory_store` when knowledge is likely to remain useful for weeks or
months and is expensive to rediscover.

Store one of these forms:

- **Fact:** One or two self-contained sentences with the important technical
  terms, values, and causality.
- **Brief:** One 350–500 word subsystem summary. Start with a headline that has
  8–12 search keywords. End with a `Deviations:` section and add the `brief`
  tag.

Set `project` for repository-specific knowledge. Keep user-wide workflow
preferences unscoped when they apply across projects.

Every claim about code must include an anchor verified during the current
session, in the form `(relative/path.py:LINE symbol)`. Repository files remain
the authority; an unverified code claim is not durable knowledge.

To correct an existing memory, call `memory_store` with
`replaces=<existing-memory-id>`. Do not create a second memory that conflicts
with the first.

Good candidates include:

- stable user workflow preferences;
- architecture decisions whose rationale is not obvious from the repository;
- recurring repository conventions that are expensive to find;
- repeated troubleshooting lessons with a durable cause and resolution;
- long-lived deployment or security assumptions needed across sessions.

## Delete memories

Call `memory_delete` with the exact memory ID when a memory is no longer true
and no replacement is needed.

## Exclude memories

Do not store:

- secrets, tokens, passwords, API keys, private keys, certificates, cookies,
  or kubeconfigs;
- sensitive operational details that are not required later;
- raw vulnerability scans, pod logs, command output, or debugging transcripts;
- one-off debugging state or temporary file paths;
- current worktree state, task progress, or short-lived plans;
- facts that a future agent can obtain quickly from repository files.

Store distilled knowledge through Rekal tools. Do not write memories to
`AGENTS.md`, `CLAUDE.md`, `MEMORY.md`, or another context file.
