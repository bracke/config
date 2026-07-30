# Security

`config` is a headless library. Its security posture is about what a settings
loader can leak or be tricked into.

## Guarantees the core aims to uphold

- **Secret redaction.** A key marked secret is never emitted by a config dump;
  redaction is applied before rendering. Tested.
- **Parser safety.** The dotenv / INI / JSON / TOML parsers are bounded and
  reject malformed input deterministically (values, not exceptions); no input
  can drive unbounded memory use or crash the loader.
- **Provenance.** Every value records which source set it, so precedence and
  overrides are auditable (e.g. an env var overriding a file).
- **No ambient I/O.** The core performs no environment or file access; what a
  deployment exposes to the loader is decided by the injected sources.

## Non-goals

- Secret storage / encryption at rest is out of scope (a secrets manager's job);
  config only avoids *emitting* marked secrets.
- Transport of remote config is an adapter concern, not the core's.

## Reporting

Report suspected vulnerabilities to bent@bracke.dk.
