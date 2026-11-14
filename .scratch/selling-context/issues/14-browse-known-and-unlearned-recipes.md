# 14: Browse and rank known and unlearned recipes

**What to build:** The Crafting tab lists available profession recipes, optionally includes unlearned entries and sorts complete margin estimates.

**Blocked by:** S13: Show one recipe's cost and estimated margin; S06: Choose explicit ranking bases.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Use verified profession/catalog access to list supported recipes, disclosing incomplete discovery instead of presenting a fabricated complete catalog.
- [ ] Provide Include unlearned recipes with clear learned/craftable distinction and selected-output market detail.
- [ ] Apply the approved recipe ranking basis and missing-estimate rules, including multi-output, zero and negative examples.
- [ ] Verify selection, filtering and visible ordering in the target client. If an essential catalog capability failed, obtain a documented scope decision rather than silently dropping the requested option.

## Scope and verification

Recipe discovery and comparison only; obtaining recipes, automatic crafting and purchase-price estimates for recipe acquisition are excluded.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
