# AI implementation guide — config

This crate is built phase-by-phase. Read this before modifying it.

## What this crate is

A headless, deterministic, bounded **configuration** library: layered sources →
one typed store keyed by dotted paths → typed, validated access.

## Hard rules

- **Headless core.** `src/` depends on Ada 2022 stdlib and `representation`
  only. No environment, file, transport, or persistence packages —
  `tools/check_config` forbids them by scanning `with` clauses.
- **No I/O in core.** The core reads no environment variables and opens no
  files. Sources feed the store through an injected seam; real env/file reading
  lives in `config_runtime`.
- **Values, not exceptions.** Missing keys, type mismatches, and parse errors
  are reported as status values / results, never raised.
- **Bounded everything.** Key length, value length, entry count, array length,
  source count, and dotted-key depth are all bounded (see `config.ads`).
- **Secrets are load-bearing.** A key marked secret must never have its value
  emitted by a config dump. Tested directly.
- **Reuse `representation`.** Scalar typing and JSON parsing come from
  `representation`; do not hand-roll a second JSON reader or number parser.

## Phase order

See `docs/PHASE_STATUS.md`. Each phase: buildable core (zero warnings), its
AUnit suite green, docs + invariant registry + CHANGELOG updated, one commit.
