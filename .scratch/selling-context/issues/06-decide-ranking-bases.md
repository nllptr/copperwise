# 06: Choose explicit ranking bases

**What to build:** The owner can compare concrete ranking examples and settle the units used for Inventory and Crafting sorting.

**Blocked by:** S02: Explore the Crafting screen; S05: Verify recipe metadata and discovery.

**Status:** awaiting-owner — defaults approved; labels and tie/missing rules pending

**Labels:** awaiting-owner

**Type:** task

- [x] Use small examples where per-unit versus whole-owned-quantity inventory ranking gives a different order; distinguish auction uplift over vendor value from recorded profit.
- [x] Compare per-output versus per-craft margin rankings, including multi-output recipes, zero/negative margin and unavailable estimates.
- [ ] Record the owner-approved default, visible labels and tie/missing-estimate handling for each tab; do not equate approval of the ticket breakdown with approval of a formula.
- [x] Demonstrate the chosen order on examples through visible behavior or an inspectable decision table; carry unresolved choices forward explicitly if feedback is pending.

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

2026-11-14 owner decisions: Inventory ranks by max(total AH asking value,
total vendor sell value) for all counted units of each item kind; the same
comparison selects the AH/Vendor button. This replaces proposed uplift sorting.
Crafting ranks by estimated margin per craft, recalculating and re-sorting when
owned ingredients are consumed. Updated the decision table with chosen orders
and a holdings-depletion reversal. Exact labels, ties, missing estimates and
alternative sorts remain explicitly pending; neither default approval settles
those secondary rules. No production sorting code changed.

2026-11-14 owner follow-up: equal destination totals select Vendor to avoid
AH deposit risk for no additional asking value. If neither value is known,
retain the row without an action button. AH buttons require a warning icon
when the AH observation exceeds a configurable age threshold. S03 runtime
evidence confirms vendor metadata can be temporarily unavailable; handling
exactly one known destination, threshold default and exact presentation remain
pending. Recorded in the decision table; no production UI change claimed.

2026-11-14 owner clarification: omit the destination button whenever either
AH or vendor price is missing; both values are necessary to compare. Keep
the row visible. Default the stale-AH warning threshold to one hour and expose
it as an easily changed setting. Updated the decision table; remaining open
items are exact labels and numeric tie/missing-row ordering, not these policies.

2026-11-14 sidebar iteration requested: implemented compact Inventory rows
(icon, name with quantity, total best sale value, destination action), and
Crafting rows (icon, name, margin/craft, owned-input calculation indicator),
without sidebar headings. Browser study now exercises chosen ranking defaults,
missing-price action suppression and editable 60-minute AH warning threshold.
Added synthetic ingredient-depletion control. See the prototype README's S06
section for verification and review instructions. Owner visual review pending;
this does not establish production sorting or client transaction behavior.
