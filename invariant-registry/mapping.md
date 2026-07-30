# Invariant -> Evidence Mapping

| Invariant | Evidence (test / contract) | Status |
|-----------|----------------------------|--------|
| CFG-INV-001 | `Keys_Tests.Test_Valid_Keys`, `Test_Invalid_Keys`, `Test_Segments` (dotted-key grammar: valid/invalid, depth, segment access) | proven |
| CFG-INV-002 | `Store_Tests.Test_Bounds` (invalid-key/entry-capacity/pool refusal) | proven |
| CFG-INV-003 | `Store_Tests.Test_Override_Provenance` (later source overrides; winning source recorded) | proven |
| CFG-INV-004 | `Reader_Tests.Test_Typed_Access`, `Test_Missing_And_Invalid` (required-vs-default; missing/invalid reported) | proven |
| CFG-INV-005 | `Reader_Tests.Test_Missing_And_Invalid` (non-numeric/non-boolean reported, never raised) | proven |
| CFG-INV-006 | `Reader_Tests.Test_Redacted_Dump` (secret key rendered as placeholder; value absent) | proven |
| CFG-INV-007 | `Parser_Tests.Test_Dotenv_Malformed`, `Test_Ini_Malformed` (malformed dotenv/INI reported with line, never raised) | proven |
| CFG-INV-008 | `Parser_Tests.*`, `Json_Tests.*`, `Toml_Tests.*` (dotenv/INI/JSON/TOML parse to the same store model) | proven |
| CFG-INV-009 | `Json_Tests.Test_Json_Object`/`Test_Json_Arrays`/`Test_Json_Errors` (JSON parsed via `Representation.JSON.Documents`) | proven |
| CFG-INV-010 | dependency-boundary audit in `check_config`; core `with`s only stdlib + representation + cryptolib (Secure_Wipe) | audited |
| CFG-INV-011 | `Hardening_Tests.Test_Pool_Wiped_On_Clear` (used char-pool region observed all-zero after Clear; Clear/Finalize scrub via `CryptoLib.Secure_Wipe`) | proven |

Hardening (`Hardening_Tests`): `Test_Parser_Fuzz` (4000 random inputs through all
four parsers — none raises, the store stays within bounds) reinforces
CFG-INV-002/007; `Test_Precedence_Stress` reinforces CFG-INV-003.

All CFG-INV-001..011 are proven or audited. V1 is feature-complete: core (32
tests) + the four parsers (env/dotenv/INI/JSON/TOML) + the `config_runtime`
adapter.
