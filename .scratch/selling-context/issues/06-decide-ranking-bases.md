# 06: Choose explicit ranking bases

**What to build:** The owner can compare concrete ranking examples and settle the units used for Inventory and Crafting sorting.

**Blocked by:** S02: Explore the Crafting screen; S05: Verify recipe metadata and discovery.

**Status:** awaiting-owner — comparison tables prepared; ranking policies unapproved

**Labels:** awaiting-owner

**Type:** task

- [x] Use small examples where per-unit versus whole-owned-quantity inventory ranking gives a different order; distinguish auction uplift over vendor value from recorded profit.
- [x] Compare per-output versus per-craft margin rankings, including multi-output recipes, zero/negative margin and unavailable estimates.
- [ ] Record the owner-approved default, visible labels and tie/missing-estimate handling for each tab; do not equate approval of the ticket breakdown with approval of a formula.
- [ ] Demonstrate the chosen order on examples through visible behavior or an inspectable decision table; carry unresolved choices forward explicitly if feedback is pending.

## Scope and verification

Focused policy/UX decision, not implementation of a pricing-rule engine or a personal cost ledger.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.

2026-11-14: S02 and S05 completion verified. Prepared the inspectable
[ranking decision table](../ranking-bases.md), including reversed orders,
multi-output recipes, ties, zero/negative and unavailable estimates. Proposed
defaults and labels are explicitly unapproved; owner feedback is required to
settle them. No production pricing or sorting code changed. The last two
acceptance items remain open until the owner's decisions are recorded.
