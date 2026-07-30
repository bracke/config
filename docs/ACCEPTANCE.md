# Acceptance

V1 acceptance criteria for `config`. Each maps to evidence in
`invariant-registry/mapping.md` and is gated by `check_config --release`.

| # | Criterion | Evidence (target) |
|---|-----------|-------------------|
| A1 | Core is headless: `with`s only stdlib + `representation` | `check_config` dependency-boundary audit |
| A2 | Dotted keys have a validated grammar; the store is bounded | `Keys_Tests`, `Store_Tests` |
| A3 | Later sources override earlier by precedence; provenance is recorded | `Sources_Tests` |
| A4 | Typed access parses correctly with required-vs-default and validation | `Access_Tests` |
| A5 | Missing keys / type mismatches / parse errors are values, never raised | `Access_Tests`, `Parser_Tests` |
| A6 | dotenv / INI / JSON / TOML parse to the same entry model | `Parser_Tests` |
| A7 | Parsers are bounded and reject malformed input deterministically | `Parser_Tests`, `Hardening_Tests` |
| A8 | A secret-marked key is never emitted by a config dump | `Redaction_Tests` |
