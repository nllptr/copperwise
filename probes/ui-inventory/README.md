# Inventory screen study (S01)

Open `index.html` directly in a browser. No build, dependencies, backend or
credentials are required. This is a disposable synthetic prototype of the
[approved integrated workflow](../../.scratch/selling-context/spec.md).
The earlier `../ui-history` study is preserved independently.

## Review journey

1. Select any of the eleven bag item types in the compact sidebar; optionally
   filter by name (clear the filter to see all items). Inspect
   owned quantities, total AH/vendor values, unit prices and aligned history.
2. Toggle Include bank. Bag and cached-bank counts remain separate; totals use
   their sum when checked. Iron Ore is bank-only and appears only when included.
3. Switch between 24h, 7d (default) and All. All requests 16 days while actual
   observations span 15 days 16 hours, leaving the unavailable leading interval.
4. Compare Observed empty supply with Missing observations. Empty shows zero
   listed stock and no price; missing observations break both series. Neither
   draws an absent buyout as a zero price. No history keeps values unknown.
5. Inspect Vendor metadata unavailable: no invented vendor baseline is drawn.
6. Use the small AH or Vendor button on a sidebar row: it moves from Inventory to
   Marked for sale. Select it there to inspect details; use the destination × button to move it back.
   Marking does not change the selected detail. Both sections share the filter. The mark
   carries item identity and the chosen destination. Quantity policy, persistence and AH handoff are
   separate tickets; marks reset on page refresh. No transaction is possible.

## Design choices

A persistent bag rail keeps selection visible beside shared market detail.
AH value is lowest observed unit buyout multiplied by counted owned units;
vendor value is vendor unit sell value multiplied by the same count. Each total
shows its unit price and multiplication. Neither is recorded profit or a promise
of a completed sale. Fixed sample order deliberately avoids
selecting a ranking formula. Stock is explicitly item units. Familiar dark
panels, gold trim, tabs and denomination colors suggest the target UI direction,
but these CSS controls and placeholder glyphs are browser-only.

The scenario picker sits outside the proposed addon. It applies to the selected
item and selected range, not to a live source. Samples are deterministic hourly
illustrations, not predictions, observed cadence or validated price statistics.
Empty/gap scenarios affect the latest 12 hours and an earlier 40–49-hour interval.
All graphs share the requested time domain and include actual coverage text.
Bank holdings are a synthetic current-character snapshot from 16:30 CET, shown
as 90 minutes old when included. Bank units require withdrawal before posting.
This owner-requested counting behavior is a prototype choice, not validation of
real bank observation APIs or a crafting-material subtraction policy.
The frozen review clock is 14 Nov 2026 18:00 Europe/Stockholm (CET, UTC+1).
Ordinary latest source observation is 17:22; illustrative import is 17:48.
Market mapping and all holdings/prices are unverified synthetic fixtures.
No local scan is claimed; the history is labelled synthetic backend history.

## Validation and boundaries

Headless Chromium checked the complete bag list, bank-only inclusion, bag/bank
quantity changes, total AH/vendor arithmetic, currency denominations, cached-bank
age, selection when bank is excluded, sidebar mark/unmark movement, independent
detail selection, keyboard focus after moving rows, shared filtering, all ranges
and missing-value scenarios. All 38 browser checks passed, including destination comparison, distinct button
colors, ties, unknown metadata and retained scheduling. The compact addon surface was checked to remain under 760px tall. Desktop rendering was inspected at a
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

2026-11-14 feedback implemented: make the UI more compact, show all inventory
items in the sidebar, show AH and vendor totals for owned quantity with unit
calculations, and add Include bank to count bank items when selected.
Further review and actual-client readability remain pending. Existing direction prefers lowest buyout
and vendor comparison, with native WoW integration; it is not approval of this
layout. Review whether the bag rail/detail split is comfortable at normal play
size, whether price/stock/age are readable, and whether “Mark for sale” clearly
means later intent. Record feedback here before claiming owner acceptance.

2026-11-14 follow-up feedback: moved sale marking from the detail panel to small
sidebar row buttons. Marked items occupy a separate sidebar section; removing a
mark returns the item to Inventory. All included items appear exactly once across
the two sections. Filtering and Include bank apply to both; hidden bank-only
marks remain intent and reappear when bank inclusion is enabled again.

2026-11-14 destination feedback: sidebar actions are gold AH when lowest unit
buyout exceeds unit vendor sell value, green Vendor when vendor is at least as
high, and neutral/disabled Review when a comparison is unknown. A successfully
observed market with no buyout listings uses known vendor value. Equal values
use Vendor as the provisional tie choice. Small Egg illustrates the vendor-best
case; the Equal AH and vendor value scenario illustrates ties. Labels accompany
colors. Both totals use the same owned count, so unit comparison yields the same
destination as comparing owned totals. Marking remembers the selected destination
until unmarked; later scenario changes do not silently rewrite scheduled intent.
Revalidation before an actual sale remains future work; no vendor sale or AH
post is executed by this prototype.
