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
the owner's normal UI scale remains unverified and will be checked during
actual addon implementation; it does not block acceptance of S01. This ticket creates no addon,
backend contract, bank access, posting path or production queue.

## Owner feedback

2026-11-14 feedback implemented: make the UI more compact, show all inventory
items in the sidebar, show AH and vendor totals for owned quantity with unit
calculations, and add Include bank to count bank items when selected.
2026-11-14 acceptance: the owner approved the revised layout (“this looks good”)
and agreed that browser review at approximately the intended addon scale is
sufficient for this disposable prototype. S01 is complete. Native fonts, UI
scaling and coexistence with bags/chat still require an actual-client check
during addon implementation. This approval covers the prototype layout, not
production data access, transactions or outstanding policies in other tickets.

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

## Crafting journey (S02)

Select Crafting on the same page. All recipe names, yields, prices and holdings
are invented fixtures. Inventory behavior is unchanged.

The owner's follow-up replaces the initial verbose per-output presentation:

- Sidebar rows show recipe name and estimated **margin per craft**, accounting
  for output yield. Positive margins are green and negative margins red; zero
  and unavailable margins stay neutral. The minus sign remains visible. Colored icons mean learned; grayscale icons mean unlearned.
  Accessible labels and hover titles also identify learning status. Unknown
  margins show a dash. Include unlearned recipes controls their visibility.
- Three detail metrics show **Cost / craft**, **AH value**, and **Vendor value**.
  The selected craft count multiplies output yield for both sale values.
- Ingredient costs now use AH prices. Cost is the additional material cost after
  subtracting owned ingredients once from the selected batch's requirements.
  Per-craft cost is that batch total divided by craft count; the total is shown
  beneath it. Fractions are displayed to two decimal copper places; sale values
  and batch totals use their exact fixture amounts.
- Sidebar margins compare a single craft's output AH value with its additional
  material cost after ownership. They describe alternative choices, not reserved
  materials. They do not change when the selected detail count changes.
- Bags count by default. Optional cached-bank subtraction remains an explicit
  comparison in Queue & materials; enabling it affects costs and sidebar margins
  as well as the shopping table. Bank eligibility is still an open production
  policy. Unknown bank counts remain unknown and are not credited.
- Craft intent and its combined shopping table are in a collapsed section below
  the quantity control. Adding intent opens it. Shared needs aggregate before
  ownership subtraction, and shortages never become negative. Queue counts are
  independent of the current detail preview; page refresh clears intent.
- Longer price/source explanations are under Price details. Synthetic status
  remains outside the addon surface. No purchasing or crafting is executed.

### Worked examples

Practice Tonic requires two reagents at 10c AH each plus three herbs at 20c AH
each, producing two items per craft. Bags contain one reagent and two herbs:

| Crafts | Output items | Cost still to buy | Average cost / craft | AH value | Vendor value |
| --- | --- | --- | --- | --- | --- |
| 1 | 2 | 30c | 30c | 140c | 10c |
| 2 | 4 | 110c | 55c | 280c | 20c |
| 3 | 6 | 190c | 63.33c | 420c | 30c |

The sidebar shows 110c/craft for this recipe: 140c output value minus 30c
additional cost for one craft. Unpriced Elixir withholds estimates when an input
price is missing. Missing output observations withhold AH value and margin.
Optional bank preview covers the first two Practice Tonic crafts entirely;
a third craft still needs 80c of additional inputs. Historical crafting costs
remain withheld because contemporaneous input observations are unavailable.

### Verification and owner feedback

2026-11-14: Owner requested less text, icon-only learned/unlearned differentiation,
sidebar margin per craft, AH-based ingredient costs net of owned materials, and
AH/vendor totals multiplied by output quantity. Implemented as described above.
This supersedes the original replacement-cost/per-output detail proposal for
this prototype; it is not a production pricing contract or ranking approval.

33 revised Chromium checks passed for simplified recipe rows, learned/unlearned
icons, yield-aware margins, one/two/three-craft arithmetic, fractional averages,
ownership credited once, bank comparison, missing estimates, invalid quantities,
Inventory restoration and a Crafting surface under 760px tall. The 38 Inventory
checks also passed. Screenshots were inspected at 960px viewport width. JavaScript
syntax and the Go suite are checked separately; this HTML has no typechecker.
These browser checks establish prototype behavior, not client capabilities.

The revised design awaits owner review. Queue persistence, sorting behavior and
production bank subtraction remain open; the owner's quantity and display
feedback above is recorded rather than treated as approval of those policies.
