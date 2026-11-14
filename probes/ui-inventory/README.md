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

The same page now includes a Crafting tab sharing the output market-detail
renderer, ranges and review scenarios. Inventory selections and sale marks stay
separate from recipe selection and craft intent. All recipes (including names,
profession, yields, prices and ingredient holdings) are invented fixtures, not
claims about the target client's recipe catalog.

1. Select Crafting. Practice Tonic illustrates two vendor reagents at 10c plus
   three AH herbs at 20c: 80c per craft, two outputs, 40c cost per output.
   A 70c output buyout gives a 30c estimated margin. Vendor sell value is 5c,
   separately labelled from vendor ingredient purchase cost. Owned inputs retain
   replacement cost. The successful-sale deposit assumption and excluded failed
   listings are disclosed. No separate sale cut is deducted.
2. Select Unpriced Elixir to see an unknown ingredient price withhold complete
   cost and margin. Empty/missing output observations also withhold margin.
3. Enable Include unlearned recipes and select Study Draught. It is explicitly
   unlearned and cannot currently be crafted; its negative margin is visible.
   Adding its intent warns that learning is required. Hiding unlearned recipes
   resets selection but retains any intent in the queue, visibly labelled unlearned.
4. Enter **2 crafts** for Practice Tonic: the preview shows **4 output units**.
   Add craft intent to open combined material requirements: four vendor reagents
   and six AH herbs. One reagent and two herbs are in bags, so three reagents
   and four herbs remain to buy with bank preview off.
5. Toggle Preview subtracting cached bank. Three bank reagents and four bank
   herbs now cover those needs, with explicit withdrawal counts. Bank counts are
   synthetic, observed at 16:30 CET (90 minutes old); this toggle is a comparison
   tool, not a selected bank-eligibility policy. Unknown bank holdings remain
   unknown. Shared ingredient requirements aggregate before crediting ownership;
   surplus never becomes a negative shopping quantity.
6. Add another recipe to compare shared-material requirements; remove intents
   individually. Tab switches retain intent; refreshing clears it. There are no
   purchase/craft controls, storage, client APIs or working AH handoff.

Historical crafting-cost lines are withheld because the fixture has no
contemporaneous ingredient observations. The separate current per-output cost
remains visible. This avoids projecting today's ingredient costs backward.
Sorting stays in sample order with the ranking basis explicitly undecided.
Craft count, additive intent, removal and page-only lifetime are disposable
interaction proposals; they do not settle quantity, cancellation or persistence
rules for production (S06/S07). Queue contents are not executable craft counts.

### S02 verification and feedback

44 disposable Chromium UI assertions passed for recipe inclusion/selection,
worked-example economics, negative/incomplete margins, craft/output quantities,
invalid counts, shared requirements, bag/bank subtraction previews, unknown bank
counts, withdrawal needs, removal, and tab switching. The 38 existing Inventory
checks also passed. JavaScript syntax and the full Go suite are checked separately;
this HTML has no typechecker. Screenshots were inspected at a 960px viewport.
Browser checks establish prototype behavior only, not native fit or capabilities.

Owner review is **pending**. No owner feedback on this Crafting journey has yet
been received. Review prompts: Is recipe → craft count → required materials →
shopping understandable? Are “crafts” versus “output units” clear for multi-output
recipes? Is the optional bank comparison useful? Should queue and shopping detail
stay here or move to the AH context? Record answers here and in S02 before marking
the feedback acceptance item complete. S01 approval does not approve these choices.
