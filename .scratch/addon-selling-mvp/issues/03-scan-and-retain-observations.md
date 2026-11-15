# 03: Full market summary scan and retained observations

**What to build:** The player scans the full AH market from the Copperwise AH tab and can review the latest successful local observations after reload/logout and away from the AH, with honest age and refresh status.

**Blocked by:** 02: Browse and rank bag items.

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Offer a user-initiated full-market summary scan in the Copperwise AH tab using all native browse pages with visible progress, throttling and cancellation; respect other AH activity and stop further work on AH closure.
- [ ] Keep each item's latest successful observation separate from its latest attempt state; failed/cancelled refreshes preserve previous usable results without advancing source time or completeness.
- [ ] Persist comparable identity, native market context, source time and coverage; prevent observations from incompatible markets or characters being mixed.
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
