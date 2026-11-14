# 15: Mark inventory items for sale

**What to build:** The player marks supported inventory items and quantities for sale and finds the same pending selections when opening the AH workflow.

**Blocked by:** S11: Browse and sort supported bag items; S07: Choose queue and ownership rules.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Add, edit and remove sale intent using agreed quantity and persistence rules; clearly distinguish marking from a transaction.
- [ ] Carry the selected item identity and intended quantity between the main Inventory tab and the AH surface without reconstructing the list.
- [ ] Revalidate actual bag availability as inventory changes; do not assume intended or bank-held units are postable.
- [ ] Verify duplicates, quantity changes, removal and the agreed reload/logout lifecycle through visible behavior. No mark action may post an auction.

## Scope and verification

Sale intent and handoff only; the next ticket executes one queued post.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
