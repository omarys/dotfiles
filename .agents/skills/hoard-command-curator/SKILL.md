---
name: hoard-command-curator
description: Curate, parameterize, and preserve complex, reusable shell commands into Hoard. Use when discovering, executing, or refining non-trivial CLI commands (e.g. Kubernetes, AWS, Terraform, jq pipelines) that are worth saving for future use, or when the user asks to save, hoard, or bookmark a command.
---

# Hoard Command Curator

Use `hoard` to preserve complex, reusable shell commands that are worth keeping for future use.

This skill is intended for coding agents and shell-capable assistants. Its purpose is not to record shell history. It should curate useful commands into reusable, documented entries.

## Goals

When a useful command is created or successfully used:

1. Decide whether it is worth saving.
2. Convert it into a reusable form.
3. Remove secrets and unnecessary environment-specific values.
4. Give it a clear name, description, namespace, and useful tags.
5. Save it with `hoard`.
6. Avoid duplicate, trivial, failed, unsafe, or overly specific entries.

Prefer quality over quantity.

## Command wrapper policy

Apply these defaults when normalizing commands before saving:

```yaml
wrapper_policy:
  rtk: optional
  sudo: strip-unless-required
  time: strip-unless-benchmarking
  timeout: preserve-when-behavioral
  watch: preserve-when-behavioral
  env: preserve-nonsecret
  nice: preserve-when-behavioral
  ionice: preserve-when-behavioral
  nohup: preserve-only-when-required
  shell_wrapper: strip-unless-required
```

These values are descriptive policy, not configuration consumed by Hoard.

Interpret them as follows:

- `optional`: omit by default unless the wrapper materially affects reusable behavior.
- `strip-unless-required`: remove unless the command would be meaningfully incomplete without it.
- `strip-unless-benchmarking`: remove unless measurement is the purpose of the saved command.
- `preserve-when-behavioral`: retain when the wrapper defines part of the intended operation rather than incidental execution context.
- `preserve-nonsecret`: retain environment assignments only when useful, while never embedding secret values.
- `preserve-only-when-required`: retain only when the command specifically depends on that execution mode.
- `strip-unless-required` for shell wrappers means removing `bash -c`, `sh -c`, `zsh -c`, or similar wrappers unless shell semantics require them.

If a later rule in this skill conflicts with this policy, the more specific rule takes precedence.

## Tool availability

Before attempting to save a command, verify that `hoard` is available:

```sh
command -v hoard >/dev/null 2>&1
```

If `hoard` is unavailable:

- Do not install it automatically unless explicitly requested.
- Continue the user's primary task normally.
- Mention that the command could not be saved because `hoard` is unavailable only when saving was explicitly requested.

When necessary, inspect the locally installed version rather than assuming CLI behavior:

```sh
hoard --help
```

or:

```sh
hoard new --help
```

Prefer the behavior of the installed binary over documentation remembered by the model.

## When to save a command

Consider saving a command when one or more of these conditions apply:

- It is difficult to remember or reconstruct.
- It contains several non-obvious flags.
- It uses multiple pipes or shell transformations.
- It contains a useful `jq`, `yq`, `awk`, `sed`, or regular-expression expression.
- It performs a useful Kubernetes operation.
- It performs a useful AWS, cloud, Terraform, OpenTofu, Helm, or infrastructure operation.
- It represents a useful troubleshooting procedure.
- It captures a command discovered during debugging.
- It performs a useful Git or Jujutsu workflow that is not obvious.
- It contains a useful container, Kubernetes, networking, or security diagnostic.
- It would reasonably save time if needed again several weeks or months later.
- The user explicitly asks to save, hoard, bookmark, or remember the command in Hoard.

Examples of good candidates:

```sh
kubectl get pods -A \
  -o json |
jq -r '.items[] |
  select(.status.containerStatuses[]?.restartCount > 5) |
  [.metadata.namespace, .metadata.name] |
  @tsv'
```

```sh
aws s3api list-object-versions \
  --bucket "$BUCKET" \
  --query 'Versions[].{Key:Key,VersionId:VersionId}'
```

```sh
terraform state list |
rg 'aws_eks_node_group'
```

