# 02: Browse and rank bag items

**What to build:** The Inventory window lists aggregated bag holdings, allows item selection and ranks complete AH/vendor comparisons from retained full-market summary observations using the approved destination rules.

**Blocked by:** None — ticket 01 resolved (2026-11-15).

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] List bag item kinds with icons, names and aggregated quantities; identify unsupported auction items and retain understandable missing-data states.
- [ ] Selecting a row changes detail independently of future marking controls
  and reads the retained full-scan observation for that item; selecting a row
  never sends a market query.
- [ ] Keep Full scan and cancellation exclusively in the Copperwise native AH
  tab. Missing Inventory data remains unavailable and directs the player there;
  do not add selected-item or sequential bag-item queries to Inventory.
- [ ] For the same owned quantity, show AH asking total and vendor sell total; rank complete comparisons by the larger total descending, then name and stable identity, with unavailable comparisons last.
- [ ] Choose Vendor on equal totals; withhold the destination action when either comparison value is unavailable, while keeping known numeric zero distinct.
- [ ] Refresh settled holdings and metadata without presenting transient stack moves/splits as actionable extra inventory.
- [ ] Verify multiple item selections, rankings, ties, zero and unavailable values and changed holdings through visible production-addon behavior in the target client.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.

### Full-scan workflow reconciliation — 2026-11-15

Owner requires an entire-market summary-mode scan like Auctionator. The native
Copperwise AH tab owns collection, progress and cancellation; standalone Inventory
is for reviewing/ranking holdings and later assigning AH/Vendor sale intent.
This replaces the original selected-item query criterion above. Reuse ticket 01's
retained snapshot interface and native commodity comparability restrictions.
Partial, failed or cancelled refreshes must not replace successful observations
or make their asking values appear newly observed.

Ticket 01's current acceptance checklist is the authoritative dependency status.
Its verified core workflow is recorded, but unverified edge cases remain open;
this edit does not silently waive the dependency or start ticket 02 implementation.

### Dependency resolved — 2026-11-15

Ticket 01 is now resolved using its recorded production-client evidence and the
owner-approved controlled diagnostics, which passed 7/7 in the target client.
Its current checklist distinguishes native observations from simulated edge
cases and records remaining evidence limits. Ticket 02 is unblocked; no ticket
02 implementation or acceptance is implied by this update.
