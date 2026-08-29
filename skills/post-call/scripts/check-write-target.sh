#!/usr/bin/env bash
# rail-kit (c) 2026 yonyon-ai, MIT. Ported from the author's private house tooling.

set -euo pipefail
trap 'echo "[$0] failed at line $LINENO" >&2' ERR

# check-write-target.sh: decide whether post-call Step 5 may Write to its
# deterministic path.
#
# THE CLASS
# ---------
# The review-doc path is deterministic: clients/<name>/post-call-<date>.md, and
# the determinism contract says re-running the same client + date OVERWRITES.
# That is correct when the skill owns the file and data loss when it does not
# (a hand-written note with the same name, for instance). Nothing in the Write
# step can tell the two apart, so this guard decides first.
#
# THE SIGNATURE
# -------------
# Every doc post-call writes carries the template's provenance line, which
# contains the words DRAFTS ONLY. Presence of that line is the skill's claim of
# ownership. Absence means the file came from somewhere else, whatever its name.
#
# CONTRACT: exactly one stdout line; the exit code carries the verdict
# ---------------------------------------------------------------------
#   ok-absent <path>       rc=0  nothing there; Write freely
#   ok-owned <path>        rc=0  a prior run of THIS skill; overwrite is the contract
#   refuse-foreign <path>  rc=3  occupied by a doc this skill did not write. Do NOT
#                                Write. Stop and ask the operator; never silently
#                                pick a different filename, that breaks the
#                                filename pattern the determinism contract needs.
#   error <reason>         rc=2  could not decide. NOT the same as "safe to write".
#
# Usage: check-write-target.sh <path-to-post-call-doc>   (--help prints this)

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  sed -n '/^# check-write-target.sh/,/^# Usage/p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

SIGNATURE='DRAFTS ONLY'

if [ "$#" -ne 1 ]; then
  echo "error missing-path (usage: check-write-target.sh <path>)"
  exit 2
fi
TARGET="$1"

if [ ! -e "$TARGET" ]; then
  echo "ok-absent $TARGET"
  exit 0
fi

if [ ! -f "$TARGET" ]; then
  echo "error not-a-regular-file: $TARGET"
  exit 2
fi

if [ ! -r "$TARGET" ]; then
  echo "error unreadable: $TARGET"
  exit 2
fi

# grep exit codes: 0 = found, 1 = not found, >1 = a real error. Collapsing >1
# into "not found" would report an unreadable file as safe to clobber, the
# exact could-not-observe-vs-nothing-there confusion this guard exists to stop.
rc=0
grep -qF -- "$SIGNATURE" "$TARGET" || rc=$?
case "$rc" in
  0) echo "ok-owned $TARGET"; exit 0 ;;
  1) echo "refuse-foreign $TARGET"; exit 3 ;;
  *) echo "error grep-failed rc=$rc on $TARGET"; exit 2 ;;
esac
