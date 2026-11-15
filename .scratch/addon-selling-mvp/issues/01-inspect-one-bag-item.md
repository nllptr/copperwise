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

Owner's first full-scan screenshot (2026-11-15 01:26:20 CET start, same market)
shows failure after eight requests and 3,500 processed summaries: duplicate
market identity. No complete snapshot was retained. Follow-up deduplicates
identical native keys without adding supply and withholds conflicting keys
from commodity estimates rather than aborting unrelated market collection.
Repeated/conflicting counts are visible in the retained full-scan summary.
This fix requires a new target-client scan; no full-scan pass is claimed yet.

Owner subsequently confirms, after duplicate-summary fixes through 597d9d0:
"scan worked and i can see ah prices in the /cw window". The revised connected
journey from full scan in the native Copperwise AH tab to retained-price display
in standalone Inventory passes for this run. Final summary count, duplicate /
conflict counts and independent native price/supply comparison for the new full
scan have not yet been supplied. Reload/logout persistence, current build and
the revised full collector's cancellation/coexistence paths remain pending;
earlier selected-item checks do not automatically pass the new collector.

Owner subsequently confirms "they remain and are correct" after the requested
close-AH, `/reload`, reopen-Inventory sequence. Retained full-scan prices survive
reload and are owner-confirmed correct. No separate explicit timestamp comparison,
supply comparison, logout/login test or cross-market scoping test was supplied;
those remain unverified rather than inferred from price persistence.

Owner confirms "it works" for the revised full-scan cancellation check:
from the Copperwise AH tab, `/run Copperwise.Scan(); Copperwise.Cancel()`,
wait several seconds, verify cancelled remains visible and prior saved prices
remain available in `/cw`. Cancellation stability and preservation of retained
prices pass for the full collector in this run. This does not establish unchanged
source time/coverage, AH-closure cancellation or competing-addon coexistence.

Owner confirms "works" for the revised full collector's AH-closure check:
after close/reopen and selecting Copperwise, run
`/run Copperwise.Scan(); C_AuctionHouse.CloseAuctionHouse()`, wait several
seconds, then inspect `/cw`. Cancellation and preservation of saved prices
pass on AH closure for this run. Exact source-time/coverage preservation and
competing-addon coexistence remain separate pending checks.

Owner screenshot after the Auctionator coexistence instruction shows Copperwise
refusing a new scan: "other AH work is outstanding; wait or close/reopen AH".
The latest attempt remains a prior cancelled attempt (started 2026-11-15
01:39:35 CET, one request, zero processed summaries; reason Copperwise AH tab
hidden). The retained complete scan remains visible: 2026-11-15 01:36:59 CET,
6,061 item summaries, one repeated key, zero conflicting keys, same market.
This verifies outstanding-work refusal and retained-snapshot display for this
interaction. Auctionator's normal completion has not yet been confirmed.

Owner subsequently confirms Auctionator finished normally. The observed
coexistence scenario passes: Copperwise refused a new full scan while external
AH work was outstanding, retained its prior complete snapshot, and did not
prevent Auctionator from completing. This does not establish every competing
request/interruption or throttle path.

Owner confirms "it works" after disabling Auctionator, reloading, running
Copperwise Full scan and checking prices in `/cw`. The production collector and
Inventory price display therefore pass the observed Auctionator-independent
workflow. This establishes no Auctionator dependency for the exercised path.

Owner supplied `GetBuildInfo()` for the current production run: version
1.60.1, build 70938, build date Nov 12 2026, interface 16001. This is direct
current-run build evidence, replacing the earlier build-recording gap.
