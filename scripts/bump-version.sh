#!/usr/bin/env bash
# rail-kit (c) 2026 yonyon-ai, MIT.
#
# bump-version.sh <new-version>: rewrite the kit version everywhere it lives
# (plugin.json, marketplace.json, every SKILL.md, SKILL_HE.md and metadata.json).
# Refuses unless CHANGELOG.md already has a "## [<new-version>]" heading, so the
# release notes exist before the tag does. Logic in scripts/lib/bump_version.py.
# Usage: bump-version.sh <x.y.z> | --help
set -euo pipefail
trap 'echo "[$0] failed at line $LINENO" >&2' ERR

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ] || [ -z "${1:-}" ]; then
  sed -n '3,8p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

NEW="$1"
[[ "$NEW" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "not a semver: $NEW" >&2; exit 1; }
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
grep -qE "^## \[$NEW\]" "$ROOT/CHANGELOG.md" || { echo "CHANGELOG.md has no '## [$NEW]' section yet" >&2; exit 1; }

python3 "$ROOT/scripts/lib/bump_version.py" "$ROOT" "$NEW"
