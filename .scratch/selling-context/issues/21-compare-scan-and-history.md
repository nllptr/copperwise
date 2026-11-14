# 21: Compare local scans with imported history

**What to build:** A selected supported item shows recent local scan context beside accumulated backend history with distinct provenance and honest coverage.

**Blocked by:** S10: Show one bag item with scanned market context; M07: Accumulate and browse seven-day history.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Carry one supported item through backend persistence, companion cache/export and login/reload import, and show its history alongside actual local scan context.
- [ ] Display the lowest-buyout historical reference with aligned stock and separate source observation, import and local scan timestamps; preserve available secondary spread context without implying confidence.
- [ ] Identify the input source for each current comparison; resolve source selection explicitly and never silently merge minima, overwrite history or fill offline gaps with scans.
- [ ] Verify differing source ages, partial/failed scans, absent imported history and a successful scan; a fault in one source must not falsely invalidate the other.
- [ ] Demonstrate controlled public-pipeline inputs and target-client scan behavior; companion exports remain unchanged in the addon until login or user reload.

## Scope and verification

One-item source comparison and history integration, not a general observation-merge service or a claim that local scans collect while offline.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
