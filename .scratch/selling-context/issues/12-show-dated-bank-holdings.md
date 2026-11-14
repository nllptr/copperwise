# 12: Show dated bank holdings in Inventory

**What to build:** The player can include observable current-character bank holdings and distinguish them from immediately available bag items.

**Blocked by:** S04: Verify bank observations and freshness; S10: Show one bag item with scanned market context.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Provide optional bank inclusion using verified observation behavior, with bag and bank quantities distinct for each supported item.
- [ ] Expose bank observation age and cached/unknown states; refresh counts only when the supported client permits observation.
- [ ] Flag bank withdrawal needs rather than representing those units as immediately postable or usable in bags.
- [ ] Verify bank access, changed holdings and leaving bank access through the actual client; do not imply other-character coverage.

## Scope and verification

Current-character bank presentation only; owned-material subtraction is implemented later under the chosen policy.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
