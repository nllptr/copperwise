# 16: Post the next queued item

**What to build:** At the auction house, the player reviews and posts the next eligible sale-queue item through supported user actions.

**Blocked by:** S15: Mark inventory items for sale; S08: Verify one native posting action.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Show current eligible bag quantity, explicitly chosen posting terms and identified recent price context before the user posts.
- [ ] Use the verified native action path to post the selected item without assuming a particular undercut, duration or one-click batch behavior; resolve required terms visibly.
- [ ] Update pending quantity only after confirmed success; preserve honest intent on failure, cancellation, changed availability or partial completion.
- [ ] Record actual-client evidence for a deliberate successful post and an unsuccessful or cancelled path; preserve normal AH behavior and client-required actions.

## Scope and verification

One-next-item rapid posting path, repeatable by the user; no unattended queue execution or pricing-rule engine.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