## When not to save

Do not automatically save commands that are:

- trivial;
- obvious;
- one-time navigation commands;
- failed experiments;
- syntactically invalid;
- superseded by a better command later in the same task;
- generated speculatively but never validated;
- dangerous without substantial context;
- highly specific to a temporary environment;
- primarily composed of secrets;
- already represented by an equivalent Hoard entry.

Examples that normally should not be saved:

```sh
ls
```

```sh
pwd
```

```sh
kubectl get pods
```

```sh
git status
```

```sh
terraform plan
```

Do not save every command merely because it was executed successfully.

## Validate before saving

Prefer commands that have been successfully executed.

If execution is inappropriate, validate using the safest reasonable mechanism.

Examples:

```sh
bash -n script.sh
```

```sh
terraform validate
```

```sh
kubectl apply --dry-run=client -f file.yaml
```

Do not execute a destructive command merely to validate it.

A command may still be saved without execution when:

- the user explicitly requests it;
- execution requires unavailable infrastructure;
- execution would mutate production systems;
- the command is clearly valid based on authoritative syntax.

When this occurs, describe it as unverified if Hoard metadata permits doing so.

## Curate instead of copying

Do not blindly save the literal command from shell history.

Convert it into the most reusable form that preserves its purpose.

For example, convert:

```sh
aws s3api list-object-versions \
  --bucket prod-opensearch-snapshots-octiprime \
  --query 'Versions[].{Key:Key,VersionId:VersionId}'
```

into:

```sh
aws s3api list-object-versions \
  --bucket #bucket \
  --query 'Versions[].{Key:Key,VersionId:VersionId}'
```

Hoard uses `#` as its default parameter token. Respect the user's configured token if it differs.

Prefer named parameters where practical.

Examples:

```sh
kubectl -n #namespace get pod #pod -o yaml
```

```sh
aws s3 sync \
  s3://#source-bucket/#source-prefix! \
  s3://#destination-bucket/#destination-prefix!
```

Do not parameterize values that are essential to the identity of the command.

For example:

```sh
kubectl get pods -A
```

does not benefit from replacing `pods` or `-A` with parameters.

## Secret handling

Never store credentials or secret material in Hoard.

Before saving, inspect commands for:

- passwords;
- API keys;
- bearer tokens;
- OAuth tokens;
- session tokens;
- private keys;
- certificates containing private key material;
- AWS secret access keys;
- database passwords;
- embedded credentials in URLs;
- authentication headers;
- Kubernetes secret values;
- environment variables whose values contain credentials.

Replace sensitive values with parameters or environment-variable references.

Bad:

```sh
curl \
  -H 'Authorization: Bearer eyJhbGciOi...' \
  https://example.internal/api
```

Good:

```sh
curl \
  -H "Authorization: Bearer $API_TOKEN" \
  https://#host/api
```

Better when the secret already comes from a secret manager:

```sh
curl \
  -H "Authorization: Bearer $(pass show #secret-name)" \
  https://#host/api
```

Never print a secret merely to transform the command before saving it.

Do not retrieve secret values unless required for the user's primary task.

## Environment-specific values

Prefer parameterizing values such as:

- Kubernetes namespaces;
- pod names;
- deployment names;
- cluster names;
- AWS account IDs;
- AWS regions when variable;
- S3 bucket names;
- ARNs;
- resource IDs;
- hostnames;
- internal domains;
- IP addresses;
- file paths specific to one project;
- ticket numbers;
- temporary IDs.

Do not aggressively parameterize stable values when doing so would make a command harder to understand.

For example:

```sh
kubectl get pods -n #namespace
```

is preferable to:

```sh
#binary #verb #resource #namespace-flag #namespace
```

## Command prefixes and wrappers

Commands may be executed through wrappers or prefixes such as:

```text
rtk
sudo
time
timeout
watch
env
nice
ionice
nohup
bash -c
sh -c
zsh -c
```

Do not blindly preserve or remove wrappers.

Determine whether the wrapper is:

1. part of the reusable operation;
2. an execution convenience;
3. an environment-specific requirement; or
4. temporary instrumentation used during debugging.

Store the simplest command that preserves the reusable intent.

