# 10: Show one bag item with scanned market context

**What to build:** The player selects one actual bag item in the main window and sees its quantity, vendor value and recent native-scan market context.

**Blocked by:** S03: Verify bag quantities and vendor values; M18: Probe native auction-house scanning; M05: Conclude Phase 0 and establish implementation contracts.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Connect actual supported bag data and a supported native AH query to one visible Inventory item and its selected-item detail.
- [ ] Show lowest observed buyout per unit, vendor sell value and stock within actual query coverage, with market identity, scan time and coverage status.
- [ ] Distinguish no scan, partial/failed scan, observed empty supply, bid-only coverage and unavailable vendor metadata without fabricating prices or zero stock.
- [ ] Keep scan observations separate from imported backend history and companion health; preserve the accepted companion import boundary.
- [ ] Demonstrate the complete selection-to-visible-result path in the target client and record controlled scenarios plus actual sample observations.

## Scope and verification

One supported item and native recent context, not the full catalog, historical merging or transaction queues. Production starts only after M05 passes or its explicit evidenced alternative is approved.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
