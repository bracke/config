# Prohibited patterns

- **No environment or file access in the core.** Never `with
  Ada.Environment_Variables`, `Ada.Text_IO`, `Ada.Directories`, or
  `Ada.Streams.Stream_IO` in `src/`. Sources feed the store; the I/O lives in
  `config_runtime`.
- **No clock reads in the core.** Never `with Ada.Calendar`. A TOML datetime is
  parsed from its text into components, not compared against the wall clock.
- **No exceptions across the public boundary.** Report failure with status
  values / results — missing keys, type mismatches, parse errors included.
- **No second JSON reader or number parser.** JSON and scalar typing go through
  `representation`.
- **No unbounded work.** Every key, value, entry count, array length, source
  count, and dotted-key depth is bounded by the types in `config.ads`.
- **No leaking secrets.** A key marked secret must be redacted before any dump
  renders it; never format a secret value into output.
- **No framework/persistence/transport coupling.** The core never `with`s `Web`,
  `Database`, `Httpclient`, `GNAT.Sockets`, etc.
