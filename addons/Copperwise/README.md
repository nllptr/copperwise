# Copperwise

Standalone Forever addon, interface 16001. Copy `Copperwise` into
`/Applications/World of Warcraft/_forever_/Interface/AddOns/`, enable it, then
reload/login. No backend, credentials, companion or Auctionator dependency.

## Review inventory

Run `/cw` or `/copperwise` to open the standalone Inventory window. Select an
owned item to inspect bag quantity and vendor sell values. Backpack and bags
0–4 are covered. Identical unlocked slot snapshots must persist for 0.75 seconds
after bag/cursor changes before new quantities replace the last settled view.
During updates, retain displayed quantities, totals and order without a visible
status change; holdings remain unavailable to actions until settled. This is a settling heuristic, not an atomic guarantee.

Inventory displays retained full-scan asking values for comparable native
commodities. Missing observations are unavailable; go to the AH to refresh.
Known-zero vendor values remain numeric zero. Equipment variants are not
compared by item ID. The scrollable Inventory list shows icons, names and settled
aggregated quantities. Complete comparisons rank by the greater of estimated AH proceeds after the
faction 5% cut and vendor sell total, descending, then name and item ID.
Estimated AH proceeds round down to whole copper and exclude deposits. Incomplete
comparisons sort last; known zero stays numeric. Equal totals prefer Vendor.
Select any row to see gross AH asking total, estimated AH proceeds and vendor total for the same quantity and its retained source
time/coverage. Selection sends no market query. Use the AH/Vendor button beside an inventory row to mark its currently observed
bag units for sale, independently of detail selection.

## Full market scan

Visit an auctioneer and select the **Copperwise** tab beside the native tabs.
Let other AH work finish, wait two quiet seconds, then click **Full scan**.
Copperwise uses native summary-mode scanning, as the installed Auctionator does:
an empty browse query followed by more browse pages until native completeness.
This collects the market, independently of which items you own or mark for sale.
Each summary contains a native item key, minimum asking price and available
quantity. These are summaries, not individual listings or completed sales.

Progress shows requests and processed item summaries. Native throttling pauses
pagination. Limits are 2,000 requests, 100,000 summaries, 30 seconds per response
and 180 seconds total. Reaching a limit leaves the scan incomplete and preserves
the prior complete scan. No automatic retries of failed requests.

Cancel, leaving the Copperwise tab or closing the AH stops collection and further
requests. Late responses after cancellation cannot publish a snapshot. Cancelled
outstanding requests, timeouts or interrupted attribution require close/reopen AH
before another scan. Other observed AH requests interrupt collection; Copperwise
never cancels another addon's work. Pending external work and the optional
read-only Auctionator queue check block new scans. Unknown completion or
ambiguous overlapping external requests require closing/reopening AH.

Only a fully processed complete market snapshot replaces retained data. Failed
or cancelled refreshes do not advance its source time or coverage. A commodity
absent from a complete scan has observed zero supply and unavailable buyout;
missing/zero summary buyout is never manufactured into a zero asking price.
Summaries with ambiguous commodity identity are withheld from comparisons.
Repeated identical native keys are counted once, without summing supply. If
repeated keys disagree on price or supply, that key is withheld from Inventory
comparisons. The AH panel reports repeated-key and conflicting-key counts.

Snapshots persist through account-wide `CopperwiseAccountDB` saved variables,
separated by native realm/faction/region. All characters on the same account can
read compatible observations away from AH after ordinary reload/logout and login.
Observation age uses the original source time. Account-wide schema version 1 is
our persistence baseline; pre-account-wide character snapshots are not imported.
Character holdings and sale intent stay separate from the account market store.
There is no live cross-client synchronization, offline collection or price history.

When changing the account schema, increment `VERSION` in `Storage.lua` and add
an upgrade function keyed by the previous version in `migrations`. Each function
returns the upgraded table; the loader advances its version by one. Retain all
steps so users can skip releases. Upgrades run on a copy and are published only
after the entire chain succeeds. Add behavior checks for the concrete schema
change at the login/Inventory boundary. No account schema change is needed yet.
Unsupported versions, malformed data and failed upgrades leave the saved data
intact and disable market reads/scans with a visible explanation.
Inventory shows one warning icon and **Market scan is outdated** above the list
when the retained complete scan is older than the threshold (default 60 minutes);
exactly 60 minutes is fresh. Every price in a complete market scan shares the
same source time, so individual rows carry no stale marker.
Use `/cw stale 30` to set a positive threshold in minutes for this character,
or `/cw stale` to see the current setting and usage. Settings survive reload
and logout; invalid input preserves the previous value. The single warning is
independent of selection and destination, including Vendor-only or empty bags.
Hover it for the scan source time, market, threshold and refresh instructions.
It is absent when no compatible complete scan is available. It updates while
Inventory is open and never changes a recommendation or source timestamp.
Failed or cancelled refreshes leave the warning based on the prior complete scan.

