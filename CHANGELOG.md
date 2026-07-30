# Changelog

All notable changes to `config` are recorded here. The format follows
Keep a Changelog; the project is pre-1.0 and built phase-by-phase.

## [Unreleased]

### Phase 0 — Repository & tooling foundation
- Root `config` crate: `alire.toml`, `config.gpr`, and `src/config.ads` (root
  strong-scalar vocabulary: `API_Version`, bounded entry/value/source/segment
  counts, bounded text sizes, `Library_Name`/`Library_Version`).
- Crate skeletons: `tests/config_tests` (green smoke suite),
  `examples/config_examples` (quickstart), `tools/check_config`
  (required-surface + dependency-boundary audit + `--release` gate).
- Documentation skeleton and the `invariant-registry/mapping.md` `CFG-INV-*`
  scheme.
