# Architecture

`config` is a headless, hexagonal configuration library: a bounded value core
with every external concern injected as a seam.

## Layers

```
   defaults   files (dotenv/INI/JSON/TOML)   environment   overrides
       \            |                          |            /
        \           v                          v           /
         `------> Config.Sources (injected)  <------------'
                        |  (precedence: low -> high)
                        v
                  Config.Store  (bounded flat map: dotted key -> value list,
                        |        + provenance + secret flag)
                        v
                  typed access:  Get_String / Get_Integer / Get_Boolean /
                        Get_Float / Get_Datetime / arrays (required/default,
                        validated, values-not-exceptions)
```

## Seams (injected, never reached into by the core)

- **`Config.Sources`** — each source yields entries (dotted key, value list,
  kind, secret) at a precedence layer. The core reads no environment and opens
  no files.

## Value model

The merged store is a **flat map**: a dotted key (`server.http.port`) maps to an
ordered list of raw string values (one for a scalar, many for an array), plus the
provenance (winning source) and a secret flag. Nested TOML tables and JSON
objects flatten to dotted keys; arrays become value lists. Typed access parses
each value on demand through `representation`'s scalar vocabulary.

## Why `representation`

Config values are typed scalars (string, integer, float, boolean, datetime).
`representation` already defines that vocabulary and a JSON codec, so typed
access and the JSON source reuse it rather than re-implementing parsing.

## What lives elsewhere

- Real environment + file sources → `config_runtime`.
- Deterministic doubles (in-memory sources, fixed env) → `Config.Testing`.
