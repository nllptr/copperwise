# 03: Prove target-client graphs and item interactions

**What to build:** An in-client capability probe demonstrates usable history rendering and access in the actual target client.

**Blocked by:** None (can start immediately).

**Status:** in-progress — sample-data addon probe implemented; awaiting actual client observations

- [ ] Render two aligned sample graphs with local time labels and record actual client/platform builds.
- [ ] Demonstrate a window accessible away from the auction house, a configurable open-window keybinding, and item-name lookup.
- [ ] Check readable tooltip additions and hovered-item or modifier-click capabilities while preserving existing game interactions.
- [ ] Record reproducible steps, outcomes, limitations, and evidence; do not treat installed addon source as runtime proof.

## Comments

2026-11-14: Implemented the standalone [client capability probe](../../../probes/client/README.md)
and [evidence report](../../../probes/client/REPORT.md). It uses two synthetic
sample items, aligned asking-price/stock graphs with local labels, sample-name
lookup, configurable game bindings, visible-tooltip item access, labelled sample
tooltip additions, and observation-only secure modifier-click hooks. No upstream
credentials or backend are required. Lua/XML parser checks do not constitute
client acceptance. The pre-agreed testing seam remains actual in-client
capability checks; no simulated runtime proof was substituted. All acceptance
checkboxes remain pending actual client/platform observations and verification
that normal game interactions are preserved.

