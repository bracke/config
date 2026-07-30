# Contributing

`config` follows the conventions of the sibling headless crates
(`navigation`, `validation`, `representation`, `logging`).

## Toolchain

- `gnat_native = "=15.2.1"`, `aunit = "^26.0.0"` in test crates.
- Compiler switches on every `.gpr`: `-gnat2022 -gnatyM120 -gnatX -gnata`
  (tools drop `-gnata`). Binder `-Es`.
- Zero-warnings bar, enforced by discipline and `tools/check_config`.

## Before each commit

```sh
cd config && alr -n build                              # core, zero warnings
cd tests/config_tests && alr -n build && ./bin/tests   # AUnit suite green
```

For a release-level check:

```sh
cd tools/check_config && alr -n build
./bin/check_config --release
```

## Rules

See `AI.md` and `docs/ai/prohibited_patterns.md`. The core stays headless
(stdlib + `representation` only), reads no environment, opens no files, and
reports failure through values rather than exceptions.
