# 07: Choose queue and ownership rules

**What to build:** The owner can review small queue scenarios and settle quantity, lifecycle and counted-ownership semantics before transactions are built.

**Blocked by:** S02: Explore the Crafting screen; S04: Verify bank observations and freshness.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Resolve craft count versus desired output count, sale quantity selection, queue edits/removal and what intent persists across window changes, reload and logout.
- [ ] Choose an explicit cached-bank subtraction policy using the bank probe evidence; distinguish counted holdings, age, withdrawal needs and unknown availability.
- [ ] Resolve how shared owned ingredients are allocated across queued crafts without counting the same unit twice, and how quantity changes affect remaining needs.
- [ ] Record agreed policies with examples for cancelled, partial and successful actions; queue intent must not itself buy, post, craft or transfer anything.

## Scope and verification

One bounded queue-state decision document and example walkthrough; no broad transaction implementation or cross-character tracking.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
