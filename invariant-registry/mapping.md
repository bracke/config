# Invariant -> Evidence Mapping

| Invariant | Evidence (test / contract) | Status |
|-----------|----------------------------|--------|
| CFG-INV-001 | `Keys_Tests.Test_Valid_Keys`, `Test_Invalid_Keys`, `Test_Segments` (dotted-key grammar: valid/invalid, depth, segment access) | proven |
| CFG-INV-002 | `Store_Tests.Test_Bounds` (invalid-key/entry-capacity/pool refusal) | proven |
| CFG-INV-003 | `Store_Tests.Test_Override_Provenance` (later source overrides; winning source recorded) | proven |
| CFG-INV-010 | dependency-boundary audit in `check_config`; core `with`s only stdlib + representation | audited |

Remaining `CFG-INV-*` entries (004-009, see `docs/ai/invariants.md`) are
`planned`; each gains a row here when its owning package and test land (see
`docs/PHASE_STATUS.md`). At Phase 0 only the dependency boundary is enforceable.
