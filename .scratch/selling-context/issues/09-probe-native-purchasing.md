# 09: Verify one native purchasing action

**What to build:** An operator can review and purchase one selected sample auction through a minimal native Copperwise AH surface.

**Blocked by:** M18: Probe native auction-house scanning.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** prototype

- [ ] Record supported query/selection/purchase mechanisms, buyout and stack semantics, and the user actions required on the actual client.
- [ ] With an operator-selected sample and price, perform one deliberate purchase and record the confirmed transaction outcome and observed quantity.
- [ ] Demonstrate honest unavailable, changed or cancelled-result handling; do not silently purchase a replacement listing or treat a request as confirmation.
- [ ] Record native tab compatibility and failures; use Auctionator only as a fallback to investigate if native integration is not viable.

## Scope and verification

Single operator-driven capability transaction only; no queued shopping, automatic spending or claim that the minimum has sufficient quantity.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
