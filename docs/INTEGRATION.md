# Integration

How a crate or application consumes `config`.

## Depend on it

```toml
[[depends-on]]
config = "*"

[[pins]]
config = { path = "../config" }
```

Add `config_runtime` too when you want ready-made environment and file sources;
depend on `config` alone if you supply your own sources.

## Shape of use (target API, filled in across phases)

1. Build a `Config.Store` by applying sources in precedence order (defaults, then
   files, then environment, then explicit overrides).
2. Read typed values: `Port : constant := Get_Integer (Cfg, "server.port",
   Default => 8080)`, with required-vs-default and validation; failures are
   reported, not raised.
3. Dump the effective config for diagnostics — secret-marked keys are redacted.

## Boundary contract

The core forbids environment/file/transport/persistence dependencies; consumers
inject those. See `docs/ai/allowed_dependencies.md`.
