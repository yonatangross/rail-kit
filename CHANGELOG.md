# Changelog

All notable changes to rail-kit. Semver, one version for the whole kit.

## [Unreleased]

## [1.1.3] - 2026-08-30

- Descriptions no longer contain angle brackets (`clients/NAME/` instead of a placeholder
  in brackets); the Skills IL spec check rejects `<` and `>` in the description.

## [1.1.2] - 2026-08-30

- Release attestation now also covers `skills/*/scripts/**` (the files a user executes),
  matching the Skills IL default subject set.
- Hebrew and English tag lists have equal length on every skill.

## [1.1.1] - 2026-08-30

- Workflow actions bumped by Dependabot (checkout 7, gitleaks-action 3, action-gh-release 3,
  attest-build-provenance 4.2.2). No skill changes.

## [1.1.0] - 2026-08-30

- SKILL.md frontmatter on all four skills: `license`, `compatibility`, `supported_agents`,
  and `metadata` with Hebrew and English display name, display description and tags
  (Skills IL catalog fields).
- Release workflow signs every tag build with a Sigstore provenance attestation
  (`actions/attest-build-provenance`) covering the zip and the skill files.
- SECURITY.md, CODEOWNERS, Dependabot for GitHub Actions.
- README and README_HE: one-command install for any agent (`gh skill install`,
  `npx skills add`) and the per-agent skills folder table.

## [1.0.1] - 2026-08-29

- README and README_HE: Wispr Flow referral link and docs link (the 1.0.0 zip shipped without them).
- clients-folder.md: state.md is read by client-context and prep-call only; post-call never reads it.
- Workflows: third-party actions pinned by commit SHA.

## [1.0.0] - 2026-08-29

First public release. Four skills for voice-first client work, built for operators who
record calls with Wispr Flow (or any notetaker) and keep one folder per client.

- `post-call`: transcript to a reviewed doc with call facts, a short recap and a one-page
  scope. Guarded overwrite via `scripts/check-write-target.sh`. Drafts only.
- `prep-call`: seven-section cheatsheet before a call, register detection (formal vs
  conversational, Hebrew or English), never overwrites.
- `client-context`: one read-only board per client from local files, CRM export and
  Wispr meeting titles; conflicts flagged, never resolved.
- `sync-call-state`: one proposed diff (state entry + stage line), applied only after an
  explicit yes; idempotent; never touches an external system.
- Fixtures: `clients/_template/` and the fictional `dana-studio`.
- Tooling: ported 13-check skill validator, kit checks, giveaway lint, smoke install,
  release zip, version bump.
- Install paths: Claude Code plugin marketplace, `cp -r`, or the release zip.
