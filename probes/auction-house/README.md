# Native auction-house scanning probe (M18)

Standalone, read-only addon for the Forever modern auction house. No backend,
companion, Auctionator dependency, posting, bidding or purchases. Actual-client
acceptance is pending; this implements the probe, not a production scanner.

## Install and first run

Copy the addon into the Forever AddOns directory, enable **Copperwise Auction
Probe**, and log in (or reload after enabling):

```sh
cp -R probes/auction-house/addons/CopperwiseAuctionProbe '/Applications/World of Warcraft/_forever_/Interface/AddOns/'
```

1. Visit an auctioneer. Let native/Auctionator startup searches finish.
2. Run `/cwah`. This opens **Copperwise probe** beside Buy/Sell/Auctions on the
   native bottom tab row. Select Peacebloom, Copper Ore or Rough Stone.
3. Wait at least two quiet seconds, then click **Scan sample**. A refusal for
   cooldown/busy state sends no request; retry manually after other work ends.
4. If metadata is uncached, the panel shows **Loading item information**. The
   same user-initiated scan continues once metadata arrives, with no second
   click. Loading is limited to 15 seconds; no auction query has been sent yet.
   Cancel, changing samples, leaving the tab, closing the AH or another search
   stops the pending action. A timeout reports **not-sent**, not empty supply.
   Search readiness is checked again before dispatch; a busy AH requires a new
   manual scan. There are no automatic retries of an auction search.
5. Inspect state, covered units, lowest covered buyout, bid-only units,
   timestamps and completeness. **More results** requests another cumulative
   result batch only after `partial`, at most three requests per observation.
6. **Cancel** stops local collection, not a server request already sent. After
   a sent search times out, fails, is cancelled or interrupted by another query,
   close and reopen the AH before starting again. Cancelling or timing out
   metadata loading needs no reopen because no search was sent. Switching tabs
   stops collection and pending metadata continuation.

Commands: `/cwah status`, `/cwah scan`, `/cwah more`, `/cwah cancel`, and
`/cwah note <short observed outcome>`. Scan/More require the Copperwise tab.
The status command works away from the AH and repeats current build/market
context plus the last result's commodity classification and covered units.
The metadata cache is checked every quarter second, or sooner after a matching
native metadata event; this is separate from the
three-auction-request limit. There is no arbitrary/full-market
query or automatic continuation. Requests and notes also print to chat.

## Coverage and result semantics

- Each new scan starts a new observation, using `MakeItemKey(itemID, 0, 0, 0)`.
  Result keys must match; only the three ordinary sample trade goods are offered.
  Item variants/equipment and catalog discovery are outside this probe.
- Commodity rows use `unitPrice` directly. Noncommodity rows divide total
  `buyoutAmount` by `quantity`. A missing/zero buyout counts as bid-only only
  with valid positive minimum-bid metadata. Stock sums all validated quantities,
  including bid-only units; bid-only rows contribute no asking price. Raw sample
  quantities/prices are recorded for independent comparison to native results.
- Result events must match the selected key/item, `HasSearchResults` must be true,
  and the corresponding `HasFull...SearchResults` must confirm completeness.
  Empty partial updates are loading signals, not zero stock. Only full, validated
  zero-row results are **empty**; no zero asking price is fabricated.
- Every result batch replaces the previous cumulative-cache snapshot. It is
  never added to the previous total. Duplicate IDs, missing/invalid row fields
  and mismatched identities prevent a complete summary.
- Process at most 500 rows per update. Above that, show only covered stock and
  minimum, marked partial even if the API reports full. Three requests and a
  15-second response deadline bound one observation. These are probe limits,
  not measured server limits or product freshness thresholds.
- A full result is only the API's full selected-key result set at this AH. It
  is not a full-market scan, atomic snapshot, historical minimum or proof that
  any quantity is purchasable at the minimum. Observation time is local result
  receipt time; no upstream/source timestamp is inferred.

The realm, faction and region diagnostics describe current client context;
the owner must confirm Forever EU RP Alliance in the native client. They do not
establish equivalence to upstream market IDs. Server/market comparability still
belongs to M02. Scan evidence is separate from imported history and companion
health; no history import code, data addon or automatic reload is used.

## Coexistence

The probe uses native display modes and its own tab after the native Auctions tab,
without modifying Auctionator or using its query queue. Read-only secure
post-hooks observe native browse/search/refresh/more/replicate/owned/bid queries.
Another observed query interrupts an outstanding or partial Copperwise scan;
no abort call is sent to the other addon. Native readiness, a two-second quiet
interval and a nonempty installed Auctionator queue check refuse obvious busy
starts. These are cautious guards, not exclusive ownership of the shared cache.

