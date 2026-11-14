# 17: Queue one craft and subtract bag materials

**What to build:** The player queues a supported recipe and quantity and sees required ingredients, bag-owned materials and remaining shopping need.

**Blocked by:** S13: Show one recipe's cost and estimated margin; S07: Choose queue and ownership rules.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Use the agreed craft/output terminology, quantity edits and queue lifecycle for one supported recipe; do not imply execution of the craft.
- [ ] Expand ingredient requirements using verified quantities and yield, automatically subtract eligible observed bag materials and clamp remaining need at zero.
- [ ] Show required, bag-owned and remaining quantities and distinguish vendor inputs from AH shopping requirements without silently changing source costs.
- [ ] Verify no-material, partial-material, excess-material and changed-quantity cases through visible behavior, preserving an explicit missing-input state.

## Scope and verification

One recipe and bag subtraction only. Multiple queued recipes, bank subtraction and purchases are separate slices.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
