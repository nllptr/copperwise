# Copperwise

Standalone Forever addon, interface 16001. Copy `Copperwise` into
`/Applications/World of Warcraft/_forever_/Interface/AddOns/`, enable it, then
reload/login. No backend, credentials, companion or Auctionator dependency.

## Review inventory

Run `/cw` or `/copperwise` to open the standalone Inventory window. Select an
owned item to inspect bag quantity and vendor sell values. Backpack and bags
0–4 are covered. Identical unlocked slot snapshots must persist for 0.75 seconds
after bag/cursor changes before quantities are shown. Holding an item on the
cursor withholds totals. This is a settling heuristic, not an atomic guarantee.

Inventory displays retained full-scan asking values for comparable native
commodities. Missing observations are unavailable; go to the AH to refresh.
Known-zero vendor values remain numeric zero. Equipment variants are not
compared by item ID. Ranking and AH/Vendor marking belong to subsequent tickets.

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

Snapshots persist through ordinary per-character addon saved variables, separated
by native realm/faction/region. Inventory can read them away from AH and after
reload; observation age is shown. There is no offline collection or price history.
Stale-warning configuration and destination buttons belong to later tickets.

## Actual-client acceptance

Status: pending for the revised full-market workflow. Prior single-item query,
vendor and bag results remain recorded in ticket 01; they do not verify this
collector. Lua syntax and Go checks are supporting checks only.

1. Record `GetBuildInfo()`, platform, native realm/faction/region, UI scale and
   enabled addons. Disable Copperwise probes. Verify loading without Auctionator.
2. Open `/cw` away from AH. Confirm no scan controls. Verify bag totals after
   split/merge/movement and withholding on cursor; compare vendor sell values.
3. Open AH, then its Copperwise tab. Confirm native tab layout and switching.
   Full scan should process all market summaries and reach complete, with a
   retained summary count and timestamp. Independently compare several owned
   commodities' minimum unit buyout and supply with native AH observations.
   Auctionator's count can differ due to time or identity mapping; record it as
   context rather than assuming counts must be identical.
4. Close AH and inspect Inventory. Reload/logout and restore: selected commodity
   observations must retain prices, supply, source time, market and coverage.
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

No posting or other transaction is performed by this version.
