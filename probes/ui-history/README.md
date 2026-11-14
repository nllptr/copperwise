# Addon history-window design study

Ticket 17: disposable browser prototype, synthetic data only. Open `index.html`
in a browser, or serve this directory with `python3 -m http.server 8017` and
visit `http://localhost:8017`. No build, backend, credentials or dependencies.

The outer controls belong to the study, not the proposed addon. Choose between
Field journal (persistent item rail) and Compact ledger (horizontal search and
item selection). The intended addon uses a fixed dark palette for in-game use.

## Review tasks

1. Search `copper`, press Enter, and switch between all three ranges. Compare
   asking-price movement with stock using the aligned axes.
2. Select Sparse evidence. Median and spread are withheld; stock stays visible.
3. Compare Observed empty supply against Collection gap, preferably at 24 hours.
   Empty has observed zero stock and no price; missing collection breaks both
   series without connecting the gap.
4. Compare Supported / no history, Unsupported item, and No usable dataset.
   None presents missing data as zero stock.
5. Select Aged source data. Cached browsing remains possible. Dataset source
   time and import time are separate. No companion heartbeat or newer-export
   detection is implied.

## Design decisions to review

- Recommend Field journal: a stable item rail makes repeated browsing easy.
  Copper indicates price, a quieter green-gray indicates stock; explicit labels
  carry meaning independently of color. Ornament is limited to the window frame
  and serif item/title treatment.
- Keep both graphs on the same requested time domain, including unavailable
  leading time. Seven-day mode deliberately contains just 6d 8h of history.
- Put current summaries above the graphs; keep provenance and refresh guidance
  below. Price spread is explicitly separated from confidence and sales.
- Do not show a Refresh button that suggests immediate imports. Login and the
  user's `/reload` are the accepted boundaries.
- Use different empty-state messages for item coverage, unsupported identity,
  and dataset availability. A green loaded-data indicator does not guarantee
  coverage for every selected item.

## Fixtures and limitations

- Frozen study clock: 14 Nov 2026 18:00 Europe/Stockholm. Latest ordinary source
  observation 17:22, import 17:48. Aged fixture shifts source observations back
  48 hours while keeping the recent import, illustrating why import age alone
  is misleading. These are synthetic timestamps, not live telemetry.
- Deterministic hourly samples span 16 days. Range changes select actual sample
  subsets, not relabeled copies. Smooth curves are generated sample values;
  they do not establish an upstream cadence, price behavior or interpolation
  policy. Median and band values are illustrative, not computed quantiles.
- Sparse/aged scenarios are manually selected fixtures, not numerical evidence
  or freshness policies. No thresholds are finalized. Sparse suppresses all
  price estimates in the selected fixture; stock is retained.
- EU RP Alliance is the intended market label, with mapping explicitly marked
  unverified. This does not pass the upstream feasibility gate.
- The scenario picker applies to the selected sample item. It is a review tool,
  not a production capability. Search covers three synthetic item names only.

## Validation and capability boundary

Browser checks ran with headless system Chromium through Playwright. All eight
scenario transitions completed with no JavaScript errors. Item selection, range
selection, search and no-match feedback worked. Desktop rendering was inspected
at a 900px browser viewport (860px addon surface). The compact layout at 320px
had no horizontal page overflow. Desktop and narrow screenshots were inspected;
the narrow reflow is a stress check, not a mobile product commitment.

Ticket 03's report records owner-verified basic graph alignment/local-time labels,
sample lookup, open-window and hovered-item bindings, and opening away from the
auction house on client 1.60.1 (70938), interface 16001, macOS 26.6.2 Intel.
Those capabilities support this direction. This exact layout, multi-day density,
band styling, range controls, state messages, font sizes and in-game UI scale
remain unvalidated in the target client. Browser inspection is not client proof.
No new addon behavior, import transport or production pipeline was implemented.

## Feedback and open questions

Owner design feedback (2026-11-14): The median may not be a useful primary
reference; the owner wants help selling quickly at a profit and considers the
lowest available asking price relevant. Neither layout is approved. This is a
change from the agreed descriptive-viewer scope, recorded in ticket 17 for
follow-up rather than treated as an already implemented pricing feature.

Next design question: present lowest buyout alongside stock available at the
cheapest price levels, preserving broader context so a single cheap unit does
not masquerade as the whole market. Asking prices alone do not establish sale
speed. Profit needs acquisition/crafting cost and applicable selling costs;
the source and scope of those inputs are unresolved.

Subsequent owner clarification: compare item buyout against its vendor sell
value, including for non-crafted goods. Crafted goods should additionally show
a separate cost-to-craft line: sum recipe quantities times vendor purchase prices
for vendor-sourced components or lowest observed AH buyout unit prices for
AH-sourced components, normalized by recipe output quantity. These reference
lines are requested design direction and are not implemented in this study yet.
Vendor value is an alternative sale value, not the player's acquisition cost.
Craft cost is a replacement-cost estimate, not recorded spend or net profit.
Dual-source ingredient rules, auction deductions, recipe metadata and missing
component coverage remain unresolved. Historical cost lines need component
observations aligned to their historical time, rather than today's input costs.

Further owner clarification: potential sell value is the crafted item's lowest
current buyout per unit; production value means per-output ingredient cost.
Their difference is the proposed estimated crafting margin. The owner elects
to omit posting deposits under the successful-sale/refund assumption. The
reported deposit amounts and impending changes are not verified fee rules.
Any separate sale cut still needs verification; a margin before that cut must
not be labelled net profit. This is recorded direction, not an implemented
calculation, forecast of sale speed, or guarantee of sale at the observed price.

Latest owner clarification supersedes the separate-cut question above: the
target environment has no separate auction-house sale cut. Use that stated rule
for the design and omit the "before sale cut" qualifier. Estimated crafting
margin = lowest current buyout per unit minus crafting cost per output unit;
deposits remain excluded under the successful-sale assumption. No further fee
confirmation is required to proceed with this design exploration.

- Is an approximately 860px-wide window comfortable alongside bags/chat at the
  owner's usual resolution and UI scale? Confirm in the target client.
- Does the persistent item rail help more than the compact horizontal layout?
- Are explicit copper denominations readable in the summary, or should the
  presentation use game coin textures once validated?
- Is the spread explanation clear without further help? Are withheld estimates,
  zero stock and collection gaps distinguishable at ordinary play distance?
- Should exact per-observation inspection be added? This study does not implement
  chart hover/scrubbing or infer that the target client supports the desired UX.

Findings are provisional inputs to tickets 07–11 and 14, not completed production
acceptance criteria. Ticket 17 remains in progress pending owner feedback and
the in-game readability check. Ticket 05 and other feasibility gates still apply.
