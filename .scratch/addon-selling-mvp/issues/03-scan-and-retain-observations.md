# 03: Full market summary scan and retained observations

**What to build:** The player scans the full AH market from the Copperwise AH tab and can review the latest successful local observations after reload/logout and away from the AH on any character of the same account, with honest age and refresh status.

**Blocked by:** 02: Browse and rank bag items.

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Offer a user-initiated full-market summary scan in the Copperwise AH tab using all native browse pages with visible progress, throttling and cancellation; respect other AH activity and stop further work on AH closure.
- [ ] Keep each item's latest successful observation separate from its latest attempt state; failed/cancelled refreshes preserve previous usable results without advancing source time or completeness.
- [ ] Persist market scans account-wide so all characters on the same account
  can read compatible observations; retain comparable identity, native market
  context, source time and coverage, and never mix incompatible markets.
- [ ] Migrate existing per-character scan snapshots without losing observations
  or changing source times; retain the newer complete snapshot for each market
  rather than letting an older character's data overwrite it.
- [ ] Verify character A scans and saves on reload/logout, then character B
  logs in/reloads and sees the same compatible prices, supply and source time
  away from AH. Keep each character's bag holdings and sale intent separate.
- [ ] Treat complete empty observations as valid empty results with unavailable buyout; partial observations remain identifiable and cannot become complete comparison estimates.
- [ ] Restore cached observations across reload/logout and show age away from the AH without implying live or offline collection.
- [ ] Provide an easily changed stale-price threshold defaulting to one hour; warn on AH destination buttons only when source age exceeds it, with exactly one hour not exceeding it.
- [ ] Verify scanning multiple items, cancellation/coexistence, failed refresh preservation, persistence, market scoping and stale-warning boundaries through visible target-client behavior.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.

Owner clarification 2026-11-15 supersedes sequential bag-item scanning: use full
market summary scanning like Auctionator. The scan tab and baseline retained
snapshots are brought forward into revised ticket 01; this ticket completes their
coverage, persistence/scoping, stale configuration and integrated acceptance.
Inventory has no market request controls.

### Account-wide scans — owner decision 2026-11-15

The owner uses an AH-parked character to scan and wants an adventuring character
to use that data when sorting its own bags for vendor sale or manual mailing to
the auction character. Same account only; ordinary saved-variable persistence
across character switches is sufficient. No live cross-client synchronization,
mail automation or shared sale intent is required.

Current scans are per-character, so the acceptance above is implementation work,
not already passed. Account-wide bag/bank observations are only an undecided
future possibility without a sufficient use case; do not implement them here.
See the specification's account-wide data decision for the requirement and scope.

### Account-wide storage implementation — 2026-11-15

Implemented account-wide `CopperwiseAccountDB` for complete market snapshots.
Login migrates version-1 per-character snapshots, preserving source time and
native market keys; only a newer complete snapshot replaces a complete shared
snapshot. Equal timestamps keep the shared copy. Legacy character data remains
intact; holdings and sale intent are not copied into the shared store.

Supporting Lua checks cover cross-character reads, newer/older/equal migration,
partial/undated rejection, complete-empty results and market isolation. These
are supporting checks, not actual-client acceptance. The two-character
reload/logout journey and migration checks in the addon README remain pending;
this storage change does not close the broader scan ticket.

### Owner verification — 2026-11-15

After installing the updated addon and receiving the two-character verification
guide, the owner reported: "works as expected". Record the account-wide sharing
workflow as owner-reported passed in the target client. Separate checks for an
older legacy snapshot failing to overwrite newer shared data and incompatible
market isolation have not been individually confirmed. The broader ticket
remains open.