### `rtk`

Treat `rtk` as a meaningful command wrapper when it is part of the user's normal agent or shell workflow.

For example, if this was executed:

```sh
rtk kubectl get pods -A
```

the underlying reusable command is:

```sh
kubectl get pods -A
```

If the Hoard entry is intended to be usable independently of the agent harness, prefer storing the underlying command.

If `rtk` materially affects execution, optimization, logging, routing, or another behavior relevant to the command, retain it:

```sh
rtk kubectl logs -n #namespace #pod
```

When uncertain, prefer portability:

```text
command: kubectl logs -n #namespace #pod
description: Retrieve logs from a Kubernetes pod. May be executed through `rtk` in RTK-enabled environments.
```

Do not assume every command executed through `rtk` should be stored with the `rtk` prefix.

### `sudo`

Remove `sudo` when privilege escalation is merely specific to the machine on which the command happened to run.

Executed:

```sh
sudo systemctl restart containerd
```

Preferred stored command:

```sh
systemctl restart containerd
```

Suggested description:

```text
Restart containerd. Requires sufficient privileges, typically root.
```

Preserve `sudo` only when it is materially part of the intended invocation or the user explicitly prefers commands stored with privilege escalation.

Never assume passwordless `sudo` exists.

Never store a command containing:

```sh
sudo -S
```

with a password supplied through stdin or another embedded credential.

### `time`

Remove `time` when it was used only to observe how long an unrelated command happened to take.

Executed:

```sh
time terraform plan
```

Preferred:

```sh
terraform plan
```

Preserve it when measurement is the purpose of the entry:

```sh
time #command
```

or:

```sh
/usr/bin/time -v #command
```

Example metadata:

```text
name: benchmark-command-resources
namespace: linux
tags: performance, profiling
description: Measure elapsed time and resource usage for a command.
```

Be aware that `time` may be a shell keyword while `/usr/bin/time` is a separate executable. Preserve the distinction when relevant.

### `timeout`

Preserve `timeout` when bounding execution time is part of the safety or intended behavior.

Example:

```sh
timeout #duration kubectl logs -f -n #namespace #pod
```

Do not remove it merely to simplify the command if doing so could cause the command to run indefinitely.

If `timeout` was added only during temporary debugging, store the underlying command instead.

### `watch`

Preserve `watch` when repeated observation is the command's purpose.

Example:

```sh
watch -n #seconds kubectl get pods -n #namespace
```

If the useful operation is simply retrieving the current state, store:

```sh
kubectl get pods -n #namespace
```

instead.

### `env`

Preserve environment assignments when they materially configure the command.

Example:

```sh
env AWS_PROFILE=#profile AWS_REGION=#region \
  aws sts get-caller-identity
```

Environment variables containing secrets must never be expanded into the Hoard entry.

Bad:

```sh
env API_TOKEN=actual-secret-value curl ...
```

Good:

```sh
env API_TOKEN="$API_TOKEN" curl ...
```

Prefer references to environment variables over storing their values.

### `nice` and `ionice`

Preserve scheduling wrappers only when reduced or elevated resource priority is part of the command's purpose.

Executed during incidental testing:

```sh
nice -n 10 tar -czf archive.tar.gz data/
```

Usually store:

```sh
tar -czf #archive #source
```

If resource throttling is intentional:

```sh
nice -n #priority \
  ionice -c #class \
  tar -czf #archive #source
```

may be appropriate.

### `nohup`

Preserve `nohup` only when detached execution is essential to the procedure.

Do not automatically preserve shell redirections generated as incidental `nohup` behavior.

Consider whether the actual reusable operation would be better represented by a systemd service, Kubernetes workload, job scheduler, or terminal multiplexer rather than saving a fragile detached shell command.

### Shell invocation wrappers

Avoid unnecessary constructs such as:

```sh
bash -c '...'
```

```sh
sh -c '...'
```

when the underlying command can be represented directly.

For example:

```sh
bash -c 'kubectl get pods -A'
```

should normally become:

```sh
kubectl get pods -A
```

Preserve the shell wrapper when the expression actually depends on shell behavior such as:

