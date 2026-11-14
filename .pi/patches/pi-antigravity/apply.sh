#!/usr/bin/env bash
# Apply the local pi-antigravity 0.14.0 fix patch to an installed package.
#
#   ./apply.sh [package-dir]
#
# Defaults to $HOME/.pi/agent/npm/node_modules/pi-antigravity.
# Idempotent: exits 0 with a note if the patch is already applied.
set -euo pipefail

readonly EXPECTED_VERSION="0.14.0"
readonly TEST_PATCH="scripts/test-native-images.ts"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
patch_file="${script_dir}/${EXPECTED_VERSION}.patch"
pkg_dir="${1:-$HOME/.pi/agent/npm/node_modules/pi-antigravity}"

die() { printf 'apply.sh: %s\n' "$*" >&2; exit 1; }

[ -f "$patch_file" ] || die "patch not found: $patch_file"
[ -d "$pkg_dir" ] || die "package dir not found: $pkg_dir"
command -v git >/dev/null 2>&1 || die "git is required"

pkg_dir="$(cd -- "$pkg_dir" && pwd)"
pkg_json="$pkg_dir/package.json"
[ -f "$pkg_json" ] || die "no package.json in $pkg_dir (not a pi-antigravity install?)"

installed_version="$(
  sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$pkg_json" | head -n 1
)"
if [ "$installed_version" != "$EXPECTED_VERSION" ]; then
  die "installed pi-antigravity is ${installed_version:-unknown}, this patch targets ${EXPECTED_VERSION}. Refusing."
fi

# Published packages ship src/ but not scripts/, so the test-harness hunk is excluded there.
exclude_args=()
if [ ! -d "$pkg_dir/scripts" ]; then
  exclude_args=(--exclude="$TEST_PATCH")
fi

cd "$pkg_dir"

if git apply -R --check -p1 ${exclude_args[@]+"${exclude_args[@]}"} "$patch_file" 2>/dev/null; then
  printf 'apply.sh: patch already applied to %s (v%s) - nothing to do.\n' "$pkg_dir" "$installed_version"
  exit 0
fi

git apply --check -p1 ${exclude_args[@]+"${exclude_args[@]}"} "$patch_file" ||
  die "patch does not apply cleanly to $pkg_dir; nothing was changed."

git apply -p1 ${exclude_args[@]+"${exclude_args[@]}"} "$patch_file"

changed="$(git apply --numstat -p1 ${exclude_args[@]+"${exclude_args[@]}"} "$patch_file" | wc -l)"
printf 'apply.sh: applied %s to %s (v%s).\n' "$(basename "$patch_file")" "$pkg_dir" "$installed_version"
printf 'apply.sh: %s file(s) touched:\n' "$changed"
git apply --stat -p1 ${exclude_args[@]+"${exclude_args[@]}"} "$patch_file" | sed 's/^/  /'
printf 'apply.sh: restore with: git apply -R -p1 %s (run inside %s)\n' "$patch_file" "$pkg_dir"
