#!/usr/bin/env bash
# rail-kit (c) 2026 yonyon-ai, MIT.
#
# validate-kit.sh: the whole gate. Runs the ported 13-check skill validator,
# then the kit-level checks (Hebrew twin present and version-stamped, one
# version everywhere, example naming and sections, shared references
# byte-identical, SKILL.md size, description contract, frontmatter name equals
# directory, organization, giveaway lint, shellcheck, every reference named in
# its SKILL.md). Exit 0 only when everything passes.
# Usage: validate-kit.sh [--help]
set -euo pipefail
trap 'echo "[$0] failed at line $LINENO" >&2' ERR

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  sed -n '3,10p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fails=0
fail() { echo "  [FAIL] $*"; fails=$((fails + 1)); }
pass() { echo "  [PASS] $*"; }

echo "=== 1/3 house validator (13 checks) ==="
RAIL_KIT_SKILLS_DIR="$ROOT/skills" bash "$ROOT/scripts/validate-skills.sh" || fails=$((fails + 1))

echo ""
echo "=== 2/3 kit checks ==="
PLUGIN_VER="$(python3 -c 'import json; print(json.load(open("'"$ROOT"'/.claude-plugin/plugin.json"))["version"])')"
MKT_VER="$(python3 -c 'import json; print(json.load(open("'"$ROOT"'/.claude-plugin/marketplace.json"))["plugins"][0]["version"])')"
[ "$PLUGIN_VER" = "$MKT_VER" ] && pass "plugin.json and marketplace.json agree ($PLUGIN_VER)" || fail "plugin.json=$PLUGIN_VER marketplace.json=$MKT_VER"

TAIL_RO="Model-invocable, so fire it yourself when the goal matches; do not fire it speculatively or as a checkpoint."
TAIL_MUT="never fire it as a background checkpoint."

fm_field() { awk -v f="$2" '/^---$/{n++; next} n==1 && $0 ~ "^"f":" {sub("^"f":[[:space:]]*",""); print; exit}' "$1"; }

for dir in "$ROOT"/skills/*/; do
  s="$(basename "$dir")"
  echo "$s/"
  md="$dir/SKILL.md"; he="$dir/SKILL_HE.md"; meta="$dir/metadata.json"
  [ -f "$md" ] || { fail "SKILL.md missing"; continue; }

  # name == dir, author, version parity
  name="$(fm_field "$md" name)"
  [ "$name" = "$s" ] && pass "frontmatter name equals directory" || fail "name '$name' != dir '$s'"
  ver="$(fm_field "$md" version | tr -d '"')"
  [ "$ver" = "$PLUGIN_VER" ] && pass "version matches plugin ($ver)" || fail "SKILL.md version $ver != plugin $PLUGIN_VER"
  author="$(fm_field "$md" author)"
  [ "$author" = "yonyon-ai" ] && pass "author yonyon-ai" || fail "author is '$author'"

  # Hebrew twin
  if [ -f "$he" ]; then
    hver="$(fm_field "$he" version | tr -d '"')"
    [ "$hver" = "$PLUGIN_VER" ] && pass "SKILL_HE.md version $hver" || fail "SKILL_HE.md version $hver != $PLUGIN_VER"
    grep -qF "<!-- mirrors SKILL.md v$PLUGIN_VER -->" "$he" && pass "SKILL_HE.md mirrors stamp" || fail "SKILL_HE.md lacks 'mirrors SKILL.md v$PLUGIN_VER' stamp"
  else
    fail "SKILL_HE.md missing"
  fi

  # metadata organization
  org="$(python3 -c 'import json; print(json.load(open("'"$meta"'")).get("organization",""))' 2>/dev/null || echo "")"
  [ "$org" = "yonyon-ai" ] && pass "metadata organization yonyon-ai" || fail "metadata organization '$org'"

  # size
  lines="$(wc -l < "$md" | tr -d ' ')"
  if [ "$lines" -gt 220 ]; then fail "SKILL.md $lines lines (> 220)"; elif [ "$lines" -gt 150 ]; then echo "  [WARN] SKILL.md $lines lines (> 150 soft cap)"; else pass "SKILL.md $lines lines"; fi

  # description contract
  desc="$(fm_field "$md" description)"
  dlen=${#desc}
  [ "$dlen" -le 1024 ] && pass "description $dlen chars" || fail "description $dlen chars (> 1024)"
  case "$desc" in *"NOT for"*) pass "description carries a NOT-for clause" ;; *) fail "description lacks 'NOT for'" ;; esac
  case "$desc" in *"$TAIL_RO"|*"$TAIL_MUT") pass "description ends with a policy tail" ;; *) fail "description does not end with a policy tail sentence" ;; esac

  # examples: naming + sections
  for ex in "$dir"/examples/*.md; do
    [ -f "$ex" ] || continue
    b="$(basename "$ex")"
    [[ "$b" =~ ^[0-9]{2}-[a-z0-9-]+\.md$ ]] || fail "example name '$b' not NN-<case>.md"
    for h in "## Context" "## What the skill does" "## Why it matters"; do
      grep -qF "$h" "$ex" || fail "$b lacks '$h'"
    done
  done
  pass "examples checked"

  # every reference named in SKILL.md
  for ref in "$dir"/references/*.md; do
    [ -f "$ref" ] || continue
    r="$(basename "$ref")"
    grep -qF "$r" "$md" || fail "references/$r is never named in SKILL.md"
  done
  pass "references named"
done

# shared references byte-identical
for shared in clients-folder.md wispr-flow.md; do
  sums="$(find "$ROOT/skills" -path "*/references/$shared" -exec md5 -q {} \; 2>/dev/null || find "$ROOT/skills" -path "*/references/$shared" -exec md5sum {} \; | awk '{print $1}')"
  n="$(echo "$sums" | sort -u | wc -l | tr -d ' ')"
  [ "$n" = "1" ] && pass "shared $shared identical across copies" || fail "shared $shared differs between skills"
done

echo ""
echo "=== 3/3 lint ==="
bash "$ROOT/scripts/check-giveaway.sh" || fails=$((fails + 1))
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck -S warning "$ROOT"/scripts/*.sh "$ROOT"/skills/*/scripts/*.sh; then pass "shellcheck clean"; else fail "shellcheck"; fi
else
  echo "  [WARN] shellcheck not installed, skipped"
fi

echo ""
if [ "$fails" -gt 0 ]; then echo "=== validate-kit: $fails failure(s) ==="; exit 1; fi
echo "=== validate-kit: all green ==="
