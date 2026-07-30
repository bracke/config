# Changelog

All notable changes to `config` are recorded here. The format follows
Keep a Changelog; the project is pre-1.0 and built phase-by-phase.

## [Unreleased]

### Phase 6 — TOML parser
- `Config.Parsers.Toml`: a bounded recursive-descent TOML parser covering
  comments, `[table]` headers with dotted names, dotted keys, basic/literal
  strings (single-line and multiline), integers (decimal/hex/octal/binary with
  `_` separators and sign, normalised to decimal), floats, booleans, datetimes
  (kept as text), scalar arrays (value lists), and inline tables (flattened to
  dotted keys). Array-of-tables (`[[t]]`) and arrays containing arrays/tables are
  reported as unsupported; malformed input is reported with a line, never raised
  (CFG-INV-007). All four formats now share one store model (CFG-INV-008).
- `Toml_Tests` suite (5 tests).

### Phase 5 — JSON source
- `Config.Parsers.Json`: parse a JSON object into a store using
  `Representation.JSON.Documents` (CFG-INV-009). Nested objects flatten to dotted
  keys, scalar arrays become value lists, numbers are typed integer/float by
  form, booleans via `Bool_Value`, and null members are omitted. A decode error,
  an unsupported structure (array of objects/arrays), an invalid key, or a store
  overflow is reported, never raised (CFG-INV-007). All three line-oriented and
  structured formats now reduce to the same store model (CFG-INV-008).
- `Json_Tests` suite (3 tests).

### Phase 4 — dotenv & INI parsers
- `Config.Parsers` parent (Parse_Status/Parse_Result) + `Config.Parsers.Scan`
  (trim + value unquoting: bare, single-quoted literal, double-quoted with
  \n \t \r \" \\ escapes).
- `Config.Parsers.Dotenv`: KEY=VALUE lines, '#' comments, optional `export `,
  quoted/bare values; keys validated as config keys.
- `Config.Parsers.Ini`: `[section]` headers (incl. nested `[a.b]`) forming dotted
  keys, `#`/`;` comments, quoted/bare values.
- Both are single-pass and bounded, reduce to the same store model
  (CFG-INV-008), and report the first malformed line rather than raising
  (CFG-INV-007).
- `Parser_Tests` suite (4 tests).

### Phase 3 — Sources, precedence & typed access
- `Config.Sources`: the source seam (`Load` populates a store, tagged with a
  provenance id). Applying sources in increasing precedence order yields layered
  config; a later source overrides an earlier one (CFG-INV-003).
- `Config.Sources.Memory`: an in-memory source (Set/Append staged, replayed by
  Load) for defaults/overrides and tests.
- `Config.Reader`: typed getters (`Get_String/Integer/Float/Boolean`) with
  required-vs-default and a `Lookup_Status` (Found/Missing/Invalid) — missing or
  unparseable values are reported, never raised (CFG-INV-004/005); integer/float
  via the language's validated 'Value with internal containment. `Dump` renders
  the effective config with secret keys redacted (CFG-INV-006).
- `Reader_Tests` suite (4 tests).

### Phase 2 — Bounded store
- `Config.Store`: a bounded, limited flat map from a dotted key to an ordered
  value list, each key carrying its kind, provenance (source id), and secret
  flag; keys/values live in one arena (no heap). `Set` replaces a key's value
  (later sources override earlier, CFG-INV-003); `Append` extends an array
  (with an in-place fast path and a copy path for interleaved growth). Capacity,
  value-slot, and pool exhaustion are refused (CFG-INV-002).
- `Store_Tests` suite (5 tests).

### Phase 1 — Keys, errors & value kinds
- `Config.Keys`: the dotted-key grammar (segments of `[A-Za-z0-9_-]` separated
  by `.`, bounded length/depth, no leading/trailing/double separator) with
  `Is_Valid_Key`, `Depth`, and `Segment`. Proves CFG-INV-001.
- `Config.Errors`: failure vocabulary reusing `Representation.Errors.Error_Category`
  + stable locale-neutral machine identifiers.
- `Config.Values`: the `Value_Kind` taxonomy (String/Integer/Float/Boolean/
  Datetime) with kind/boolean images and case-insensitive `Parse_Boolean`
  (true/false, yes/no, on/off, 1/0).
- `Keys_Tests` suite (6 tests).

### Phase 0 — Repository & tooling foundation
- Root `config` crate: `alire.toml`, `config.gpr`, and `src/config.ads` (root
  strong-scalar vocabulary: `API_Version`, bounded entry/value/source/segment
  counts, bounded text sizes, `Library_Name`/`Library_Version`).
- Crate skeletons: `tests/config_tests` (green smoke suite),
  `examples/config_examples` (quickstart), `tools/check_config`
  (required-surface + dependency-boundary audit + `--release` gate).
- Documentation skeleton and the `invariant-registry/mapping.md` `CFG-INV-*`
  scheme.
