#!/bin/bash
# rail-kit skill validator.
#
# Ported from the author's private house validator (validate-skills.sh,
# (c) Yonatan Gross) and released under MIT for rail-kit. The 13 checks are kept
# byte-comparable with upstream so future changes can be diffed in. Exemption
# lists are intentionally empty: the kit has no grandfathered skills.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# SKILLS_DIR overridable so tests can target fixture skill directories (ζ-4, #230)
SKILLS_DIR="${RAIL_KIT_SKILLS_DIR:-$PLUGIN_ROOT/skills}"

TOTAL_SKILLS=0
PASSED_SKILLS=0
FAILED_SKILLS=0
TIER1_COUNT=0
TIER2_COUNT=0
TIER3_COUNT=0

REQUIRED_FIELDS=("name" "description" "tags" "version" "author" "user-invocable" "complexity" "disable-model-invocation" "allowed-tools")

# Line-anchored frontmatter probes for check #13, as bash EREs rather than
# `grep -q ... <<<"$frontmatter"` (#789). A here-string is backed by a pipe that
# bash fills BEFORE exec'ing the reader, so a frontmatter body over PIPE_BUF
# deadlocks forever, 512 bytes on macOS under pipe pressure, 64K on Linux CI,
# which is why CI never saw it. `[[ =~ ]]` is bash's own regex engine: no pipe,
# no fork, same ERE syntax.
# Both the subject and these patterns are wrapped in newlines, so a `\n...\n`
# match is exactly grep's per-line `^...$`, including on the first and last
# lines. Do not drop the wrapping: bash anchors `^`/`$` to the whole string, not
# to each line, so `^context:` alone would only ever match line 1.
FORK_CONTEXT_RE=$'\ncontext:[[:space:]]*fork[[:space:]]*\n'
BACKGROUND_DECL_RE=$'\nbackground:[[:space:]]*(true|false)[[:space:]]*\n'

# Grandfathered tier-1 user-invocable skills (allow-listed at v1.15 close, ζ-4 / #230).
# Empty as of ζ-5 wrap (#249), all 12 originally-allow-listed skills graduated to tier 2+.
# New tier-1 user-invocable skills must NOT join this list; scaffold-skill.sh produces tier-3 by default.
GRANDFATHERED_TIER1=(
  # ζ-5 wrap (#249): array is intentionally empty. The validator now fails any
  # new tier-1 user-invocable skill without exception. Do not re-populate.
)

# Directories under skills/ that are deliberately NOT skills: shared libraries other
# skills and agent prompts point at. They carry no SKILL.md by design, mirroring
# ork/skills/shared/. sync-skill-manifest.mjs already ignores them (it requires a
# SKILL.md), so they never become phantom slash targets; this loop needs the same guard
# or it fails them for the missing file. Add new non-skill directories here.
NON_SKILL_DIRS=(
  "shared"
)

is_non_skill_dir() {
  local name="$1"
  for entry in "${NON_SKILL_DIRS[@]}"; do
    [ "$entry" = "$name" ] && return 0
  done
  return 1
}

is_grandfathered() {
  local name="$1"
  for entry in "${GRANDFATHERED_TIER1[@]}"; do
    [ "$entry" = "$name" ] && return 0
  done
  return 1
}

# Skills exempt from the read-only MCP-delegation invariant (check #11, #345).
# The convention (CONTRIBUTING-SKILLS.md §Subagent Delegation Pattern, Mandatory)
# is that a skill delegates ALL MCP calls to subagents via the Agent tool, its own
# allowed-tools must inline no mcp__ tool or server glob. A skill that legitimately
# inlines a send/write MCP tool BY DESIGN goes here, with a one-line justification ,
# same discipline as GRANDFATHERED_TIER1. Keep this list as small as possible.
SEND_EXEMPT=(
  # rail-kit: no skill inlines an MCP grant; MCP use is described in references and permission-prompted.
)

is_send_exempt() {
  local name="$1"
  for entry in "${SEND_EXEMPT[@]}"; do
    [ "$entry" = "$name" ] && return 0
  done
  return 1
}

