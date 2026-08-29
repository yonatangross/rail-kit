# Contributing

Thanks for looking. rail-kit is small on purpose: four skills, one folder convention,
no runtime. Most contributions are wording, a missed edge case in a spec, or a new
example. Here is what a mergeable change looks like.

## The gate

```bash
bash scripts/validate-kit.sh    # must print "validate-kit: all green"
bash scripts/smoke-install.sh   # copy-install path
```

`validate-kit.sh` runs the 13-check skill validator (ported from the private house
tooling and kept byte-comparable), then kit-level checks: one version everywhere, the
Hebrew twin is present and stamped, examples have their three sections, shared
references are byte-identical across skills, every reference is named in its SKILL.md,
the description carries a NOT-for clause and ends with the policy sentence, and the
giveaway lint is clean. CI runs the same script plus a self-test that plants a broken
skill and asserts the validator fails on it.

## Skill layout

```
skills/<name>/
  SKILL.md               100-150 lines, the only file the model loads
  SKILL_HE.md            condensed Hebrew twin for operators, <!-- mirrors SKILL.md vX.Y.Z -->
  metadata.json          version, organization, date, abstract
  behavioral-spec.json   >= 6 cases, >= 1 negative with the literal token NOT
  references/            clients-folder.md and wispr-flow.md are shared copies; the rest is per skill
  examples/              NN-<case>.md with ## Context / ## What the skill does / ## Why it matters
  scripts/               optional, bash, set -euo pipefail, --help, executable
```

Editing a shared reference means editing every copy; the validator checks their md5s.

## The Hebrew twin policy

`SKILL_HE.md` is a condensed operator-facing summary, not a full translation. The model
reads only `SKILL.md`, so a full mirror would double the drift surface for text nothing
loads. When you change `SKILL.md` behavior, update the twin's step table and bump the
`mirrors` stamp in the same commit.

## Giveaway rules

This repo is public. Nothing from real client work goes in: no names, no prices, no
transcripts, no internal tool or issue references. `scripts/check-giveaway.sh` catches
the generic shapes; a private denylist of real names runs in CI from a secret. If you
need an example, extend the fictional `dana-studio` fixture.

## Versioning

One version for the whole kit, semver. Add a `## [x.y.z]` section to `CHANGELOG.md`
first, then `bash scripts/bump-version.sh x.y.z` rewrites every version site. A tag
`vx.y.z` on `main` builds the release zip; the release workflow refuses a tag that does
not match `plugin.json`.

## Writing style

Plain sentences. No em-dashes. Hebrew never inside markdown tables, blockquotes or
ASCII boxes (terminals reorder it); use plain lines or a fenced block.
