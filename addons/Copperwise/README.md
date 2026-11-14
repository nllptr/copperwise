# Copperwise Inventory

Standalone production addon, interface 16001 (Forever). Copy `Copperwise` into
`/Applications/World of Warcraft/_forever_/Interface/AddOns/`, enable it, then
reload/login. Open the separate Inventory window with `/cw` or `/copperwise`.
No backend, credentials, companion or Auctionator dependency is required.

Select an owned item from the menu. Backpack and bags 0–4 are covered. Only native
commodity classifications are eligible for scans; unsupported items remain
inspectable. Vendor values are sell proceeds, with unavailable distinct from zero.
Bag events invalidate quantities immediately. Identical unlocked slot snapshots
must persist for 0.75 seconds after the last bag/cursor event before quantities
are shown; cursor-held items withhold totals. This is a settling heuristic, not an
atomic native snapshot guarantee. Verify real split/move behavior before acceptance.

At an auctioneer, let other searches finish, wait two quiet seconds, then click
**Scan at AH**. Missing item metadata requires another explicit click after loading;
metadata events never dispatch a search. **More results** is available for partial
results only, with three total requests and 500 processed rows per update. There
are no automatic retries. Results describe observed asking values, not sales.
Complete empty results have zero supply and unavailable price.

Cancel, changing selection, hiding Inventory, or closing the AH stops collection.
Late responses are ignored. Uncertain outstanding requests require closing and
reopening the AH before another query. Other observed AH requests interrupt local
collection; Copperwise never cancels another addon's work. Throttling and a
read-only Auctionator queue check can refuse a request. Outstanding external
requests block scanning until a matching result event; unknown completion or
overlapping requests for the same item require closing/reopening the AH.

The latest complete result is retained separately in memory during unsuccessful
refreshes. Persistence, multiple-item retention, ranking and sale intent belong
to later tickets. No destination recommendation or transaction is provided here.

## Acceptance: actual client boundary

Status: pending. Repository checks do not establish runtime acceptance.

Record client version/build/interface (`/dump GetBuildInfo()`), platform, realm,
faction, region, enabled addons and UI scale. Use owned commodities with native
quantity and price comparisons. Record screenshots and outcomes here or in the
ticket. Never include account paths or unrelated saved variables.

1. Disable Copperwise probes; enable only Copperwise first. Open `/cw` away from
   AH and confirm the window is independent of the native AH. Repeat with
   Auctionator enabled. Confirm normal native AH navigation still works.
2. Select an owned commodity, record ID, native bag stacks, aggregate count and
   native vendor sell tooltip. Compare displayed unit and total sell proceeds.
   Exercise uncached metadata and known-zero vendor sell value where available.
3. Split, merge and move stacks between bags, including holding an item on the
   cursor. During changes totals must be withheld; settled totals must equal
   native bag holdings. If transient counts become actionable, fail acceptance.
4. At AH, scan a selected owned commodity. Independently compare lowest native
   unit buyout and covered supply. Record selected ID, coverage/completeness,
   market and displayed observation time. Check no scan and metadata-loading
   states separately; loading must not send a query automatically.
5. Exercise complete empty, partial (including More), failed, timeout, busy and
   throttled outcomes where reproducible. Empty must have unavailable buyout;
   partial coverage must be labelled incomplete. No destination is recommended.
6. Cancel immediately after Scan, wait for late responses, then close/reopen AH
   and scan again. Repeat closing AH during a request and hiding Inventory.
   Cancelled state must remain cancelled; no further requests are dispatched.
7. Run native/Auctionator searches before and during local scanning. Verify
   refusal/interruption, that other work completes normally, and reopen recovery.
8. After a complete result, trigger a failed/cancelled refresh. The last complete
   observation must retain its source time, price, market and coverage. It must
   be visibly separate from the latest attempt and never labelled newly observed.

Limits: settling, UI templates, native shared-cache attribution, unsupported item
classification and all outcomes above require target-client validation. Existing
probe samples do not pass this new integrated workflow.
