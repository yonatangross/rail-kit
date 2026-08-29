#!/usr/bin/env bash
# rail-kit (c) 2026 yonyon-ai, MIT.
#
# check-giveaway.sh: refuse to ship internal references or real client data.
# Scans skills/, fixtures/ and the root docs for (a) the generic patterns in
# scripts/giveaway-patterns.txt and (b) an optional out-of-repo denylist of real
# names, one extended regex per line, given via GIVEAWAY_DENYLIST_FILE. The
# denylist is never committed; CI writes it from a secret into a temp file.
#
# Exit 0 = clean. Exit 1 = at least one hit (printed as file:line: text).
# Usage: check-giveaway.sh [--help]
set -euo pipefail
trap 'echo "[$0] failed at line $LINENO" >&2' ERR

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  sed -n '3,10p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PATTERNS="$ROOT/scripts/giveaway-patterns.txt"
DENYLIST="${GIVEAWAY_DENYLIST_FILE:-}"

targets=("$ROOT/skills" "$ROOT/fixtures")
for f in README.md README_HE.md CHANGELOG.md CONTRIBUTING.md; do
  [ -f "$ROOT/$f" ] && targets+=("$ROOT/$f")
done

hits=0
scan() {
  local re="$1" label="$2"
  # grep rc 1 = no match (fine), rc >1 = real error (must surface, not read as clean)
  local out rc=0
  out="$(grep -rnE --exclude-dir=.git -- "$re" "${targets[@]}" 2>/dev/null)" || rc=$?
  if [ "$rc" -gt 1 ]; then
    echo "error: grep failed (rc=$rc) on pattern [$label]" >&2
    exit 2
  fi
  if [ -n "$out" ]; then
    echo "[$label]"
    echo "$out"
    hits=$((hits + 1))
  fi
}

while IFS= read -r line; do
  case "$line" in ''|'#'*) continue ;; esac
  scan "$line" "generic: $line"
done < "$PATTERNS"

if [ -n "$DENYLIST" ]; then
  if [ ! -r "$DENYLIST" ]; then
    echo "error: GIVEAWAY_DENYLIST_FILE=$DENYLIST is not readable" >&2
    exit 2
  fi
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    scan "$line" "denylist entry"
  done < "$DENYLIST"
  echo "denylist: applied ($(grep -cvE '^(#|$)' "$DENYLIST") entries)"
else
  echo "denylist: not set (GIVEAWAY_DENYLIST_FILE), generic patterns only"
fi

if [ "$hits" -gt 0 ]; then
  echo "giveaway lint: $hits pattern(s) hit"
  exit 1
fi
echo "giveaway lint: clean"
