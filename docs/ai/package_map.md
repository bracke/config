# Package map

Current and planned packages. Behaviour lands phase-by-phase; the root is a pure
scalar vocabulary.

| Package | Role | Phase |
|---------|------|-------|
| `Config` (root) | Strong-scalar vocabulary: `API_Version`, bounded counts, text sizes, library identity. No behaviour. | 0 |
| `Config.Keys` | Dotted-key grammar + validation. | 1 |
| `Config.Errors` / `Config.Results` | Category taxonomy + generic result. | 1 |
| `Config.Values` | Value-kind taxonomy (String/Integer/Float/Boolean/Datetime/Array). | 1 |
| `Config.Store` | Bounded flat map: dotted key -> value list + provenance + secret. | 2 |
| `Config.Sources` | Source seam + precedence/merge. | 3 |
| `Config.Access` | Typed getters (required/default, validated) + redacted dump. | 3 |
| `Config.Parsers.Dotenv` / `.Ini` | Line-oriented parsers. | 4 |
| `Config.Parsers.Json` | JSON source via `representation`. | 5 |
| `Config.Parsers.Toml` | TOML parser. | 6 |
| `Config.Testing` | Deterministic in-memory sources / fixed env. | 7 |
