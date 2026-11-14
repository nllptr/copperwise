# 18: Combine queued crafts without double counting

**What to build:** The player queues more than one craft and sees combined shopping requirements that use each owned ingredient unit at most once.

**Blocked by:** S17: Queue one craft and subtract bag materials.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Aggregate shared ingredient identities across queued recipes and craft quantities, retaining vendor/AH source distinctions and unresolved-source feedback.
- [ ] Apply the agreed allocation policy so owned materials are credited once across the queue; show explainable combined required, owned and remaining amounts.
- [ ] Recalculate after recipe quantity edits, removal and observed bag changes without negative requirements or duplicated credit.
- [ ] Verify a small two-recipe shared-ingredient scenario and an over-supply case at the visible behavior boundary; do not add recursive subcraft planning.

## Scope and verification

Combined requirements and existing bag subtraction only; no new bank policy or transaction execution.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