## Actual-client acceptance

Ticket 01 is resolved: production full-market workflow evidence and the
owner-approved controlled edge-case diagnostics are recorded in its acceptance
checklist. The target-client diagnostic run passed 7/7 on 2026-11-15; simulated
inputs do not establish native-server behavior. The broader release checklist
below spans later tickets and is not entirely complete. Lua syntax and Go checks
are supporting checks only.

1. Record `GetBuildInfo()`, platform, native realm/faction/region, UI scale and
   enabled addons. Disable Copperwise probes. Verify loading without Auctionator.
2. Open `/cw` away from AH. Confirm no scan controls. Verify bag totals after
   split/merge/movement and stable retained display while holding an item on the cursor; compare vendor sell values.
3. Open AH, then its Copperwise tab. Confirm native tab layout and switching.
   Full scan should process all market summaries and reach complete, with a
   retained summary count and timestamp. Independently compare several owned
   commodities' minimum unit buyout and supply with native AH observations.
   Auctionator's count can differ due to time or identity mapping; record it as
   context rather than assuming counts must be identical.
4. Close AH and inspect Inventory. Reload/logout and restore: selected commodity
   observations must retain prices, supply, source time, market and coverage.
   Switch to another character on the same account and compatible market, away
   from AH. Confirm the same observations and original source time against that
   character's own bag quantities. Verify another realm/faction/region cannot
   read incompatible data. On 2026-11-15 the owner confirmed existing observations
   survived reinstall/restart with the versioned loader, compatible characters
   shared those observations, and a new full scan completed and survived reload.
   Incompatible-market client acceptance is deferred to
   [ticket 08](../../.scratch/addon-selling-mvp/issues/08-verify-other-factions-and-rulesets.md),
   together with all other-faction/ruleset tests; it does not gate current-environment acceptance.
5. Cancel immediately after dispatch from the open Copperwise AH tab:
   `/run Copperwise.Scan(); Copperwise.Cancel()`.
   Wait for late responses; state must remain cancelled and retained data must
   remain unchanged. Close/reopen AH and verify a new scan succeeds.
6. Repeat with `/run Copperwise.Scan(); C_AuctionHouse.CloseAuctionHouse()`.
   Verify closure, cancelled stability, preservation and reopen recovery. Leaving
   the tab must also stop collection. Hiding Inventory must not cancel an AH scan.
7. Exercise native/Auctionator activity before and during scanning; confirm
   refusal/interruption, normal completion of other work and reopen recovery.
8. Exercise throttling, partial/bound/timeout/failure and complete-empty coverage
   where reproducible. None may publish partial data as a complete snapshot or
   turn missing buyout into zero. Verify unavailable/known-zero vendor metadata.

9. With an AH-recommended commodity selected, use `/cw stale 0.01` on a scan
   older than one second. Confirm one warning icon and “Market scan is outdated”
   above the list, with no per-row **!**. Hover for scan time, market, threshold
   and Full scan instructions. Select AH, Vendor or unavailable rows: the shared
   warning must remain the same. Use `/cw stale 60` to restore the default; it
   disappears if the observation is within an hour. Reload and use `/cw stale` to confirm the chosen setting.
   Exact threshold boundaries are covered by the synthetic checks below.

The AH tab now includes deliberate selected-item posting; see its acceptance checklist below.

For reproducible simulated edge cases, see the separate
[ticket 01 diagnostics](../../probes/ticket-01/README.md). Those checks run isolated
production Lua with synthetic API inputs; they do not establish native-server
acceptance and never replace the retained production market snapshot.

## Supporting storage checks

From the repository root, run `lua addons/Copperwise/tests/storage.lua` with Lua
5.1 or newer. These checks exercise login and Inventory observations with native
API boundary stubs; they do not establish actual-client acceptance. Syntax-check
the production Lua files with `luac -p addons/Copperwise/*.lua`.

## Supported auction-house scope