# Skills that genuinely take NO user input, exempt from the argument-hint
# requirement (check #12, #583②). A user-invocable skill that accepts input
# (a positional slug/path, a subcommand, or real flags) MUST advertise it via
# `argument-hint` so the slash-command menu shows what to type. Skills that are
# pure "just run it" entry points (status/health/digest roll-ups, or workflows
# whose flags are internal to scripts/ rather than user-facing) go here, with a
# one-line justification, same discipline as SEND_EXEMPT. A misleading hint on
# a no-arg skill is worse than none, so the exemption is explicit, not inferred.
NO_ARGS_EXEMPT=(
  # rail-kit: every skill takes a client name, so every skill carries an argument-hint.
)

is_no_args_exempt() {
  local name="$1"
  for entry in "${NO_ARGS_EXEMPT[@]}"; do
    [ "$entry" = "$name" ] && return 0
  done
  return 1
}

# Fork + user-invocable skills whose background disposition is NOT yet decided (#773).
# CC 2.1.218 flipped the `context: fork` default to backgrounded, so every skill that
# omits the key silently inherits whatever upstream currently prefers. The first pass
# (#773) triaged the 28 skills on the everyday operator surface and deliberately left
# these alone rather than guess at their intent. They still inherit the default; that
# is a known, written-down gap instead of an invisible one.
# This list may only SHRINK. A NEW fork skill is not on it, so check #13 fires for it,
# which is the whole point: the next upstream default flip cannot move anything quietly.
BACKGROUND_TRIAGE_PENDING=(
  # rail-kit: no fork skills.
)

is_background_triage_pending() {
  local name="$1"
  for entry in "${BACKGROUND_TRIAGE_PENDING[@]}"; do
    [ "$entry" = "$name" ] && return 0
  done
  return 1
}

echo "=== Validating rail-kit skills ==="
echo ""