- pipelines;
- redirection;
- brace expansion;
- shell functions;
- command substitution;
- shell-specific syntax;
- compound commands;
- environment setup affecting multiple commands.

Example:

```sh
bash -c 'kubectl get pods -A | jq -r ".items[].metadata.name"'
```

may remain a shell expression when required by the execution environment, although Hoard should normally store the pipeline itself when it can do so safely.

### Multiple wrappers

Commands may contain multiple wrappers:

```sh
sudo time rtk kubectl get pods -A
```

Analyze them independently.

For example:

```text
sudo    -> incidental privilege requirement
time    -> temporary measurement
rtk     -> optional local workflow wrapper
kubectl -> actual reusable operation
```

The preferred Hoard entry may therefore be:

```sh
kubectl get pods -A
```

Conversely:

```sh
timeout 30s rtk kubectl logs -f -n #namespace #pod
```

may reasonably retain `timeout` because bounded log following is the reusable behavior, while `rtk` may remain optional:

```sh
timeout #duration kubectl logs -f -n #namespace #pod
```

### Wrapper normalization principle

Before saving, conceptually decompose a command as:

```text
[privilege]
[instrumentation]
[execution wrapper]
[environment]
[resource controls]
[actual command]
[arguments]
```

Then retain only the layers necessary to reproduce the intended reusable behavior.

The goal is not to reproduce exactly what appeared in shell history.

The goal is to preserve the command someone will want to run next time.

## Destructive commands

Treat destructive commands more conservatively.

Examples include:

- `rm`;
- `kubectl delete`;
- `terraform destroy`;
- `aws ... delete-*`;
- database `DROP` or destructive SQL;
- force pushes;
- filesystem formatting;
- bulk permission changes;
- commands that overwrite remote state.

Only save a destructive command when:

- it represents a genuinely reusable administrative procedure; and
- its dangerous parameters are clearly parameterized; and
- its description explicitly states its destructive effect.

Prefer adding a safety mechanism when the tool supports one.

For example, prefer:

```sh
kubectl delete pod #pod -n #namespace --dry-run=client
```

as a diagnostic/template entry over storing a production deletion command unnecessarily.

Never silently execute a destructive command simply because it exists in Hoard.

## Naming

Names should be:

- short;
- descriptive;
- action-oriented;
- distinguishable during search.

Prefer:

```text
k8s-pods-high-restarts
```

```text
aws-s3-list-object-versions
```

```text
terraform-find-eks-state
```

Avoid:

```text
command1
```

```text
useful-command
```

```text
aws-stuff
```

Names should describe intent rather than implementation details whenever possible.

## Descriptions

Descriptions should answer:

> Why would I use this command?

Prefer:

```text
List Kubernetes pods across all namespaces whose containers have restarted more than five times.
```

over:

```text
Runs kubectl and jq.
```

Useful descriptions may also mention:

- prerequisites;
- output format;
- destructive behavior;
- unusual assumptions;
- required permissions.

Keep descriptions concise.

## Namespaces

Use namespaces as broad organizational categories.

Prefer existing namespaces when they clearly fit.

Suggested namespaces:

```text
aws
containers
git
jj
kubernetes
linux
networking
opensearch
opencti
security
terraform
```

Do not create near-duplicate namespaces such as:

```text
k8s
kubernetes
kube
```

If an existing naming convention can be determined from Hoard, follow it.

## Tags

Tags should improve retrieval rather than repeat every word in the command.

Use approximately 2-6 meaningful tags when supported.

Example:

```text
namespace: kubernetes

tags:
- troubleshooting
- pods
- restarts
- jq
```

Another example:

```text
namespace: aws

tags:
- s3
- versions
- inventory
```

Prefer lowercase tags.

Avoid overly generic tags such as:

```text
command
shell
cli
useful
```

unless they convey meaningful information within the user's existing taxonomy.

## Duplicate detection

Avoid accumulating many versions of the same command.

Before saving when practical, inspect existing Hoard commands using the installed CLI.

For example:

```sh
hoard list
```

Search by likely:

- name;
- namespace;
- command;
- distinctive flags;
- tags.

If an equivalent command already exists:

- do not create another entry;
- prefer the existing entry when it is still correct.

