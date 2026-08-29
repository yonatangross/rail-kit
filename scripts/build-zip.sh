#!/usr/bin/env bash
# rail-kit (c) 2026 yonyon-ai, MIT.
#
# build-zip.sh: build dist/rail-kit.zip, the release asset yonyon.ai/rail links to.
# Contents: skills/ .claude-plugin/ fixtures/ README.md README_HE.md LICENSE
# CHANGELOG.md, under a top-level rail-kit/ folder. Excludes .github/, scripts/,
# dist/ and any real clients/. Deterministic file order; extended attributes off.
# Also writes dist/notes.md: the CHANGELOG section for the current version.
# Usage: build-zip.sh [--help]
set -euo pipefail
trap 'echo "[$0] failed at line $LINENO" >&2' ERR

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  sed -n '3,9p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(python3 -c 'import json; print(json.load(open("'"$ROOT"'/.claude-plugin/plugin.json"))["version"])')"
STAGE="$(mktemp -d)/rail-kit"
mkdir -p "$STAGE" "$ROOT/dist"

for p in skills .claude-plugin fixtures README.md README_HE.md LICENSE CHANGELOG.md; do
  [ -e "$ROOT/$p" ] || { echo "missing $p" >&2; exit 1; }
  cp -R "$ROOT/$p" "$STAGE/"
done
find "$STAGE" -name .DS_Store -delete

rm -f "$ROOT/dist/rail-kit.zip"
( cd "$(dirname "$STAGE")" && find rail-kit -type f | LC_ALL=C sort | zip -X -q "$ROOT/dist/rail-kit.zip" -@ )

# Release notes: the CHANGELOG block for this version (heading "## [x.y.z]").
awk -v v="$VERSION" '
  $0 ~ "^## \\[" v "\\]" {p=1; print; next}
  p && /^## \[/ {exit}
  p {print}
' "$ROOT/CHANGELOG.md" > "$ROOT/dist/notes.md"
[ -s "$ROOT/dist/notes.md" ] || { echo "CHANGELOG has no section for $VERSION" >&2; exit 1; }

echo "built dist/rail-kit.zip (v$VERSION): $(unzip -l "$ROOT/dist/rail-kit.zip" | tail -1)"
