# 02: Browse and rank bag items

**What to build:** The Inventory window lists aggregated bag holdings, allows item selection and ranks complete AH/vendor comparisons using the approved destination rules.

**Blocked by:** 01: Inspect one bag item with AH context.

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] List bag item kinds with icons, names and aggregated quantities; identify unsupported auction items and retain understandable missing-data states.
- [ ] Selecting a row changes detail independently of future marking controls; allow user-initiated selected-item queries using the integrated scan path.
- [ ] For the same owned quantity, show AH asking total and vendor sell total; rank complete comparisons by the larger total descending, then name and stable identity, with unavailable comparisons last.
- [ ] Choose Vendor on equal totals; withhold the destination action when either comparison value is unavailable, while keeping known numeric zero distinct.
- [ ] Refresh settled holdings and metadata without presenting transient stack moves/splits as actionable extra inventory.
- [ ] Verify multiple item selections, rankings, ties, zero and unavailable values and changed holdings through visible production-addon behavior in the target client.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.
