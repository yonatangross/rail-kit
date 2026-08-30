# Security

rail-kit is four Markdown skill files plus one bash guard script. It stores no
credentials, makes no network calls of its own, and never writes outside the
`clients/<name>/` folder the operator points it at.

## Reporting

Email security@yonyon.ai, or open a private security advisory on GitHub
(Security tab, "Report a vulnerability"). Expect an acknowledgement within 3
working days. Please do not file public issues for anything that could expose an
operator's client data.

## What counts

- A skill writing outside its declared paths, or sending anything.
- Prompt-injection paths: text inside a transcript or client file that makes a
  skill act on it as an instruction (the fixtures carry a planted line for this).
- A release artifact that differs from the tagged source (releases carry a
  Sigstore provenance attestation; verify with `gh attestation verify`).

## Supported versions

Only the latest release tag is supported.