If the new command materially improves an existing entry, consider updating it with:

```sh
hoard edit <name>
```

Do not overwrite a user's curated command merely because stylistic differences exist.

Material improvements include:

- fixing incorrect syntax;
- removing embedded secrets;
- making fixed values parameterized;
- replacing deprecated syntax;
- adding important safety flags;
- making the command substantially more reusable.

## Saving workflow

When a command qualifies for Hoard:

1. Capture the useful command.
2. Remove secrets.
3. Identify wrappers and decide which are incidental versus behavioral.
4. Parameterize appropriate values.
5. Simplify unnecessary environment-specific details.
6. Confirm syntax or successful execution.
7. Check for an obvious duplicate when practical.
8. Determine:

   - name;
   - description;
   - namespace;
   - tags.

9. Use the locally installed `hoard` CLI to save it.

The standard Hoard entry workflow is:

```sh
hoard new
```

Because this operation may be interactive, interact with the CLI normally rather than editing Hoard's storage files directly.

Do not modify `trove.yml` directly unless:

- the user explicitly asks;
- `hoard new` cannot accomplish the task; or
- batch management of Hoard data is the explicit task.

Prefer Hoard's own CLI so its configuration and schema remain authoritative.

## Parameter syntax

Hoard supports parameterized commands.

The default parameter token is:

```text
#
```

Example:

```sh
echo "My name is #name and I live in #city"
```

Named parameters should be descriptive.

Prefer:

```text
#namespace
#pod
#bucket
#region
#profile
#cluster
#repository
```

over:

```text
#x
#foo
#value1
```

The user's Hoard configuration may define a different token.

If parameter syntax appears not to work, inspect:

```sh
hoard info
```

and:

```sh
hoard --help
```

Do not change the user's configured parameter token unless explicitly requested.

## Shell portability

Preserve the shell semantics of the command.

Do not convert:

- Bash-specific constructs to POSIX shell;
- Zsh-specific syntax to Bash;
- Fish syntax to Bash;

unless portability is itself the goal.

If the command requires a particular shell, mention that in its description when relevant.

Example:

```text
Bash/Zsh command for extracting Kubernetes restart counts with jq.
```

## Multiline commands

For long commands, retain readable formatting where Hoard and the installed shell support it.

For example:

```sh
kubectl get pods -A -o json |
jq -r '
  .items[]
  | select(.status.containerStatuses[]?.restartCount > 5)
  | [
      .metadata.namespace,
      .metadata.name
    ]
  | @tsv
'
```

Do not minify a complicated command solely to save space.

If Hoard requires a single-line representation, preserve quoting carefully.

## Command pipelines

Treat a pipeline as one Hoard entry when the stages jointly perform one reusable task.

Example:

```sh
kubectl get pods -A -o json |
jq -r '.items[] | [.metadata.namespace, .metadata.name] | @tsv'
```

Do not split this into separate `kubectl` and `jq` entries unless each is independently useful.

## Commands generated during troubleshooting

Troubleshooting sessions often produce many temporary commands.

Do not save each intermediate attempt.

Wait until there is a clear useful result.

Prefer saving:

- the command that exposed the root cause;
- the command that fixed the problem;
- a reusable verification command.

Do not save:

- typo corrections;
- repeated attempts;
- commands whose output proved irrelevant;
- temporary debugging mutations.

When multiple commands form a reusable procedure, prefer the most useful individual commands unless Hoard supports a clean representation of the workflow.

## Project-local versus global commands

Hoard may use a local `trove.yml` when one exists in the current directory.

Respect this behavior.

Before saving a command whose scope matters, determine whether the current project has local Hoard configuration.

Prefer project-local storage when the command is tightly coupled to:

- one repository;
- one deployment;
- one application;
- project-specific scripts or paths.

Prefer global storage when the command is broadly reusable across environments.

Do not move commands between global and local troves without user intent.

## Examples

### Kubernetes troubleshooting

Original:

```sh
rtk kubectl get pods -n cti -o json |
jq -r '.items[] |
select(.status.containerStatuses[]?.restartCount > 5) |
.metadata.name'
```

Curated:

