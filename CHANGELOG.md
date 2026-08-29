# Changelog

All notable changes to rail-kit. Semver, one version for the whole kit.

## [Unreleased]

- README: Wispr Flow referral link and docs link.

## [1.0.0] - 2026-08-30

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
