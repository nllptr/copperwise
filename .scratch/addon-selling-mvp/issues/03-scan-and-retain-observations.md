# 03: Full market summary scan and retained observations

**What to build:** The player scans the full AH market from the Copperwise AH tab and can review the latest successful local observations after reload/logout and away from the AH on any character of the same account, with honest age and refresh status.

**Blocked by:** None — ticket 02 resolved (2026-11-15).

**Status:** resolved — current-environment acceptance passed; additional-market checks deferred to 08

**Labels:** accepted

- [x] Offer a user-initiated full-market summary scan in the Copperwise AH tab using all native browse pages with visible progress, throttling and cancellation; respect other AH activity and stop further work on AH closure.
- [x] Keep each item's latest successful observation separate from its latest attempt state; failed/cancelled refreshes preserve previous usable results without advancing source time or completeness.
- [x] Persist market scans account-wide so all characters on the same account
  can read compatible observations; retain comparable identity, native market
  context, source time and coverage, and never mix incompatible markets.
- [x] Preserve account-wide data through future schema upgrades, including skipped
  releases; keep unsupported data intact. Pre-account-wide migration was waived
  by the owner on 2026-11-15.
- [x] Verify character A scans and saves on reload/logout, then character B
  logs in/reloads and sees the same compatible prices, supply and source time
  away from AH. Keep each character's bag holdings and sale intent separate.
- [x] Treat complete empty observations as valid empty results with unavailable buyout; partial observations remain identifiable and cannot become complete comparison estimates.
- [x] Restore cached observations across reload/logout and show age away from the AH without implying live or offline collection.
- [x] Provide an easily changed stale-price threshold defaulting to one hour; warn on AH destination buttons only when source age exceeds it, with exactly one hour not exceeding it.
- [x] Verify scanning multiple items, cancellation/coexistence, failed refresh preservation, persistence, market scoping and stale-warning behavior through visible target-client behavior, with exact boundaries covered by approved synthetic tests. Other-market client verification is deferred to ticket 08.

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

### Compatibility scope update — 2026-11-15

The owner waived pre-account-wide migration because they are the sole user;
older-character overwrite acceptance is no longer required. Removed that import
path. Account-wide version 1 remains readable. Added a versioned loader with a
sequential migration registry for future schema updates, copy-before-upgrade and
publish-on-success behavior. Unknown/malformed stores are preserved and market
reads/scans are disabled with an explanation. No schema upgrade is needed today;
each future schema change must supply its migration and behavior tests.

### Post-update owner verification — 2026-11-15

After the storage-loader update, the owner reported "it works as expected" for
the requested client checks: existing account-wide prices, supply and source
timestamp remain available after reinstall/restart; another character on the
same realm/faction reads those observations; a new full scan completes and
survives `/reload`. Record these checks as owner-reported passed. No legacy
migration check is required. Incompatible-market client verification and the
remaining broader scan-ticket acceptance are not covered by this confirmation.


### Ticket 03 implementation — 2026-11-15

Added `/cw stale <positive minutes>` with a per-character persisted threshold,
default 60 minutes. AH recommendations show a warning strictly after the
threshold; Vendor/unavailable comparisons do not. Source times are unchanged.
Destination marking buttons remain ticket 04 scope and must reuse this warning
behavior when introduced. Existing settings and sale intent are preserved.

Owner approved synthetic tests through public UI/events with simulated WoW APIs
and time. Current-production scan tests cover cumulative pagination/readiness,
cancellation, AH closure/tab changes, competing requests, failed/timeout refreshes,
late results, reopen recovery, realm/faction/region isolation, complete-empty
coverage and missing buyout. Inventory tests cover exact-hour/one-second-later
boundaries, setting restoration, invalid input and Vendor warning exclusion.

Reuse ticket 01's recorded native and controlled-client evidence for existing
scan behavior, and this ticket's owner confirmations for account-wide persistence.
Still pending: target-client verification of the new configuration/warning display
and persistence (README step 9), incompatible-market isolation, and integrated
review of the ticket 03 acceptance list. Synthetic checks do not establish native
server behavior; this ticket is not resolved yet.


### Warning acceptance screenshot — 2026-11-15

Owner supplied an in-client screenshot showing AH recommendations labeled
“stale price” (including Sharp Arrow and Lesser Healing Potion), while Heavy
Linen Bandage's Vendor recommendation has no stale warning. Chat reports the
configured threshold as 0.01 minutes. No item is selected, so the detail warning
is not verified by this screenshot. Reload persistence is not independently
established by a still image; awaiting owner confirmation of the reload step.
Warning clearing and incompatible-market verification remain pending.


### Owner-confirmed stale-warning acceptance — 2026-11-15

Following the screenshot and the requested detail/clearing checks, the owner
reported “everything works” and explicitly confirmed setting persistence.
Record selected AH detail warning, clearing row/detail warnings with a larger
threshold, restoring the 60-minute threshold, and setting persistence across
reload as owner-reported passed. The screenshot separately verifies AH row
warnings and Vendor warning exclusion. Exact threshold boundaries remain
supported by synthetic tests. Incompatible-market client verification remains
pending; the ticket is not resolved.


### Resolution and deferred compatibility acceptance — 2026-11-15

Owner directed all tests for other factions/rulesets to dedicated
[ticket 08](08-verify-other-factions-and-rulesets.md). That ticket also owns the
remaining incompatible-market client verification across faction/realm/region.
No native evidence for those environments is claimed; automated isolation checks
remain passing. This supersedes earlier comments treating that check as a gate.

Ticket 03 is resolved for the current environment using the recorded ticket 01
scan evidence, owner-confirmed account-wide sharing/persistence, the new warning
screenshot and owner confirmation, and approved synthetic edge-case checks.
Destination marking controls and their warning reuse remain ticket 04 work.
