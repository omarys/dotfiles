---
name: lumins
description: Synchronize, copy, compare and delete directory trees with `lms` (LuminS), the agent-first rsync alternative. Use when a task mirrors a source tree into a destination, dry-runs a sync before applying it, needs the delta between two trees, cleans a workspace directory, or when rsync progress output would flood the context window.
---

# LuminS (`lms`)

Three verbs over directory trees, each reporting one line of JSON instead of a progress bar.

| Verb | Effect | Deletes on the destination? |
| --- | --- | --- |
| `lms sync <src> <dest>` | Make `dest` mirror `src` | Yes - anything `src` lacks |
| `lms cp <src> <dest>` | Add `src` to `dest` | Never |
| `lms rm <target>...` | Delete each target tree | Everything under the target |

`sync` places the contents of `src` directly in `dest`, the way `rsync src/ dest/` does. `cp` appends the source's own name when `dest` already exists, the way `cp -r` does: `lms cp src dest` writes `dest/src/`.

```sh
lms --version    # 0.4.0 and later carry --llm
```

When `lms` is missing, `cargo build --release` in the LuminS checkout and use `target/release/lms`.

## Dry-run first

`-N` / `--dry-run` computes the full plan and writes no file contents:

```sh
lms sync src/ dest/ --llm -N
```

It does create `dest` when that directory is missing, as a real sync would, so point it at a path you do not mind existing afterwards.

Done when you can name every entry in `changes.added`, `changes.modified` and `changes.deleted`, and can say how much of the destination `stats.scanned_dest` covers. On a mirror, `deleted` is the list to read twice: those paths are about to disappear.

## Choose the verb

- `sync` when `dest` must end up identical to `src`. `--nodelete` keeps the mirror additive.
- `cp` when nothing in `dest` may be removed.
- `rm` when the tree should go. It requires explicit targets. `--preserve-vcs` spares `.git/` and deletes everything else, so a workspace sweep cannot take the history with it.

For `sync` and `cp`, `--ignore-vcs-and-build` skips `.git/`, `target/`, `node_modules/`, `dist/`, `.cache/` and `*.pyc` from inside the walked tree. `rm` refuses that flag: on a delete it would leave those trees on disk and still exit 0, which reads as a clean sweep.

Done when the verb matches the destructive intent, not merely the files that move.

## Apply, then confirm

Run the same command without `-N`. Success is exit 0 with `"status":"synced"`. A second dry-run should then report empty change lists:

```sh
lms sync src/ dest/ --llm | jq -e '.status == "synced"' &&
  lms sync src/ dest/ --llm -N | jq -e '.changes | (.added + .modified + .deleted) == []'
```

## The report

```json
{
  "status": "dry_run | synced",
  "changes": {
    "added": ["path/to/new_file.rs"],
    "modified": [
      {"path": "src/main.rs", "delta_bytes": 412, "hunks": 2}
    ],
    "deleted": []
  },
  "stats": {
    "scanned_src": 142,
    "scanned_dest": 1150,
    "transferred_bytes": 1024,
    "duration_ms": 48
  }
}
```

- Paths are relative to their root: `added` and `modified` to the source, `deleted` to the destination (for `rm`, to the target). Join them before acting on them. Deletions name directories as well as files, so `["target", "target/x"]` lists a child whose parent already covers it.
- `delta_bytes` is source size minus destination size, so it is negative when the source is smaller. `0` with `hunks > 0` means a same-size rewrite or a retargeted symlink, not an unchanged file.
- `hunks` counts runs of differing 8 KiB windows: how scattered the edit is, not how large.
- `scanned_dest` is the denominator for `deleted`. Five deletions out of five scanned entries is a wipe; five out of fifty thousand is a trim. `scanned_src: 10` beside `scanned_dest: 450000` names the destination walk as whatever made the run slow.
- `transferred_bytes` counts bytes written, and `cp` rewrites every file it copies: it is non-zero even when `changes` is empty. Reach for `sync` when write volume matters, since it copies only what differs.

### Truncation

`--llm` lists at most 50 changes and summarises the rest; `--json` is unlimited unless you pass `--max-report-files <N>`. The budget is reserved by signal - deletions first, then modifications, then additions, with unused slots spilling down - so a run that generates 400 new files still shows you the 3 deletions and the 2 rewrites in it.

```json
"truncated": true,
"total_overflow": 450,
"overflow": {
  "added": {"count": 430, "by_dir": {"assets/icons/": 400, "docs/": 30}},
  "modified": {"count": 20, "by_dir": {"src/generated/": 20}},
  "deleted": {"count": 0, "by_dir": {}}
}
```

`by_dir` keys end in `/`, and entries sitting directly under the root bucket as `./`. `overflow` keeps the categories apart because a collapsed directory of new assets and one of deleted files call for opposite reactions. `--max-report-files 0` keeps the counts and drops every path, for a yes/no answer on whether anything changed at all.

### Failures

A run that fails while doing the work - a missing source, an unreadable file - exits 1, explains itself on stderr, and under `--llm` or `--json` also answers on stdout:

```json
{"status": "error", "error": "Source Error -- /nope: No such file or directory (os error 2)"}
```

A rejected command line is the other failure: an unknown flag or missing argument exits 1 with the usage message on stderr and nothing at all on stdout, in every mode. So empty stdout beside a non-zero exit is a usage error, not a silent success.

### Several targets

`rm` over more than one target prints one document per target, in order, as a JSON array.

## Terminal hygiene

Progress bars, percentages, ETAs and carriage returns appear only on an interactive terminal without `--llm` or `--json`. A report is one `\n`-terminated line with no `\r`, backspace or ANSI escape of its own, so a captured stdout stream costs one line of context and parses as JSON on the first try. On a real terminal the line ending may arrive as CRLF; that is the tty translating the newline, not the report. Pass `-v` only when a human is reading the log: it writes to stderr, never into the report.

## Recipes

Compare two trees without moving a file - the sync dry-run *is* the diff, given both already exist:

```sh
lms sync old/ new/ --llm -N | jq '.changes'
```

Bounded report for a large tree, deletions first:

```sh
lms sync build/ mirror/ --llm --max-report-files 20 -N
```

Clean a workspace but keep its git history:

```sh
lms rm scratch/ --llm --preserve-vcs
```

Skip the dependency and build trees on a mirror, without writing out an exclude list:

```sh
lms sync repo/ backup/ --llm --ignore-vcs-and-build
```
