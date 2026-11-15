# 07: Verify the standalone selling release

**What to build:** The owner can install and use the standalone selling MVP with recorded evidence for the complete scan, review, mark, restore and deliberate-post journey.

**Blocked by:** 03: Scan bag items and retain observations; 06: Post all marked AH items and reconcile the batch.

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Run the production addon without external services or Auctionator dependency on the actual target platform; record client/platform builds, native market context and installation steps.
- [ ] Verify the full journey: inspect bags, scan multiple supported items at the AH, review ranking/destinations, mark/edit/remove quantities in the separate Inventory window, reload/logout, restore intent, review the whole marked list and use Post all through Copperwise's native AH tab, with only native-required additional clicks.
- [ ] Confirm only AH-marked items enter the posting queue; Vendor and unmarked items remain excluded, and vendor sales use the normal merchant UI.
- [ ] Cover multi-stack/transient holdings, missing and known-zero metadata, unsupported items, no scan, observed empty, partial/failed/cancelled scans, preserved cached observations and configurable stale warnings.
- [ ] Cover changed holdings, posting cancellation/failure, unresolved outcomes, duplicate prevention and confirmed partial completion with native owned-listing and bag reconciliation.
- [ ] Verify native fonts/controls/coin presentation, layout and readability at the owner's normal UI scale, normal AH navigation and coexistence with Auctionator installed.
- [ ] Record outcomes and limitations at the agreed public in-client boundary; syntax checks and passed historical probes alone do not establish release acceptance.

Other-faction/ruleset and incompatible-market client acceptance is deferred to
[ticket 08](08-verify-other-factions-and-rulesets.md); this release ticket verifies
the current supported environment and records that limitation.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.