Use faction auction houses for MVP scans and posting. Neutral/cross-faction
auction houses and their 15% cut are deferred to a later release. Inventory
assumes faction AH commission (5%); it does not detect or support neutral
markets. Estimated proceeds are conditional on a sale, not guaranteed profit.

## Inventory synthetic acceptance

Run `luajit addons/Copperwise/tests/inventory.lua` from the repository root.
These checks load the production Inventory, storage and scan modules with
synthetic native APIs, saved observations, clock and widgets. Assertions observe
rendered rows and selection detail, covering net destination ties, missing
vendor metadata resolving to zero, absent observations, equal ranking values
and commission-aware ordering. Market request stubs fail if selection queries
the AH. They verify behavior in code, not native layout or server semantics.
The owner approved these code-only cases to complete ticket 02 alongside its
recorded real-client evidence; this does not replace later release acceptance.


## Scan lifecycle checks

Run `luajit addons/Copperwise/tests/scan.lua`. These checks load the current
production modules and exercise native events with simulated APIs and time.
They cover cumulative pagination, throttling, cancellation, AH closure/tab
changes, competing work, failure/timeouts, late responses, reopen recovery,
market isolation, complete-empty coverage and missing buyout. Inventory checks
also cover stale-warning boundaries and per-character setting restoration.
These checks support the client evidence; they do not establish server behavior.

## Maintain sale intent (ticket 04)

Each compact inventory row has a separate **AH** or **Vendor** button beside
its name, owned quantity and total comparison value. Click that button to mark
the currently observed bag units without changing the selected detail. The
button follows the approved net-AH/vendor comparison and is absent when metadata
or either comparison is missing, or while bag holdings settle. The single
window warning indicates when the retained complete scan is outdated.

Marked rows move below unmarked inventory into **Marked for sale**. Their
button reads **AH ×** or **Vendor ×**; click it to unmark and return the item to
inventory. Selecting the name/icon only changes the detail. Each section retains
its value ordering, calculated for its own quantity. Marked rows show the
intended quantity, and the top list shows only remaining unmarked bag units.
For example, 11 in bags and 5 intended produces a marked row of 5 and an
unmarked row of 6. The latter has **AH +** or **Vendor +**, which adds only those
6 remaining units to the existing destination. The top row then disappears.
The marked × button always removes the whole mark. Changed holdings recalculate
the remainder without silently changing intended units.

Select either portion to inspect totals for that portion's quantity; overall
bag quantity stays visible separately. Marked totals use intended units even
when holdings fall short, with coverage and shortage shown separately.
Select the marked portion to edit the labeled **Units to sell** field. Enter positive
whole item units and press **Save quantity** to replace the intended quantity
(maximum 2,147,483,647). Typing alone changes nothing; zero is rejected. To change
a saved destination after prices change, unmark and mark again. There is no
Add bag units control. Existing saved quantities are preserved by this update.

Intended units, current bag availability, covered intent and shortage are shown
separately. Marked items remain listed when none are held. During bag or cursor
activity, the last settled quantities, shortage labels and destination buttons
stay visible. Revalidation runs in the background; additions still require
settled holdings at click time. Edits and explicit removal remain available.
Before the first settled observation after login, availability is unavailable;
saved intent never proves current bag holdings. A bag decrease never completes or removes
Vendor or AH intent. Use the normal merchant UI to sell Vendor items, then
explicitly remove or edit the plan. No merchant or auction transaction is sent.

Sale plans use version 1 in `CopperwiseDB.salePlan`, saved per character by the
native SavedVariables lifecycle. Window/tab changes and AH visits do not reset
them. Login/reload restores intent before bag revalidation. Incompatible or
malformed plans are preserved and editing is blocked with a visible explanation.
This introduces a separate character-plan schema without changing the account
market schema. Future plan schema changes require sequential copy-on-upgrade
migrations preserving supported saved plans.

### Ticket 04 client acceptance

Ticket 04 is resolved from owner-run client checks recorded in its
[acceptance history](../../.scratch/addon-selling-mvp/issues/04-mark-and-maintain-sale-intent.md).
The following is the reusable verification checklist; resolution does not claim
an individually recorded run of every edge-case permutation or posting acceptance.
Record build, platform, realm/faction/region and UI scale when rerunning it.
Run the production addon with probes disabled. Repository checks alone do not
pass client acceptance.

