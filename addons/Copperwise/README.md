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
AH row buttons show an **!** warning only when the original observation is
older than the threshold (default 60 minutes); exactly 60 minutes is fresh.
Use `/cw stale 30` to set a positive threshold in minutes for this character,
or `/cw stale` to see the current setting and usage. Settings survive reload
and logout; invalid input preserves the previous value. Vendor recommendations
and unavailable comparisons have no stale warning. The warning updates while
Inventory is open and never changes a recommendation or source timestamp.
The same warning appears on the AH destination marking control.

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
   older than one second. Confirm **!** on its AH row button, an age warning in
   its tooltip and a warning in its detail. Use `/cw stale 60` to restore the default; warnings
   disappear if the observation is within an hour. Confirm Vendor recommendations
   have no warning. Reload and use `/cw stale` to confirm the chosen setting.
   Exact threshold boundaries are covered by the synthetic checks below.

No posting or other transaction is performed by this version.

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
or either comparison is missing, or while bag holdings settle. An AH **!** and
its tooltip warn about stale prices.

Marked rows move below unmarked inventory into **Marked for sale**. Their
button reads **AH ×** or **Vendor ×**; click it to unmark and return the item to
inventory. Selecting the name/icon only changes the detail. Each section retains
its value ordering. Marked rows also show intended units, bag availability and
any shortage. Marking never adds repeated copies to an existing plan.

Select a marked item to edit the labeled **Units to sell** field. Enter positive
whole item units and press **Save quantity** to replace the intended quantity
(maximum 2,147,483,647). Typing alone changes nothing; zero is rejected. To change
a saved destination after prices change, unmark and mark again. There is no
Add bag units control. Existing saved quantities are preserved by this update.

Intended units, current bag availability, covered intent and shortage are shown
separately. Marked items remain listed when none are held. During bag or cursor
activity, availability says **checking** and additions are withheld; edits and
explicit removal remain available. A bag decrease never completes or removes
Vendor or AH intent. Use the normal merchant UI to sell Vendor items, then
explicitly remove or edit the plan. No merchant or auction transaction is sent.

Sale plans use version 1 in `CopperwiseDB.salePlan`, saved per character by the
native SavedVariables lifecycle. Window/tab changes and AH visits do not reset
them. Login/reload restores intent before bag revalidation. Incompatible or
malformed plans are preserved and editing is blocked with a visible explanation.
This introduces a separate character-plan schema without changing the account
market schema. Future plan schema changes require sequential copy-on-upgrade
migrations preserving supported saved plans.

### Ticket 04 client acceptance — pending

Record build, platform, realm/faction/region and UI scale. Run the production
addon with probes disabled. Repository checks do not pass these cases.

1. With retained prices and multiple stacks, compare an unmarked commodity's
   net AH/vendor values. Confirm its row button names the preferred destination,
   including a stale-price warning where applicable. Missing comparisons and
   unsupported items must have no destination button.
2. Select a different row first, then click the commodity's AH/Vendor button.
   Confirm intended units equal its bag quantity, the row moves below inventory
   into Marked for sale, and the detail selection stays on the other item.
   Select the marked item by its name/icon; that must not change its mark.
3. Click its AH ×/Vendor × button: it returns to unmarked inventory. Mark it
   again: the intended quantity must equal current bags, with no accumulation.
   Select it, enter 5 in Units to sell and Save quantity: confirm replacement.
   Reject blank, zero, negative, fractional and oversized values. Typing without
   saving must leave the plan unchanged. Unmarking must also work at zero bags.
4. Split/merge stacks and move an item onto the cursor: additions disappear
   during settling and availability says checking. After settling, bag quantities
   agree with native bags. Decrease holdings below intended units, then to zero:
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
