# 01: Inspect one bag item with AH context

**What to build:** The player selects one real supported bag item in a standalone Inventory window and sees bag quantity, vendor sell value and a user-initiated native AH observation.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Install and open the production addon without a backend, API credentials, companion or Auctionator dependency; the Inventory window is separate from the native AH window.
- [ ] Show one supported commodity's comparable identity, settled bag quantity across stacks and vendor sell value; distinguish unavailable metadata from known zero and avoid actionable transient double counts.
- [ ] At the AH, perform a bounded user-initiated query and show lowest observed buyout per unit, covered supply, market context, source time and completeness in the selected item's detail.
- [ ] Distinguish no scan, metadata loading, partial, failed, cancelled and complete empty results; no missing buyout becomes zero and incomplete observations cannot drive a destination recommendation.
- [ ] Respect native throttling and other AH activity; cancellation or AH closure stops further requests and late responses do not replace a cancelled result.
- [ ] Verify the selection-to-query-to-visible-result journey in the actual target client against native quantity/price observations; record build, context and limitations.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.

Implementation prepared in `addons/Copperwise/` with standalone `/cw` Inventory,
settled bag snapshots, explicit native commodity queries and separate attempt /
last-complete observation display. Target-client acceptance remains pending;
see `addons/Copperwise/README.md` for the production workflow checklist and limits.
The ticket remains open until actual client evidence verifies the acceptance list.