1. With retained prices and multiple stacks, compare an unmarked commodity's
   net AH/vendor values. Confirm its row button names the preferred destination.
   Confirm the window-level stale-scan warning where applicable. Missing comparisons and
   unsupported items must have no destination button.
2. Select a different row first, then click the commodity's AH/Vendor button.
   Confirm intended units equal its bag quantity, the row moves below inventory
   into Marked for sale, and the detail selection stays on the other item.
   Select the marked item by its name/icon; that must not change its mark.
3. Click its AH ×/Vendor × button: it returns to unmarked inventory. Mark it
   again: the intended quantity must equal current bags, with no accumulation.
   Select its marked row, enter 5 in Units to sell and Save quantity: confirm
   replacement. With 11 bags, verify marked 5 and unmarked 6, with totals based
   on each quantity. For Bolt of Linen Cloth at 50c AH and 40c vendor per unit:
   marked 5 gives 250c gross AH, 237c net and 200c vendor; unmarked 6 gives 300c
   gross, 285c net and 240c vendor. Select each portion and check its detail.
   Click the top AH +/Vendor +: intended becomes 11, and the top row disappears.
   No action may add the same available remainder twice. Edit to 5 again, reload
   and verify the 5/6 split. Unmark and confirm one unmarked row of 11.
   Reject blank, zero, negative, fractional and oversized values. Typing without
   saving must leave the plan unchanged. Unmarking must also work at zero bags.
4. Hover items in native bags repeatedly, then split/merge stacks and move an
   item onto the cursor: existing buttons, bag labels, shortages, totals and
   order must remain stable during background settling. No transient checking
   label or disappearing button should appear. Additions during this interval
   must not mutate intent. After settling, bag quantities agree with native bags. Decrease holdings below intended units, then to zero:
   the mark and destination remain, with the correct shortage and no lost row.
5. Close/reopen Inventory, visit/switch native AH tabs and return. Reload and
   logout/login: verify the same intended quantity and destination, with fresh
   availability rather than treating saved intent as bag holdings.
6. Change to a second character: the first character's intent must be absent.
   Mark something on the second character, then return to the first; verify both
   characters retain only their own plan while sharing compatible scan data.
7. Refresh prices so the preferred destination changes: the saved destination
   must remain. Edit quantity without changing it. Click its × button to unmark,
   then mark again to choose the new recommendation.
8. Exercise a Vendor mark and sell some units with the normal merchant UI.
   Verify bag availability decreases but intended units persist. Remove the mark
   explicitly. Confirm AH and Vendor labels remain distinct throughout.
9. Verify readable layout at normal UI scale, scrolling marked/unmarked rows,
   quantity controls and shortage detail. Confirm marking, editing, removal,
   restoration and window/tab changes never query or post an auction or sell
   to a merchant. AH queue display and posting belong to tickets 05 and 06.

## Selected-item AH layout (ticket 05, approved prototype)

The AH tab follows `probes/ah-layout/index.html`: Full scan / Cancel scan and the
Post all placeholder share the top section. The left sidebar contains all AH
intent, including restored, unavailable and unsupported entries. Vendor intent
and unmarked holdings are excluded. The first item is selected automatically.
Select another row to change the posting form and current-listings table.

The form shows marked/bag/eligible units, editable quantity (Max restores eligible
marked units), unit buyout in gold/silver/copper, native deposit, total buyout and
2/8/24-hour duration radios. Duration defaults to 24 hours and is shared. Edits
are ephemeral and survive item selection; tab departure/AH closure discards them.
Neither editing nor selecting changes saved intent or posts an auction.

Selected-item searches use native commodity search and bounded pagination, separate
from the retained full-market summary. The two-column table groups available item
units by unit buyout. Click any row, including a higher price, to adopt its unit
buyout without changing quantity. Refresh item starts a new selected-item query.
Only complete attributed results populate selectable price levels. Empty supply
has no automatic price; unavailable prices/deposits are never rendered as zero.
Unedited unit prices initially use compatible retained observations, then use the
lowest complete current-item result. Explicit edits/listing choices survive item
refresh. The full-scan source time and current-item observation time stay separate.
Selected queries never replace account-wide full-scan observations.

Requests wait for throttling and quiet native/Auctionator activity. Item searches
are bounded to 20 requests, 10,000 rows, 20 seconds per response and 90 seconds
total. Changing selection drains an outstanding item response before querying the
new item. Tab departure stops further pages; closure resets local request state.
An uncertain response blocks further work until close/reopen. If Full scan is
clicked while item/owned-listing work is outstanding, let it finish then click
again. Global scans block selected-item queries until they finish/cancel.

