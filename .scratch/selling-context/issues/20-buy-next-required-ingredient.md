# 20: Buy the next required AH ingredient

**What to build:** At the auction house, the player reviews a queued ingredient's remaining need and purchases a supported quantity through the native workflow.

**Blocked by:** S18: Combine queued crafts without double counting; S09: Verify one native purchasing action.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Present remaining AH-sourced need, current listing/quantity/price and its difference from the earlier cost estimate; keep vendor requirements separate.
- [ ] Use the verified user-initiated buying path and actual client stack semantics; do not assume enough units exist at the minimum or silently buy substitutes.
- [ ] Reconcile confirmed purchase quantities with observed ownership and remaining need without crediting both the purchase and resulting bag change twice.
- [ ] Preserve correct remaining requirements for partial purchases, changed prices, exhausted listings, cancellation and failure; unknown outcomes do not count as success.
- [ ] Record target-client evidence for a deliberate purchase and a partial/unavailable/cancelled path. Use current eligible ownership, including the bank-aware path when that slice is available.

## Scope and verification

One-next-ingredient path that can be repeated deliberately; no unattended spending, automatic vendor buying or craft execution.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
