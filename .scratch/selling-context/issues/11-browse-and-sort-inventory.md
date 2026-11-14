# 11: Browse and sort supported bag items

**What to build:** The Inventory tab lists supported bag items, selects their detail and sorts available estimates using the agreed ranking basis.

**Blocked by:** S10: Show one bag item with scanned market context; S06: Choose explicit ranking bases.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Extend the one-item path to the supported bag list, preserving item identity and quantity updates without mixing incompatible variants.
- [ ] Selecting or finding a listed item updates shared market detail; unsupported and missing-market-data rows remain clearly identified.
- [ ] Implement the agreed Inventory sort basis and visible units, with deterministic treatment of negative, zero, tied and unavailable comparisons.
- [ ] Verify changed bag contents and sample sort orders at the public client UI boundary; do not label vendor uplift as actual acquisition-cost profit.

## Scope and verification

Bag browsing and sorting only. Bank visibility and marking/posting remain separate slices.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.

2026-11-14 S06 handoff: use the owner-selected defaults in
[the ranking decision table](../ranking-bases.md#owner-decision). Inventory
sorts by the higher total AH/vendor value for all counted units; ties select
Vendor. Keep rows with missing prices, but omit destination buttons if either
price is missing. AH buttons require a stale-observation warning above an
easily changed threshold defaulting to 60 minutes. This is a UI requirement
for future implementation, not a claim of completed production behavior.
