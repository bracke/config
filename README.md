# config

Headless **configuration** for Ada 2022 — a general settings loader for the
whole stack, not tied to any one application.

`config` loads settings from **layered sources** (defaults, files, environment,
explicit overrides) into one bounded, typed **store** keyed by dotted paths. It
tracks each value's **provenance** (which source it came from), marks **secrets**
for redaction, and offers **typed access** (string / integer / float / boolean /
datetime / arrays) with required-vs-default and validation. Values are reported,
never raised.

## Formats

V1 reads **environment variables**, **dotenv** (`KEY=value`), **INI**
(`[section]` + `key=value`), **JSON** (via `representation`), and **TOML**.

## Boundary

The core (`src/`) depends on Ada 2022 stdlib and `representation` only. It reads
no environment and opens no files — every source is an injected seam, enforced by
`tools/check_config`. Real environment and file reading live in the sibling
`config_runtime` adapter; deterministic test doubles live in `Config.Testing`.

## Status

`0.1.0-dev`, built phase-by-phase. See `docs/PHASE_STATUS.md`.

## Layout

- `src/` — the headless core library.
- `tests/config_tests/` — AUnit suite (`alr build && ./bin/tests`).
- `examples/config_examples/` — runnable examples exercised by the release check.
- `tools/check_config/` — required-surface + dependency-boundary + release gate.
- `docs/`, `invariant-registry/` — architecture and the `CFG-INV-*` mapping.

## License

MIT OR Apache-2.0 WITH LLVM-exception.