for skill_dir in "$SKILLS_DIR"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  if is_non_skill_dir "$skill_name"; then
    echo "$skill_name/  [SKIP] shared library, not a skill (no SKILL.md by design)"
    echo ""
    continue
  fi
  TOTAL_SKILLS=$((TOTAL_SKILLS + 1))
  skill_failed=false

  echo "$skill_name/"

  # 1. SKILL.md exists and has YAML frontmatter
  skill_md="$skill_dir/SKILL.md"
  if [ -f "$skill_md" ]; then
    first_line="$(head -n1 "$skill_md")"
    if [ "$first_line" = "---" ]; then
      # Check closing delimiter exists
      closing="$(tail -n +2 "$skill_md" | grep -n "^---$" | head -n1)"
      if [ -n "$closing" ]; then
        echo "  [PASS] SKILL.md exists with frontmatter"
      else
        echo "  [FAIL] SKILL.md missing closing frontmatter delimiter (---)"
        skill_failed=true
      fi
    else
      echo "  [FAIL] SKILL.md missing YAML frontmatter (first line must be ---)"
      skill_failed=true
    fi
  else
    echo "  [FAIL] SKILL.md does not exist"
    skill_failed=true
  fi

  # 2. Required fields in frontmatter
  if [ -f "$skill_md" ]; then
    # Extract frontmatter (between first and second ---)
    frontmatter="$(awk '/^---$/{n++; next} n==1{print}' "$skill_md")"
    missing_fields=()
    for field in "${REQUIRED_FIELDS[@]}"; do
      # `case` builtin, NOT `grep -q <<<"$frontmatter"` (#789). Bash 5.3 backs a
      # here-string with a pipe and writes the payload BEFORE exec'ing the reader,
      # so a body over PIPE_BUF deadlocks forever (512B on macOS, 64K on Linux CI,
      # which is why CI stayed green while every local run hung here). Frontmatter
      # is routinely over that line. The leading newline makes `*\n<field>:*`
      # equivalent to grep's `^` anchor, including on the very first line.
      case $'\n'"$frontmatter" in
        *$'\n'"$field":*) : ;;
        *) missing_fields+=("$field") ;;
      esac
    done
    if [ ${#missing_fields[@]} -eq 0 ]; then
      echo "  [PASS] Required fields present"
    else
      echo "  [FAIL] Missing required fields: ${missing_fields[*]}"
      skill_failed=true
    fi
  fi

  # 3. SKILL.md under 500 lines
  if [ -f "$skill_md" ]; then
    line_count="$(wc -l < "$skill_md" | tr -d ' ')"
    if [ "$line_count" -lt 500 ]; then
      echo "  [PASS] SKILL.md under 500 lines ($line_count lines)"
    else
      echo "  [FAIL] SKILL.md exceeds 500 lines ($line_count lines)"
      skill_failed=true
    fi
  fi

  # 3b. A bundled-script invocation must not depend on CLAUDE_PLUGIN_ROOT or
  #     CLAUDE_SKILL_DIR (#964). Both are UNSET in the Bash tool, so
  #     `bash "$CLAUDE_PLUGIN_ROOT/skills/x/scripts/y.sh"` expands to
  #     `/skills/x/scripts/y.sh` and exits 127, measured, not inferred: the
  #     floor skill shipped, released and installed with its step 1 dead, and
  #     every static gate passed it because the string is well-formed.
  #
  #     `${CLAUDE_PLUGIN_ROOT:-.}` is the nastier variant and is caught too. It
  #     falls back to `.`, so it resolves ONLY when cwd happens to be the
  #     upstream checkout, one of thirteen workspaces on this machine. It works
  #     for the maintainer, in the maintainer's repo, and nowhere else.
  #
  #     Statically decidable, like the check-load-paths gate (#962). Prose may
  #     still NAME these variables (this repo documents the trap), so only a
  #     line that actually invokes `bash "..."` counts. awk, not `grep -c`:
  #     grep exits 1 on no-match, and `|| true` would turn a real grep failure
  #     into an empty count indistinguishable from a clean skill.
  if [ -f "$skill_md" ]; then
    # The pattern is NOT anchored to `^bash "`. That was the #968 form, and it
    # had two holes that let 7 live instances through across 6 skills (#954):
    #   1. only `bash`, every `python3 "${CLAUDE_PLUGIN_ROOT}/..."` was invisible
    #   2. only at line start, anything inside a bullet or prose was invisible
    # `alembic-rescue` was the skill #968 named as carrying the blast radius, and
    # it still had 2 broken python3 invocations afterwards. Fixing the instances
    # a narrow pattern can see is not fixing the class.
    #
    # NOTE the DOUBLED backslashes. `awk -v` processes escape sequences in the
    # assignment, so a single `\$` arrives as a bare `$`, an end-of-string
    # anchor that can never match mid-line, and the gate silently counts ZERO.
    # That is the same defect one level up: a check reporting clean because it
    # cannot see its subject. The self-test below makes it impossible to ship.
    ENVDEP_RE='(bash|sh|python3|python|uv run|node|npx|deno)[[:space:]]+"[^"]*\\$\\{?CLAUDE_(PLUGIN_ROOT|SKILL_DIR)'

    # Self-test: the pattern MUST match a known-positive control. A regex that
    # matches nothing would otherwise render as "every skill is clean".
    if ! printf 'python3 "${CLAUDE_PLUGIN_ROOT}/scripts/x.py"\n' \
         | awk -v re="$ENVDEP_RE" '$0 ~ re {found=1} END{exit !found}'; then
      echo "  [FAIL] [paths] the env-dep pattern matches its own control, gate is BLIND" >&2
      skill_failed=true
    fi

    envdep_count="$(awk -v re="$ENVDEP_RE" '$0 ~ re {n++} END{print n+0}' "$skill_md")"
    if [ "$envdep_count" -eq 0 ]; then
      echo "  [PASS] [paths] no bundled-script invocation depends on an unset env var"
    else
      echo "  [FAIL] [paths] $envdep_count invocation(s) use CLAUDE_PLUGIN_ROOT/CLAUDE_SKILL_DIR, UNSET in the Bash tool (#964)"
      awk -v re="$ENVDEP_RE" '$0 ~ re {print "         line " NR ": " substr($0,1,120)}' "$skill_md"
      echo "         fix: S=\"\$(ls -d ~/.claude/skills/<name> ./.claude/skills/<name> ~/.claude/plugins/cache/yonyon/rail-kit/*/skills/<name> 2>/dev/null | head -1)\"; bash \"\$S/scripts/<script>.sh\""
      skill_failed=true
    fi
  fi

  # 4 & 5. behavioral-spec.json exists, valid JSON, at least 6 test cases
  test_cases="$skill_dir/behavioral-spec.json"
  if [ -f "$test_cases" ]; then
    if python3 -c "import json; json.load(open('$test_cases'))" 2>/dev/null; then
      case_count="$(python3 -c "import json; print(len(json.load(open('$test_cases'))))")"
      if [ "$case_count" -ge 6 ]; then
        echo "  [PASS] behavioral-spec.json valid with $case_count cases"
      else
        echo "  [FAIL] behavioral-spec.json has only $case_count cases (minimum 6 required)"
        skill_failed=true
      fi
    else
      echo "  [FAIL] behavioral-spec.json is not valid JSON"
      skill_failed=true
    fi
  else
    echo "  [FAIL] behavioral-spec.json does not exist"
    skill_failed=true
  fi

  # 6. At least 1 negative test case
  if [ -f "$test_cases" ]; then
    negative_count="$(python3 -c "
import json
cases = json.load(open('$test_cases'))
count = 0
for case in cases:
    for behavior in case.get('expected_behavior', []):
        low = behavior.lower()
        if 'not' in low.split() or 'should not' in low:
            count += 1
            break
print(count)
" 2>/dev/null || echo "0")"
    if [ "$negative_count" -ge 1 ]; then
      echo "  [PASS] Negative test case found"
    else
      echo "  [FAIL] No negative test case found (expectedBehavior containing 'NOT' or 'should not')"
      skill_failed=true
    fi
  fi

  # 7. metadata.json exists, is valid JSON, and its version matches SKILL.md.
  # metadata.json duplicates the frontmatter version; a hand-edit to one and not
  # the other silently drifts, hq-promote shipped v1.1.0 with metadata.json still
  # claiming 1.0.0 + the superseded abstract (#628). Gate the drift, don't chase it.
  metadata="$skill_dir/metadata.json"
  if [ ! -f "$metadata" ]; then
    echo "  [FAIL] metadata.json does not exist"
    skill_failed=true
  elif ! python3 -c "import json; json.load(open('$metadata'))" 2>/dev/null; then  # silent: known-noise
    echo "  [FAIL] metadata.json is not valid JSON"
    skill_failed=true
  else
    echo "  [PASS] metadata.json valid"
    # JSON is valid here, so .get() cannot raise, no stderr suppression needed.
    meta_ver="$(python3 -c "import json; print(json.load(open('$metadata')).get('version',''))")"
    if [ -n "$meta_ver" ] && [ -f "$skill_md" ]; then
      skill_ver="$(awk '/^---$/{n++; next} n==1{print}' "$skill_md" | grep '^version:' | head -n1 | sed 's/^version:[[:space:]]*//' | tr -d '"[:space:]')"
      if [ "$meta_ver" = "$skill_ver" ]; then
        echo "  [PASS] metadata.json version matches SKILL.md ($meta_ver)"
      else
        echo "  [FAIL] version drift: metadata.json=$meta_ver != SKILL.md=$skill_ver"
        skill_failed=true
      fi
    fi
  fi

  # 8. If rules/ directory exists, _sections.md and _template.md must exist
  rules_dir="$skill_dir/rules"
  if [ -d "$rules_dir" ]; then
    sections_ok=true
    template_ok=true
    if [ ! -f "$rules_dir/_sections.md" ]; then
      sections_ok=false
    fi
    if [ ! -f "$rules_dir/_template.md" ]; then
      template_ok=false
    fi
    if $sections_ok && $template_ok; then
      echo "  [PASS] Rules: _sections.md and _template.md present"
    else
      missing_rules=()
      $sections_ok || missing_rules+=("_sections.md")
      $template_ok || missing_rules+=("_template.md")
      echo "  [FAIL] Rules directory missing: ${missing_rules[*]}"
      skill_failed=true
    fi
  fi

  # 9. All .sh scripts in scripts/ are executable
  scripts_dir="$skill_dir/scripts"
  if [ -d "$scripts_dir" ]; then
    total_scripts=0
    exec_scripts=0
    non_exec=()
    for script in "$scripts_dir"/*.sh; do
      [ -f "$script" ] || continue
      total_scripts=$((total_scripts + 1))
      if [ -x "$script" ]; then
        exec_scripts=$((exec_scripts + 1))
      else
        non_exec+=("$(basename "$script")")
      fi
    done
    if [ "$total_scripts" -gt 0 ]; then
      if [ ${#non_exec[@]} -eq 0 ]; then
        echo "  [PASS] Scripts executable ($exec_scripts/$total_scripts)"
      else
        echo "  [FAIL] Non-executable scripts: ${non_exec[*]}"
        skill_failed=true
      fi
    fi
  fi

  # 10. Tier classification, user-invocable skills must be tier 2+ (ζ-4, #230 policy lock).
  # Non-invocable internal dispatchers may stay tier 1.
  # Grandfathered tier-1 user-invocable skills warn (tracked in ζ-5); new ones fail.
  refs_dir="$skill_dir/references"
  examples_dir="$skill_dir/examples"
  refs_count=0
  examples_count=0
  if [ -d "$refs_dir" ]; then
    refs_count=$(find "$refs_dir" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
  fi
  if [ -d "$examples_dir" ]; then
    examples_count=$(find "$examples_dir" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')
  fi
  # silent: best-effort, frontmatter without user-invocable field is treated as non-invocable (handled below)
  user_invocable="$(echo "$frontmatter" | grep -E '^user-invocable:' | awk '{print $2}' | tr -d '"' || true)"
  if [ "$examples_count" -ge 2 ] && [ "$refs_count" -ge 1 ]; then
    echo "  [PASS] [tier 3] full structure (references: $refs_count, examples: $examples_count)"
    TIER3_COUNT=$((TIER3_COUNT + 1))
  elif [ "$refs_count" -ge 1 ]; then
    echo "  [PASS] [tier 2] standard (references: $refs_count, examples: $examples_count), add ≥2 examples for tier 3"
    TIER2_COUNT=$((TIER2_COUNT + 1))
  else
    # Tier 1 minimal, verdict depends on user-invocable + grandfathered status
    if [ "$user_invocable" = "true" ]; then
      if is_grandfathered "$skill_name"; then
        echo "  [WARN] [tier 1] grandfathered (ζ-5 backlog), retrofill references/ to graduate to tier 2+"
        TIER1_COUNT=$((TIER1_COUNT + 1))
      else
        echo "  [FAIL] [tier 1] user-invocable skill missing references/, must be tier 2+ (see CONTRIBUTING-SKILLS.md, scaffold via scripts/scaffold-skill.sh)"
        TIER1_COUNT=$((TIER1_COUNT + 1))
        skill_failed=true
      fi
    else
      echo "  [PASS] [tier 1] minimal (non-invocable dispatcher), references/ optional"
      TIER1_COUNT=$((TIER1_COUNT + 1))
    fi
  fi

  # 11. Read-only MCP-delegation invariant (#345). Skills delegate ALL MCP calls to
  #     subagents via the Agent tool (CONTRIBUTING-SKILLS.md §Subagent Delegation
  #     Pattern, Mandatory), so a skill's own allowed-tools must inline NO mcp__ tool
  #     or server glob, unless the skill is explicitly send-exempt. This is the TRUE,
  #     enforceable read-only invariant. Skill-level `disallowed-tools` would be dead
  #     here (allowed-tools is already an allowlist, no PreToolUse fires for the Skill
  #     tool, and denies don't propagate into spawned sub-agents); real read-only
  #     enforcement lives at the AGENT layer (agents/validate-handoffs.sh +
  #     hooks/src/pretool-spawn-guard.ts). The check catches drift, a new skill
  #     copy-pasting a send/write grant instead of delegating.
  if [ -f "$skill_md" ]; then
    # silent: best-effort, allowed-tools is a required field (check #2); guard the grep anyway
    allowed_line="$(echo "$frontmatter" | grep -E '^allowed-tools:' | head -n1 || true)"
    # Plain substring on a single line, so the `[[ ]]` builtin is exact and forks
    # nothing. Deliberately not a here-string (#789).
    if [[ "$allowed_line" == *mcp__* ]]; then
      if is_send_exempt "$skill_name"; then
        echo "  [PASS] [io-class] send-exempt, inlines MCP by design (see SEND_EXEMPT)"
      else
        inlined="$(echo "$allowed_line" | grep -oE 'mcp__[a-zA-Z0-9_*-]+' | tr '\n' ' ')"
        echo "  [FAIL] [io-class] skill inlines MCP grant(s) [ ${inlined}], delegate MCP via the Agent tool (CONTRIBUTING-SKILLS.md §Subagent Delegation Pattern); read-only enforcement lives at the agent layer, not skill frontmatter"
        skill_failed=true
      fi
    else
      echo "  [PASS] [io-class] delegates MCP via Agent (no inline mcp__ grant)"
    fi
  fi

  # 12. argument-hint present for USER-INVOCABLE skills unless they take no input (#583②).
  #     `argument-hint` is the slash-command menu hint, so it only matters for
  #     user-invocable skills, non-invocable dispatchers never appear in the menu
  #     and are skipped here. A user-invocable skill that accepts a positional /
  #     subcommand / flag should advertise it; no-arg ones are explicitly allow-listed
  #     in NO_ARGS_EXEMPT (same discipline as SEND_EXEMPT), a misleading hint is worse
  #     than none, so the exemption is conscious, not inferred. New arg-taking skills
  #     must add a hint; new no-arg ones must add themselves to NO_ARGS_EXEMPT.
  if [ -f "$skill_md" ] && [ "$user_invocable" = "true" ]; then
    # Line-anchored field probe via the `case` builtin, not a here-string (#789).
    if [[ $'\n'"$frontmatter" == *$'\n'argument-hint:* ]]; then
      echo "  [PASS] [args] argument-hint present"
    elif is_no_args_exempt "$skill_name"; then
      echo "  [PASS] [args] no-arg skill (NO_ARGS_EXEMPT)"
    else
      echo "  [FAIL] [args] missing argument-hint, add one (e.g. \"<slug> [--flag]\"), or if the skill takes no user input add it to NO_ARGS_EXEMPT in validate-skills.sh"
      skill_failed=true
    fi
  fi

  # 13. `background:` must be DECLARED, not inherited, on fork + user-invocable skills (#773).
  #     CC 2.1.218: "Changed skills with `context: fork` to run in the background by default;
  #     opt out per skill with `background: false`". The predicate in the running 2.1.220
  #     binary is `if (t || DT() || _n()) return !1; return e.background ?? !0`, so a skill
  #     that omits the key inherits whatever upstream currently prefers. That preference
  #     already changed once without us noticing, which is precisely the failure this check
  #     exists to stop.
  #     Why it matters more than "the answer shows up elsewhere": a user-invocable skill was
  #     typed by the operator, who is waiting. If it also asks a question, backgrounding does
  #     not merely hide the answer, it STRANDS the run (the agent goes state blocked and fires
  #     agent_needs_input, invisible until the agent view is opened).
  #     `background` is deliberately NOT in REQUIRED_FIELDS: non-fork skills never fork, so the
  #     key is meaningless for them and a flat requirement would fail every one of them.
  #     Skills still awaiting a decision are listed in BACKGROUND_TRIAGE_PENDING and warn.
  if [ -f "$skill_md" ] && [ "$user_invocable" = "true" ] && [[ $'\n'"$frontmatter"$'\n' =~ $FORK_CONTEXT_RE ]]; then
    if [[ $'\n'"$frontmatter"$'\n' =~ $BACKGROUND_DECL_RE ]]; then
      echo "  [PASS] [background] explicit background declared"
    elif is_background_triage_pending "$skill_name"; then
      echo "  [WARN] [background] inherits the upstream default (BACKGROUND_TRIAGE_PENDING, #773)"
    else
      echo "  [FAIL] [background] fork + user-invocable skill does not declare 'background:', add 'background: false' next to 'context: fork' when the operator is waiting on the answer, or 'background: true' when it is genuinely fire-and-forget (#773)"
      skill_failed=true
    fi
  fi

  if $skill_failed; then
    FAILED_SKILLS=$((FAILED_SKILLS + 1))
  else
    PASSED_SKILLS=$((PASSED_SKILLS + 1))
  fi

  echo ""
done

echo "=== Results: $PASSED_SKILLS/$TOTAL_SKILLS skills passed, $FAILED_SKILLS failed ==="
echo "Tier breakdown: tier-1: $TIER1_COUNT · tier-2: $TIER2_COUNT · tier-3: $TIER3_COUNT"

if [ "$FAILED_SKILLS" -gt 0 ]; then
  exit 1
fi
exit 0