Do not start alongside another active scan. A ready throttle flag is not proof
another addon has finished. Another addon may schedule work after a quiet period;
when observed, the probe stops. Same-key late responses have no per-request token;
closing/reopening is required after uncertain outstanding requests. Validate
these boundaries in the client, especially with Auctionator full scans, which
may temporarily unregister other event listeners. Do not disable that behavior
or unregister another addon's events to make the probe run.

## Actual-client acceptance (pre-agreed test seam)

Record outcomes and relevant lines in [REPORT.md](REPORT.md). Syntax checks or a
simulated client cannot pass these checks. Use read-only actions throughout.

1. Capture login version/build/interface, `/cwah status`, `sw_vers` and `uname -m`.
   Confirm the actual realm/faction/region and which other AH addons are enabled.
2. Away from the AH, scan must refuse. At the AH, confirm the tab opens, other
   tabs remain usable, switching tabs cancels waiting collection, and closing
   the AH cancels it without reopening it or resubmitting.
3. Scan an available sample. Compare recorded raw quantity and total/unit buyout
   fields to the same native listing/price tier. Independently verify per-unit
   arithmetic using different stack sizes if noncommodity results are available.
   Record whether each sample is commodity or item-based; do not assume both
   paths were exercised. Check all-listed-unit stock within actual coverage.
4. Observe bid-only rows if this market exposes them; record their quantities
   and exclusion from minimum buyout. If unavailable, report unexercised rather
   than claiming bid-only runtime acceptance.
5. Exercise partial results/More where available, verify cumulative updates do
   not double count, and confirm the cap remains partial. If all samples return
   full results, record the partial path as unexercised. Do not broaden the scan
   to create an unbounded test. Record request/response elapsed times and actual
   throttling behavior rather than assuming a server cooldown.
6. Scan a supported sample with no listings if available: only confirmed full
   empty results may display zero stock. Missing events, uncached metadata,
   throttle refusal or errors must not appear as observed empty supply.
7. Cancel while waiting, close/reopen and retry; late events must not complete
   the cancelled observation. Record timeout/error paths if encountered.
   For an uncached sample, verify one click progresses from loading to a result.
   If you cancel while loading, observe zero auction requests and no later
   automatic scan. Changing samples or tabs must likewise stop pending loading.
8. With Auctionator installed, first scan while it is idle. Then initiate a
   normal Auctionator search yourself and try Copperwise only while the other
   work is active: it must refuse or stop its own collection without aborting
   Auctionator. Check both tab layouts and normal native browsing afterwards.
   Repeat a standalone run with Auctionator disabled if feasible. No purchase
   or posting is part of this test.

If client APIs/frames differ, record the exact failure before adapting. There is
no silent legacy fallback or use of Auctionator's saved prices as fresh scans.

## Evidence and repository checks

SavedVariables `CopperwiseAuctionEvidence` retains at most five sessions, each
with 200 lines of at most 900 characters. Log out to persist. Raw price evidence
is limited to the first five rows per update; it is not a full listing export.
No seller names, buyer identities, character names or account paths are stored.
Notes should omit personal data. Copy relevant evidence before it rotates out;
disable the probe after the run. This is bounded probe evidence, not side history.

```sh
luajit -e 'assert(loadfile("probes/auction-house/addons/CopperwiseAuctionProbe/Probe.lua"))'
env CGO_ENABLED=1 go vet ./...
env CGO_ENABLED=0 go test ./...
```

Lua 5.1 syntax compilation checks syntax only. No statically typed addon code is
added; existing Go checks do not verify auction APIs. No mocked client/private
helper test substitutes for the agreed actual-client public UI/API seam.

Research sources: Forever [auction API definitions](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_APIDocumentationGenerated/AuctionHouseDocumentation.lua),
[native display-mode implementation](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_AuctionHouseUI/Shared/Blizzard_AuctionHouseFrame.lua),
and [Camelot categories](https://github.com/Gethe/wow-ui-source/blob/forever/Interface/AddOns/Blizzard_AuctionHouseUI/Camelot/Blizzard_AuctionData.lua).
Installed Auctionator 346 `Source_ModernAH/AH/Mixins/SearchScan.lua` corroborates
cache/completeness checks; `Source_ModernAH/AH/Mixins/Throttling.lua` corroborates
readiness events, and `Libs_ModernAH/LibAHTab/LibAHTab.lua` informs coexistence.
Auctionator also ships legacy APIs; their presence does not establish the
running client's AH mode. No TSM installation was found in the local AddOns
directory. All source evidence remains provisional until exercised in-client.
