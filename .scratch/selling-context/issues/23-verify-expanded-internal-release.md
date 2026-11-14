# 23: Verify the expanded internal release

**What to build:** The owner can run the connected inventory, crafting and native AH journeys on the target platform with recorded acceptance evidence.

**Blocked by:** S14: Browse and rank known and unlearned recipes; S16: Post the next queued item; S19: Make shopping requirements bank-aware; S20: Buy the next required AH ingredient; S22: Show one recipe's historical cost line; M16: Verify the complete original internal release.

**Status:** ready-for-agent

**Labels:** ready-for-agent

**Type:** task

- [ ] Record actual client/platform builds and execute Inventory selection/ranking, sale marking and a deliberate next-item post with observed outcomes.
- [ ] Exercise recipe browsing including the supported unlearned path, craft quantities, combined requirements, visible bag/bank ownership and deliberate ingredient purchasing.
- [ ] Verify integration between bank-aware requirements and purchasing, partial/failure handling, queue lifecycle and source selection without double counting or unintended transactions.
- [ ] Run the confirmed backend/companion/addon acceptance path plus extended actual-client checks for native scans and transactions; preserve history import, age, outage and retention behavior.
- [ ] Record owner feedback, remaining limitations and supported alternatives. Do not infer production acceptance from prototypes, inherited checkboxes or source inspection, and do not add new features in this verification ticket.

## Scope and verification

Integration and release evidence for already-delivered slices, not a catch-all implementation ticket. Other-character tracking and full TSM parity remain excluded.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
