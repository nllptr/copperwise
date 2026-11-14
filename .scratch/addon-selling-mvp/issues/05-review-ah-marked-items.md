# 05: Review AH-marked items in the native AH tab

**What to build:** A Copperwise tab inside the native AH window shows only AH-marked items and lets the player review one eligible item's posting terms without submitting a transaction.

**Blocked by:** 04: Mark and maintain sale intent.

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Create a Copperwise tab inside the native AH window following the probes' integration approach; retain the separate Inventory marking window and normal native navigation.
- [ ] Populate the posting queue only from explicit Sell on AH intent, including after persistence restoration; Vendor-marked and unmarked holdings never become posting candidates automatically.
- [ ] Show intended and currently executable quantities and retain shortages; select a revalidated supported bag stack for one posting review without requiring automatic stack consolidation.
- [ ] Review item identity, chosen quantity, unit/total buyout, native duration, native-calculated deposit and identified price context; allow deliberate term selection without a mandated undercut strategy.
- [ ] Invalidate or require renewed review when source identity, holdings, eligibility or terms change; cancellation and AH closure discard preparation without discarding intent.
- [ ] Verify the two-window handoff, queue filtering, source-stack limits, invalidation, cancellation, native tab layout and Auctionator coexistence in the actual client; this slice submits no posts.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.
