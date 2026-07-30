# Release checklist

The release gate is `tools/check_config`. It runs in three levels:

- **(default)** — required-surface audit + dependency-boundary audit (core
  `with`s only stdlib + `representation`).
- **`--release`** — the above, plus: build the library, build and run the AUnit
  tests, build and run the examples.
- **`--release-strict`** — the above, plus: require clean git worktrees for
  `config` and `project_tools`.

```sh
cd tools/check_config && alr -n build
./bin/check_config                 # surface + boundary
./bin/check_config --release       # + build/test/examples
```

V1 is declared feature-complete only when every release-critical `CFG-INV-*`
invariant maps to green evidence in `invariant-registry/mapping.md` and
`check_config --release` passes.
