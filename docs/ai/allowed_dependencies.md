# Allowed dependencies (core)

The `config` core (`src/`) may depend on:

- **Ada 2022 standard library** — bounded strings, numerics, characters. Not
  `Ada.Environment_Variables`, `Ada.Text_IO`, `Ada.Directories`,
  `Ada.Streams.Stream_IO`, or `Ada.Calendar`.
- **`representation`** — typed scalar vocabulary and the JSON codec used by the
  JSON source and typed access.
- **`cryptolib`** — the pure memory-hygiene primitive `Secure_Wipe`, so the
  store can zero secret material from its char pool on clear/finalisation. It is
  preelaborable and does no I/O, clock, or transport, so it does not weaken the
  headless boundary.

Everything else is **forbidden in the core** and enforced by
`tools/check_config` (it scans `with` clauses in `src/`):

`Web`, `Webframework`, `Authorization`, `Identity`, `Database`, `Tables`,
`Forms`, `Jobs`, `Notifications`, `Logging`, `Templates`, `I18n`, `Messages`,
`Httpclient`, `Smtplib`, `GNAT.Sockets`, `GNAT.OS_Lib`,
`Ada.Environment_Variables`, `Ada.Text_IO`, `Ada.Directories`, `Ada.Calendar`,
`Ada.Streams.Stream_IO`.

Real environment and file sources live in the `config_runtime` adapter crate;
deterministic doubles live in `Config.Testing`.