```sh
kubectl get pods -n #namespace -o json |
jq -r '.items[] |
select(.status.containerStatuses[]?.restartCount > #restart-count) |
.metadata.name'
```

Suggested metadata:

```text
name: k8s-pods-over-restart-count
namespace: kubernetes
tags: pods, troubleshooting, restarts, jq
description: List pods in a namespace whose containers exceed a specified restart count.
```

Reasoning:

```text
rtk -> omitted because it is an optional execution wrapper
namespace -> parameterized
restart threshold -> parameterized
kubectl/jq pipeline -> preserved because it is the reusable operation
```

### AWS S3

Original:

```sh
aws s3api list-object-versions \
  --bucket prod-example-data \
  --query 'Versions[].{Key:Key,VersionId:VersionId}'
```

Curated:

```sh
aws s3api list-object-versions \
  --bucket #bucket \
  --query 'Versions[].{Key:Key,VersionId:VersionId}'
```

Suggested metadata:

```text
name: aws-s3-list-object-versions
namespace: aws
tags: s3, versions
description: List object keys and version IDs from a versioned S3 bucket.
```

### Terraform

Original:

```sh
time rtk terraform state list |
grep aws_eks_node_group
```

Curated:

```sh
terraform state list |
rg 'aws_eks_node_group'
```

Suggested metadata:

```text
name: terraform-find-eks-node-groups
namespace: terraform
tags: state, eks, aws
description: Find EKS node group resources in Terraform state.
```

Reasoning:

```text
time -> removed because benchmarking is not the command's purpose
rtk -> removed because it is an optional execution wrapper
grep -> may be replaced with rg only if rg is available and consistent with the user's normal tooling
terraform pipeline -> preserved
```

Do not make substitutions like `grep` to `rg` unless the replacement is available and represents the user's normal tooling or materially improves the command.

### Privileged system command

Original:

```sh
sudo systemctl restart containerd
```

Curated:

```sh
systemctl restart containerd
```

Suggested metadata:

```text
name: restart-containerd
namespace: linux
tags: systemd, containerd
description: Restart the containerd service. Requires sufficient privileges, typically root.
```

### Bounded log following

Original:

```sh
rtk timeout 30s kubectl logs -f -n cti worker-abc123
```

Curated:

```sh
timeout #duration kubectl logs -f -n #namespace #pod
```

Suggested metadata:

```text
name: k8s-follow-logs-with-timeout
namespace: kubernetes
tags: logs, troubleshooting, timeout
description: Follow Kubernetes pod logs for a bounded period to prevent indefinite execution.
```

Reasoning:

```text
rtk -> omitted as optional
timeout -> preserved because bounded execution is intentional behavior
duration -> parameterized
namespace -> parameterized
pod name -> parameterized
```

## User intent

If the user explicitly says:

```text
save this command
```

or equivalent, treat that as authorization to create the Hoard entry.

If the user merely asks for a command, do not assume they want it saved unless command auto-curation has already been established as an expected agent behavior.

When automatic Hoard curation is enabled, do not interrupt ordinary work with confirmation prompts for every safe command.

Instead:

- save only high-value commands;
- briefly mention the saved entry afterward when useful.

For destructive, security-sensitive, or ambiguous entries, prefer confirmation before saving unless the user has explicitly established a different policy.

## Agent behavior

Hoard management is secondary to the user's primary task.

Do not:

- derail troubleshooting to organize commands;
- repeatedly mention Hoard;
- spend substantial time categorizing marginal commands;
- save dozens of commands from one session;
- treat Hoard as long-term semantic memory for facts.

A good rule:

> If reconstructing this command three months from now would be annoying, and the command is likely to be useful again, consider hoarding it.

A better rule:

> Save the reusable solution, not the debugging history.

## Safety boundary

Never use a saved Hoard command as proof that the command is safe to execute.

Before executing any retrieved command:

1. inspect it;
2. resolve parameters;
3. consider the current environment;
4. evaluate destructive effects;
5. apply normal agent safety rules.

Saved commands can become stale as:

- APIs change;
- CLI versions change;
- infrastructure changes;
- resource names change;
- permissions change.

Hoard is a command library, not an authorization mechanism.
