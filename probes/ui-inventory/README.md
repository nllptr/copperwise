# Inventory screen study (S01)

Open `index.html` directly in a browser. No build, dependencies, backend or
credentials are required. This is a disposable synthetic prototype of the
[approved integrated workflow](../../.scratch/selling-context/spec.md).
The earlier `../ui-history` study is preserved independently.

## Review journey

1. Select Copper Ore, Peacebloom and Linen Cloth. Inspect bag quantities,
   lowest observed buyout per unit, vendor sell value and aligned history.
2. Search `linen`; clear the search, then try an absent item name.
3. Switch between 24h, 7d (default) and All. All requests 16 days while actual
   observations span 15 days 16 hours, leaving the unavailable leading interval.
4. Compare Observed empty supply with Missing observations. Empty shows zero
   listed stock and no price; missing observations break both series. Neither
   draws an absent buyout as a zero price. No history keeps values unknown.
5. Inspect Vendor metadata unavailable: no invented vendor baseline is drawn.
6. Mark an item for sale, select another, then return and unmark it. The mark
   carries item identity only. Quantity policy, persistence and AH handoff are
   separate tickets; marks reset on page refresh. No transaction is possible.

## Design choices

A persistent bag rail keeps selection visible beside shared market detail.
Lowest buyout is primary; vendor sell value is a separate per-unit comparison,
not acquisition cost or recorded profit. Fixed sample order deliberately avoids
selecting a ranking formula. Stock is explicitly item units. Familiar dark
panels, gold trim, tabs and denomination colors suggest the target UI direction,
but these CSS controls and placeholder glyphs are browser-only.

The scenario picker sits outside the proposed addon. It applies to the selected
item and selected range, not to a live source. Samples are deterministic hourly
illustrations, not predictions, observed cadence or validated price statistics.
Empty/gap scenarios affect the latest 12 hours and an earlier 40–49-hour interval.
All graphs share the requested time domain and include actual coverage text.
The frozen review clock is 14 Nov 2026 18:00 Europe/Stockholm (CET, UTC+1).
Ordinary latest source observation is 17:22; illustrative import is 17:48.
Market mapping and all holdings/prices are unverified synthetic fixtures.
No local scan is claimed; the history is labelled synthetic backend history.

## Validation and boundaries

Headless Chromium checked selection, marks across selection changes, all three
ranges, all five scenarios, observed zero versus unknown stock and no-match
search feedback. All 15 checks passed. Desktop rendering was inspected at a
960px viewport with a 900px addon surface. JavaScript syntax and the repository's
Go suite were checked; there is no TypeScript/build step for this HTML study.
The browser check is disposable verification, not a new production test seam.

M03 previously verified sample graphs/local-time labels, lookup, window access
and bindings on client 1.60.1 (70938), interface 16001, macOS 26.6.2 Intel.
That evidence does not establish this layout, bag metadata, native widgets,
range density, sale intent or real inventory integration. Actual client fit at
the owner's normal UI scale remains pending. This ticket creates no addon,
backend contract, bank access, posting path or production queue.

## Owner feedback

Pending review of this S01 prototype. Existing direction prefers lowest buyout
and vendor comparison, with native WoW integration; it is not approval of this
layout. Review whether the bag rail/detail split is comfortable at normal play
size, whether price/stock/age are readable, and whether “Mark for sale” clearly
means later intent. Record feedback here before claiming owner acceptance.
