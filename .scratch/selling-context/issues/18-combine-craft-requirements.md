# 18: Combine queued crafts without double counting

**What to build:** The player queues more than one craft and sees combined shopping requirements that use each owned ingredient unit at most once.

**Blocked by:** S17: Queue one craft and subtract bag materials.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Aggregate shared ingredient identities across queued recipes and craft quantities, retaining vendor/AH source distinctions and unresolved-source feedback.
- [ ] Apply the agreed allocation policy so owned materials are credited once across the queue; show explainable combined required, owned and remaining amounts.
- [ ] Project guaranteed outputs of covered earlier crafts to later entries; allow reordering and recalculate after edits, removal and observed bag changes without duplicated credit.
- [ ] Show green/yellow/red row borders plus full/partial/no coverage counts and tooltip breakdowns. Generate shopping requirements for the whole ordered queue, crediting earlier explicitly queued producers after their missing inputs are supplied.
- [ ] Verify a small two-recipe shared-ingredient scenario and an over-supply case at the visible behavior boundary; do not add recursive subcraft planning.

## Scope and verification

Combined requirements, ordered projected outputs and existing bag subtraction;
apply S07 policy without adding bank implementation or transaction execution.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.

2026-11-14: Apply owner-approved [S07 rules](../queue-rules.md), including
ordered manually queued producers and distinct current-coverage versus full-plan
shopping calculations. Automatic recursive recipe discovery/insertion remains
excluded. Verify partial producer coverage, reordering, producer removal and
conversion from projected outputs to observed bags without double credit.
