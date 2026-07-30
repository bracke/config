# Fuzzing

Fuzz harnesses for `config` land in Phase 8: random byte streams are fed through
the dotenv / INI / JSON / TOML parsers to prove they reject malformed input
deterministically and stay bounded (no unbounded memory, no crash). Placeholder
until then.
