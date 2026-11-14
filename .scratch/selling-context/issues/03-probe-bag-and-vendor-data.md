# 03: Verify bag quantities and vendor values

**What to build:** A target-client probe displays actual bag quantities and vendor sell values for a few comparable sample items.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** prototype

- [ ] Record the actual client/platform build and supported item/container metadata access used; show counts for selected sample bag items.
- [ ] Move or split a sample stack and verify the displayed count reflects observed changes without double counting.
- [ ] Distinguish vendor sell value from vendor purchase price, and known zero value from unavailable metadata.
- [ ] Record actual-client outcomes, item-identity limitations and failures; syntax checks or third-party source alone do not pass the probe.

## Scope and verification

Read-only capability probe, independent of API credentials. Does not establish bank, alt or transaction access.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
