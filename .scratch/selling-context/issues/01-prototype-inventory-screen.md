# 01: Explore the Inventory screen

**What to build:** The owner can select a synthetic owned item in an Inventory tab and inspect its market detail in a disposable prototype.

**Blocked by:** None (can start immediately).

**Status:** in-progress — browser prototype implemented; owner feedback and target-client readability pending

**Labels:** ready-for-agent

**Type:** prototype

- [x] Show a small, clearly synthetic bag-item list with quantities and a selected-item detail panel; selection changes the displayed item without requiring tooltip interaction.
- [x] Bring lowest buyout, vendor sell value and aligned price/stock history together with units, observation age, timezone and actual coverage; distinguish missing observations from observed empty supply.
- [x] Show an understandable mark-for-sale affordance as intent only; do not imply a working posting integration or approved ranking formula.
- [ ] Review the screen at a realistic addon window size; record owner feedback and which details are browser-only versus already verified client capabilities.

## Scope and verification

Disposable UX only; no production backend, contracts or game transactions. Preserve the earlier history study as evidence, not proof of this new layout.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.

2026-11-14: Implemented the [Inventory browser study](../../../probes/ui-inventory/README.md)
with synthetic bag selection, lowest-buyout/vendor comparisons, aligned ranges,
empty/missing states and temporary mark/unmark intent. Browser interaction checks
and rendering review are recorded in the study. Owner feedback and actual-client
readability remain pending; the fourth acceptance item is intentionally open.

2026-11-14 owner feedback: compact the layout, list all inventory items, show
AH value (lowest unit buyout × owned count) and vendor value (unit vendor sell
value × owned count), and add Include bank to count bank holdings when checked.
Implemented in the browser study with eleven bag item types and one bank-only
item, separate bag/bank counts, cached-bank age and withdrawal guidance. Actual
client metadata/access and crafting bank-subtraction policy remain separate work.
