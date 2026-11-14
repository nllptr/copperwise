# 13: Show one recipe's cost and estimated margin

**What to build:** For one supported learned recipe, the player sees complete per-output crafting cost alongside output buyout, vendor sell value and estimated margin.

**Blocked by:** S05: Verify recipe metadata and discovery; S10: Show one bag item with scanned market context.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Connect verified recipe quantities, source-appropriate ingredient unit costs and output yield to one selected recipe detail.
- [ ] Use vendor purchase prices for vendor-sourced inputs and lowest observed AH unit buyouts for AH-sourced inputs; identify observation sources and age.
- [ ] Compute per-output cost and estimated margin without a separate sale cut or refundable posting deposit. Preserve positive, zero and negative signs under display rounding.
- [ ] Withhold complete costs/margins for missing inputs, unresolved dual sources, ambiguous recipes or yields; do not price owned/gathered inputs at zero by default.
- [ ] Verify a multi-output controlled example and a target-client sample through visible results; label replacement-cost margin and excluded failed-listing losses clearly.

## Scope and verification

One recipe economics path, not a catalog sort, historical cost line, recursive crafting optimizer or craft execution.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
