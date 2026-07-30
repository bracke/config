# Phase status

Built phase-by-phase; each phase is buildable, its suite green, and committed.

| Phase | Scope | Status |
|-------|-------|--------|
| 0 | Repository & tooling foundation (skeleton, `check_config`, docs, invariant registry, green smoke test) | **done** |
| 1 | `Config.Keys` (dotted-key grammar) + `Config.Errors` + value-kind taxonomy | **done** |
| 2 | `Config.Store` (bounded flat map: dotted key -> value list + provenance + secret) | **done** |
| 3 | `Config.Sources` seam + layering/precedence/merge + typed access (`Get_*`) + redacted dump | planned |
| 4 | dotenv + INI parsers (bounded, injection-safe) | planned |
| 5 | JSON source via `representation` (objects -> dotted keys, arrays -> value lists) | planned |
| 6 | TOML parser (tables, arrays, typed scalars, datetimes, dotted keys) | planned |
| 7 | `config_runtime` adapter (env + file sources) + `Config.Testing` doubles + example | planned |
| 8 | Hardening (parser fuzz, precedence tests), docs/registry complete, `check_config --release` green -> V1 | planned |
