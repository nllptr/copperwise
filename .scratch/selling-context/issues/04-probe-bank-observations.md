# 04: Verify bank observations and freshness

**What to build:** A target-client probe demonstrates what current-character bank holdings can be observed and what remains cached after bank access ends.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** prototype

- [ ] Display sample bank counts separately from bag counts and record the client/platform build and bank-access conditions.
- [ ] Observe a sample deposit/withdrawal and document when the bank count can actually be refreshed.
- [ ] After leaving bank access and after a user reload where applicable, distinguish confirmed, cached and unknown counts and expose the last observation time.
- [ ] Record limitations without selecting a subtraction policy or claiming access to unseen or other-character holdings.

## Scope and verification

Read-only observation probe; automatic withdrawals, transfers and cross-character tracking are excluded.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
