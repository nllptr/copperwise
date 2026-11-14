# 22: Show one recipe's historical cost line

**What to build:** The player compares one recipe output's buyout history with a separate contemporaneous per-output crafting-cost line and applicable vendor baseline.

**Blocked by:** S13: Show one recipe's cost and estimated margin; S21: Compare local scans with imported history.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Carry timestamped recipe/ingredient/vendor inputs through backend history publication, companion cache/export and addon rendering for one supported recipe.
- [ ] Use the same verified recipe/source/yield cost semantics as the current estimate; choose and document temporal validity/alignment from evidence rather than projecting today's component prices backward.
- [ ] Render cost and output buyout references against the same time domain as stock; identify absent or changing vendor metadata rather than inventing a historical baseline.
- [ ] Leave a missing-input interval incomplete and withhold associated margin without zero-cost ingredients or future input reuse; preserve age, coverage and retention rules.
- [ ] Verify controlled changing-component sequences through the real pipeline at login/reload, including incomplete inputs and non-positive margins, with target-client readability evidence.

## Scope and verification

One recipe historical economics path; no full recipe-history optimizer, unbounded cache or retroactive synthetic price filling.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
