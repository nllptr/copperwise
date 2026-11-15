# 01: Inspect one bag item with AH context

**What to build:** The player selects one real supported bag item in a standalone Inventory window and sees bag quantity, vendor sell value and an observation from a user-initiated full market summary scan in the Copperwise AH tab.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Install and open the production addon without a backend, API credentials, companion or Auctionator dependency; the Inventory window is separate from the native AH window.
- [ ] Show one supported commodity's comparable identity, settled bag quantity across stacks and vendor sell value; distinguish unavailable metadata from known zero and avoid actionable transient double counts.
- [ ] From the Copperwise AH tab, perform a user-initiated full market summary scan; in Inventory show lowest observed buyout per unit, covered supply, market context, source time and completeness in the selected item's detail.
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

### Production client evidence — 2026-11-15

Owner screenshot and explicit native-AH comparison confirm the connected
selection → user-initiated query → visible result journey for Rough Stone
(2835). At displayed observation time 2026-11-15 00:47:43 CET, the result is
complete: 1/3 requests, 19 covered rows, 2,465 covered units and lowest asking
buyout 5 copper/unit. Owner confirms native AH price and supply match.
Market: CAMWOW EU5 Realm 10 RP / Alliance / region 3.

The same screenshot displays 18 owned units, vendor sell 2 copper/unit and
36 copper total. These vendor/bag values are visible evidence only; independent
native bag/vendor comparisons and split/move settling checks remain pending.
The earlier missing-coin-formatter crash was fixed in 8e05004; the subsequent
screenshots verify successful money rendering and item selection.

Current run build/interface/platform, enabled addons and UI scale have not been
recorded. Earlier probe build evidence is not substituted for this run. Remaining
acceptance includes metadata/zero/empty/partial/failure paths, cancellation and
late responses, AH closure/recovery, coexistence and retained-result behavior.
This confirms one production sample, not full ticket completion.

Owner follow-up screenshot after `/run Copperwise.Scan(); Copperwise.Cancel()`
shows Rough Stone latest attempt cancelled after 1/3 requests, incomplete, with
unavailable rows, supply, buyout and observation time. A separate last-complete
observation remains visible: 2026-11-15 00:49:03 CET, supply 2,360, asking buyout
5 copper/unit, same market context. This verifies immediate cancellation display
and preservation of the preceding successful observation without assigning a
new observation time to the cancelled attempt. The screenshot alone does not
establish elapsed waiting or late-response stability; confirmation after waiting
and AH close/reopen recovery remain pending.

Owner subsequently confirms recovery after the requested close/reopen and scan
sequence ("it recovers"). AH close/reopen recovery after cancellation passes
for this run. No separate confirmation of the cancelled state's stability during
the waiting interval was supplied, so that check remains pending.

Owner confirms cursor-held quantity withholding works. Owner also clarifies
stack splitting works as expected with Inventory open when the AH is closed;
Shift-click has another function while the AH is open. The reported splitting
issue is therefore not a Copperwise defect. No explicit split/merge aggregate
quantity comparison was supplied, so that quantity acceptance remains pending.

Owner subsequently confirms the requested split/merge comparison: with the AH
closed, splitting the 18 Rough Stone into two stacks and merging them again
both settle at 18 total in Copperwise. Settled split/merge aggregation passes
for this sample, alongside the previously confirmed cursor-held withholding.

Owner confirms the native vendor sell tooltip matches Copperwise for Rough
Stone: 2 copper/unit and 36 copper for 18 units. The sample's vendor unit and
owned-quantity total comparison passes.

Owner ran the AH-closure check with the corrected modern API macro,
`/run Copperwise.Scan(); C_AuctionHouse.CloseAuctionHouse()`, and confirms
"it's cancelled" after the instruction to wait several seconds. AH closure
produces a cancelled attempt for this run. The initial macro used unavailable
global `CloseAuctionHouse()` and errored; that failed operator instruction is
not counted as closure evidence. Preservation of the prior observation in the
closure case has not been explicitly confirmed.

### Revised collection workflow — owner clarification 2026-11-15

Full-market summary scanning replaces selected-item queries. Inventory has no
Scan/More/Cancel controls; it displays retained observations for review and later
sale-intent marking. Full scan lives in the native Copperwise AH tab and covers
all native browse pages, following the installed Auctionator summary-mode path.
The owner supplied Auctionator output reporting 3,758 processed items. Copperwise
must verify the new full scan independently. Previous production single-item
results above are historical evidence, not acceptance of the revised collector.

Revised implementation retains complete market snapshots per character and native
market, preserving prior successful data on cancellation/failure and exposing
it away from AH and after reload. Request/row/time bounds, native throttling and
other AH activity remain enforced. No ranking/marking/posting is added here.
Full-scan runtime and persistence acceptance remain pending.
