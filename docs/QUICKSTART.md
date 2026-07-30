# Quickstart

At Phase 0 the crate exposes only its root vocabulary; the runnable example in
`examples/config_examples/src/quickstart.adb` prints the library version and the
bounded limits, and is exercised by `check_config --release`.

```sh
cd examples/config_examples
alr -n build
./bin/quickstart
```

Later phases grow this into a full example: layer a dotenv file under an
environment override, read typed values with provenance, and show a redacted
dump.