### Post item (individual execution; Post all still deferred)

**Post item sends a real native auction request and can spend a deposit.** It is
only enabled for reviewed supported commodity sources, known positive prices,
valid quantities, sufficient money and current owned-listing attribution data.
The XML button follows the verified posting probe; transactions never originate
from timers, queries, login, reopening or selection. Native confirmations remain
native. Sources, intent and deposit are revalidated at click time.

One click posts at most the first supported source stack. When reviewed quantity
spans stacks, the button shows that click's quantity and the status explains how
many reviewed units remain. After confirmed owned-listing and settled-bag evidence,
intent decreases by that source quantity and the form retains the reviewed
remainder. Click the same Post item control again to continue. No automatic stack
consolidation or Post all execution is introduced. A completed intent disappears
and the next marked item is selected.

A before/after owned-listing identity comparison, exact item/quantity/unit buyout
match and settled matching bag decrease are required for automatic confirmation.
Shared events or API returns alone never consume intent. Conflicts, failures and
uncertainty preserve intent and block another post. The character-specific
`pendingPost` version-1 ledger survives ordinary logout/reload; restored pending
outcomes always require operator reconciliation. It does not change either saved
market or sale-plan schemas. Unsupported ledger data is preserved and blocks posts.

Use Reconcile post only after checking native Auctions and bags. Count as posted
consumes the unchanged reviewed intent; Keep intent clears the blocker without
changing intent; Cancel changes nothing. An edited intent cannot be silently
reduced. Explicit operator reconciliation is necessary when attribution cannot
establish the result. No automatic retry occurs. AH closure/tab departure stops
preparation and makes any outstanding post require reconciliation. No automatic
posting resumes after reopening or reloading.

### Target-client acceptance — pending

Existing Lua syntax and regression checks support the implementation but cannot
establish native layout, query/server behavior or successful production posting.
Use the usual faction AH with probes disabled. Record client build, market, UI
scale and Auctionator version/presence. The original review screenshots established
visible marks and tabs, not acceptance of this replacement layout.

1. Reload, open Copperwise: the sidebar includes all and only AH marks, first item
   selected. Check sidebar scrolling, icon/name/count, current quantity and shortages.
   Verify restored absent/unsupported marks stay visible. Compare layout with the
   approved prototype at normal UI scale; check no overlap or clipped controls.
2. Wait for item listings; compare price levels and grouped Available units with
   native/Auctionator listings. Switch items rapidly during loading. Only the
   selected item's complete results may appear. Empty/failed/partial results stay
   distinct; malformed/uncertain data never supplies automatic defaults.
3. Click a non-lowest price: unit buyout and quantity-times-price total change,
   quantity stays fixed. Edit quantity and denominations, use Max, select another
   item and return. Explicit prices persist until leaving the tab/closing AH.
   Refresh item keeps overrides. Duration radios select exactly one of 2/8/24h;
   native deposit and total reflect selected terms. Compare deposits per source
   stack, including multiple stacks, zero, unavailable and insufficient funds.
4. Exercise Full scan, Cancel scan and Refresh item separately, including during
   native/Auctionator work. Verify global scans preserve their existing full-market
   completeness, cancel/closure behavior and original saved-data semantics. A
   selected query must never publish into the full-market cache.
5. Before posting, choose one inexpensive commodity and explicit safe terms.
   Click Post item once; inspect native owned listings for matching item, quantity,
   price and duration, and compare bag change. Intent must decrease only after
   confirmation. For multiple stacks continue the same reviewed remainder through
   deliberate clicks. Verify duplicate clicks cannot submit another unresolved post.
6. Test shortage, changed holdings/terms, blocked/native-error paths and uncertain
   outcomes. Inspect Auctions before operator reconciliation; neither a shared
   event nor bag decrease alone can claim a successful post. Reload with an
   unresolved outcome: ledger and intent survive and no posting auto-resumes.
7. Leave tab/close AH during queries and pending posting; reopen. No extra pages
   or posts may dispatch while closed. Defaults rebuild; saved intent survives.
   Verify normal native/Auctionator tabs still work. Test without Auctionator too.

Ticket 06 remains open for reviewed multi-item Post all execution and its actual
click/advancement requirements. This individual path does not resolve that ticket.
