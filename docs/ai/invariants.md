# Invariants (CFG-INV-*)

Normative invariants for `config`. Evidence is tracked in
`invariant-registry/mapping.md`; each becomes `proven` when its package + tests
land.

- **CFG-INV-001** — Dotted keys have a validated grammar (non-empty segments,
  bounded length/depth, safe character set); invalid keys are rejected.
- **CFG-INV-002** — The store is bounded in every dimension (entries, values per
  key, key/value sizes); over-limit input is rejected deterministically.
- **CFG-INV-003** — A later source (higher precedence) overrides an earlier one
  for the same key; the winning source is recorded as provenance.
- **CFG-INV-004** — Typed access parses a value to its type with required-vs-
  default semantics; a missing required key is reported, not defaulted silently.
- **CFG-INV-005** — Missing keys, type mismatches, and parse errors are values,
  never exceptions.
- **CFG-INV-006** — A key marked secret never has its value emitted by a config
  dump (redaction precedes rendering).
- **CFG-INV-007** — Parsers are bounded and injection-safe: malformed dotenv /
  INI / JSON / TOML is rejected deterministically without unbounded work.
- **CFG-INV-008** — dotenv, INI, JSON, and TOML all reduce to the same entry
  model (dotted key -> value list), so typed access is format-agnostic.
- **CFG-INV-009** — JSON parsing and scalar typing go through `representation`;
  the core contains no second JSON reader or number parser.
- **CFG-INV-010** — The core `with`s only the Ada stdlib and `representation`;
  the dependency boundary is audited by `check_config`.
