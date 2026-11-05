#!/usr/bin/env bash
# Keep the tracked copy of pi's settings in sync with the live one.
#
# pi rewrites ~/.pi/agent/settings.json whenever you add a package or when it
# bumps lastChangelogVersion, so the copy committed in this repo drifts and a
# fresh machine restores a stale package list. Run from the pre-commit hook,
# this re-copies the live file whenever the two differ.
#
# PI_LIVE_SETTINGS overrides the source path (used by the tests).
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
live="${PI_LIVE_SETTINGS:-$HOME/.pi/agent/settings.json}"
tracked="$repo_root/.pi/agent/settings.json"

# Machines without pi have nothing to sync.
if [[ ! -f "$live" ]]; then
  exit 0
fi

# Never commit a config that does not parse.
if ! python3 -c 'import json, sys; json.load(open(sys.argv[1]))' "$live" 2>/dev/null; then
  printf 'pi-settings-sync: %s is not valid JSON; leaving the tracked copy alone\n' "$live" >&2
  exit 1
fi

# Already identical: nothing to do.
if cmp -s "$live" "$tracked"; then
  exit 0
fi

cp "$live" "$tracked"
printf 'pi-settings-sync: copied %s -> %s\n' "$live" "${tracked#"$repo_root"/}" >&2
printf 'pi-settings-sync: re-run the commit to include the update\n' >&2
exit 1
