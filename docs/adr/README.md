# Architecture Decision Records

Short records of decisions that shape `config`.

## Decisions so far

- **ADR-0001 — One flat store keyed by dotted paths.** Nested structures (TOML
  tables, JSON objects) flatten to dotted keys and arrays become value lists, so
  every format reduces to the same entry model and typed access is
  format-agnostic.

- **ADR-0002 — Headless core with injected sources.** The core reads no
  environment and opens no files; sources are seams. Real env/file reading lives
  in `config_runtime`, mirroring the other headless crates.

- **ADR-0003 — Reuse `representation` for JSON and scalar typing.** The JSON
  source and the typed getters use representation's parser and scalar vocabulary
  rather than a second implementation. dotenv/INI/TOML parsers are config-owned.

- **ADR-0004 — Provenance and secret flags are first-class.** Each value records
  its winning source (auditable precedence) and whether it is secret (redacted on
  dump).
