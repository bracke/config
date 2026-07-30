# Invariant -> Evidence Mapping

| Invariant | Evidence (test / contract) | Status |
|-----------|----------------------------|--------|
| CFG-INV-010 | dependency-boundary audit in `check_config`; core `with`s only stdlib + representation | audited |

Remaining `CFG-INV-*` entries (001-009, see `docs/ai/invariants.md`) are
`planned`; each gains a row here when its owning package and test land (see
`docs/PHASE_STATUS.md`). At Phase 0 only the dependency boundary is enforceable.
