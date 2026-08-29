#!/usr/bin/env bash
# rail-kit (c) 2026 yonyon-ai, MIT.
#
# smoke-install.sh: prove the copy-install path produces four loadable skills.
# Copies skills/ into a temporary HOME, then asserts each skill directory has a
# SKILL.md whose frontmatter name equals the directory name. The interactive
# half (type /skills in Claude Code and see the four) is printed as a manual step.
# Usage: smoke-install.sh [--help]
set -euo pipefail
trap 'echo "[$0] failed at line $LINENO" >&2' ERR

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  sed -n '3,8p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
mkdir -p "$TMP_HOME/.claude/skills"
cp -R "$ROOT/skills/." "$TMP_HOME/.claude/skills/"

expected=(post-call prep-call client-context sync-call-state)
ok=0
for s in "${expected[@]}"; do
  f="$TMP_HOME/.claude/skills/$s/SKILL.md"
  if [ ! -f "$f" ]; then
    echo "[FAIL] $s: SKILL.md missing after install"
    exit 1
  fi
  name="$(awk '/^---$/{n++; next} n==1 && /^name:/{sub(/^name:[[:space:]]*/,""); print; exit}' "$f")"
  if [ "$name" != "$s" ]; then
    echo "[FAIL] $s: frontmatter name is '$name'"
    exit 1
  fi
  echo "[PASS] $s installed (name matches directory)"
  ok=$((ok + 1))
done
echo "smoke-install: $ok/${#expected[@]} skills installed under $TMP_HOME/.claude/skills"
echo "manual step: HOME=$TMP_HOME claude, then /skills should list the four."
