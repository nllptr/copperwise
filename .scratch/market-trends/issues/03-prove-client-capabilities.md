# 03: Prove target-client graphs and item interactions

**What to build:** An in-client capability probe demonstrates usable history rendering and access in the actual target client.

**Blocked by:** None (can start immediately).

**Status:** completed — target-client capability gate passed for the tested sample paths

- [x] Render two aligned sample graphs with local time labels and record actual client/platform builds.
- [x] Demonstrate a window accessible away from the auction house, a configurable open-window keybinding, and item-name lookup.
- [x] Check readable tooltip additions and hovered-item or modifier-click capabilities while preserving existing game interactions.
- [x] Record reproducible steps, outcomes, limitations, and evidence; do not treat installed addon source as runtime proof.

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

2026-11-14: Completed from direct owner-reported runtime observations and saved
probe build evidence: client 1.60.1 (70938), interface 16001, local macOS 26.6.2
(25G83), x86_64. The owner confirmed graph changes and alignment, local time and
timezone, no-match behavior, opening away from the auction house, both bindings
persisting through `/reload`, Sharp Arrow tooltip and hover-open, and normal
Shift-link/stack/Ctrl-preview actions. Binding registration initially failed;
the manifest/category fix was retested successfully. See the report for the
exact evidence and remaining limits. Modifier-click shortcuts, combat behavior,
and exhaustive tooltip/other-addon combinations are not validated or promised.
Ticket 05 still depends on the other Phase 0 tickets.

