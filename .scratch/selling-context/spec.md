# Copperwise competitive asking prices and crafting margin

Status: open
Labels: ready-for-agent

## Problem Statement

The owner wants Copperwise to help casual sellers sell quickly at a profit.
The median asking price alone does not show the cheapest competing listings or
whether selling a crafted item at a competitive asking price covers the cost
of its ingredients. Non-crafted items also need a useful baseline: their vendor
sell value. These decisions belong to the product, not only the addon UI spike.

Asking-price observations cannot establish sale speed or completed sales. The
experience should support the owner's goal by making observed competition and
cost comparisons clear, without presenting a guaranteed sale or realized profit.

## Solution

Help the player weigh three choices: vendor now, post on the auction house now,
or wait. Vendor sell value provides the baseline, recipe costs provide estimated
crafting margin, and asking-price history plus listed supply provide competition
and trend context. The owner explicitly confirmed this purpose. The player
decides; a rising historical price or shrinking supply does not establish that
prices are about to rise, and waiting has an uncertain outcome. The addon does
not forecast prices or issue a promised sell/wait recommendation.

Make the lowest observed auction-house buyout unit price a primary reference
for the selected item. Show vendor sell value as an alternative-disposal
baseline for both crafted and non-crafted items. For crafted items, add a
separate cost-to-craft line and estimated crafting margin per output unit.

Compute crafting cost from recipe quantities: vendor purchase prices for
vendor-sourced ingredients, and the lowest observed auction-house buyout unit
prices for AH-sourced ingredients. Divide total recipe ingredient cost by the
recipe's output quantity. Potential sell value is the crafted item's lowest
observed buyout unit price. Estimated crafting margin is potential sell value
minus crafting cost per output unit.

Use the owner's stated target-environment fee model: no separate auction-house
sale cut. Exclude posting deposits from the successful-sale comparison under
the owner's stated refund-on-sale rule. No further fee confirmation is required
to design this comparison. Failed-listing deposit losses are outside this
estimate and should be disclosed compactly.

Keep the existing searchable addon window, aligned price/stock history, range
controls, cached browsing, provenance and login/user-initiated `/reload` model.
Explore the revised presentation with synthetic fixtures before production.
The median and middle-50% price spread may remain secondary market context;
their presence and prominence are still design questions, not owner approval
of the existing prototype.

## User Stories

1. As a casual seller, I want the lowest observed buyout price prominently displayed, so that I can see the cheapest observed competition.
2. As a casual seller, I want buyout prices expressed per item unit, so that I can compare differently sized listings.
3. As a casual seller, I want lowest-buyout history, so that I can inspect how the cheapest observed asking price changes over time.
4. As a casual seller, I want listed supply aligned with price history, so that I can compare competition and price movement.
5. As a casual seller, I want vendor sell value shown for non-crafted items, so that I can compare auction asking prices with a direct vendor sale.
6. As a casual seller, I want vendor sell value shown for crafted items too, so that the alternative-disposal baseline remains visible.
7. As a casual seller, I want vendor sell value distinguished from vendor purchase price, so that I do not confuse proceeds with ingredient cost.
8. As a casual seller, I want a separate crafting-cost line for crafted goods, so that I can compare potential sell value with production cost.
9. As a casual seller, I want recipe ingredient quantities included in crafting cost, so that the estimate covers the whole recipe.
10. As a casual seller, I want vendor-sourced ingredients valued at their purchase price, so that their known acquisition cost is represented.
11. As a casual seller, I want AH-sourced ingredients valued at their lowest observed buyout unit price, so that the estimate reflects the agreed market-cost basis.
12. As a casual seller, I want ingredient costs normalized by recipe output quantity, so that multi-output recipes have comparable per-unit costs.
13. As a casual seller, I want the crafted item's lowest observed buyout used as potential sell value, so that the comparison reflects the agreed competitive reference.
14. As a casual seller, I want estimated crafting margin displayed as potential sell value minus crafting cost, so that I can identify positive or negative comparisons.
15. As a casual seller, I want negative and zero margins presented honestly, so that an unfavorable comparison is not hidden or rounded into a misleading gain.
16. As a casual seller, I want posting deposits excluded from the successful-sale estimate, so that the calculation follows the owner's refund-on-sale model.
17. As a casual seller, I want a compact explanation that failed-listing deposit losses are excluded, so that I understand the estimate's boundary.
18. As a casual seller, I want no separate sale cut deducted in this target environment, so that the comparison follows the owner's stated fee rules.
19. As a casual seller, I want crafting margin labelled as an estimate, so that I do not mistake it for recorded profit.
20. As a casual seller, I want vendor value labelled as an alternative sale baseline, so that found items are not assigned an invented acquisition cost.
21. As a casual seller, I want incomplete recipe or component pricing disclosed, so that missing costs do not become zero-cost ingredients.
22. As a casual seller, I want crafting margin withheld when crafting cost or potential sell value is unavailable, so that an incomplete calculation does not appear profitable.
23. As a casual seller, I want an item without a vendor sell value identified explicitly, so that unavailable information does not appear as a valid zero.
24. As a casual seller, I want observation times for item and component prices available, so that a recent import does not disguise old inputs.
25. As a casual seller, I want historical crafting costs based on appropriately dated component prices, so that today's inputs do not silently rewrite the past.
26. As a casual seller, I want observed empty supply distinguished from missing collection, so that no buyout is not plotted as a zero price.
27. As a casual seller, I want sparse or questionable observations described honestly, so that a single cheap listing does not imply plentiful stock or an achievable purchase.
28. As a casual seller, I want optional median and price-spread context distinguished from the minimum, so that I can understand broader asking-price distributions.
29. As a casual seller, I want the price spread described as spread rather than confidence, so that distribution width does not imply trustworthy evidence.
30. As a casual seller, I want item search and 24-hour, seven-day and all-retained views preserved, so that the new references fit the existing browsing workflow.
31. As a casual seller, I want actual history coverage and local timezone displayed, so that partial or misaligned history is apparent.
32. As a casual seller, I want cached comparisons available when updates fail, so that outages do not remove useful history or conceal its age.
33. As a casual seller, I want source observation and import times kept separate, so that I understand when market prices were observed.
34. As a casual seller, I want updated exports loaded at login or user-initiated `/reload`, so that the UI follows the accepted delivery model.
35. As the owner, I want the revised price and cost presentation explored in the UI spike, so that I can review it before production implementation.
36. As the owner, I want target-market recipe, vendor and buyout semantics validated, so that attractive comparisons do not conceal incompatible inputs.
37. As a casual seller, I want vendor value, estimated crafting margin, asking-price history and listed supply considered together, so that I can weigh vendoring now, posting now or waiting without mistaking historical movement for a forecast.

## Implementation Decisions

- This amendment expands the agreed descriptive trend-viewer scope to include
  lowest-buyout references, vendor-value comparisons, recipe-based crafting
  costs and estimated crafting margin. It supersedes the original deferral of
  crafting analysis and estimated margin only to that extent. Auction execution,
  automated strategies, sale-speed predictions and realized-profit accounting
  are not introduced.
- Preserve the three-component architecture and responsibilities: backend
  normalizes market and supporting metadata; companion caches and exports;
  addon presents the loaded dataset. No production wire contract, schema,
  endpoint or vendor/recipe metadata provider is selected by this amendment.
- Lowest buyout means the minimum comparable observed buyout price per unit in
  a snapshot. Exclude bid-only listings from buyout references; continue counting
  all listed units in supply. Validate actual fields and stack semantics through
  the existing upstream feasibility work. A minimum is not unit-weighted median
  and must not inherit its meaning or manipulation-resistance claims.
- Use vendor sell value as an item baseline; use vendor purchase price for
  vendor-sourced recipe inputs. A known zero differs from missing metadata.
  Vendor baseline differences must not be labelled actual profit for found goods.
- For one identified recipe, total ingredient cost is the sum of required
  ingredient quantities multiplied by their selected source's per-unit costs;
  cost per output unit is that total divided by the known positive output count.
  Use sufficient currency precision internally; display rounding must not turn
  a non-positive margin positive. Validate recipe yields and identity rather
  than assuming every craft produces one item.
- Ingredient costs use the owner's specified source rules. Dual-source
  ingredients, multiple recipes, variable yields and vendor price modifiers
  remain unresolved metadata/policy cases. Do not silently select the cheapest
  source, recursively expand subrecipes, or invent a yield. Where the chosen
  recipe/source is unresolved, disclose it and withhold a complete cost estimate.
- Lowest AH input prices are replacement-cost references, not the player's
  recorded spend and not proof enough units are available to complete a recipe.
  Free materials gathered by the player are not automatically zero-cost inputs.
- Estimated crafting margin per unit equals the crafted item's lowest observed
  buyout unit price minus complete crafting cost per output unit. Do not subtract
  a separate sale cut. Deposits are deliberately excluded under the agreed
  successful-sale assumption. Do not hardcode the reported 1-silver deposit,
  prospective 1-copper change or duration scaling as verified fee constants.
- Identify missing component, recipe and vendor metadata. Missing buyouts,
  empty supply, unsupported identity or incomplete costs must not produce zero
  price, zero cost or a seemingly complete margin. A usable dataset may still
  lack a reference for a particular item.
- Historical item, ingredient and vendor inputs must retain their provenance
  and temporal validity. Use contemporaneous component observations for a
  historical crafting-cost line. Do not carry today's prices backward or fill
  gaps silently. Temporal alignment and stale-input thresholds need validation;
  withhold an estimate when a complete compatible input set is unavailable.
- Keep source age distinct from import age. Loaded status must not claim a
  live companion connection or knowledge of newer exports. Login and explicit
  user-initiated `/reload` remain the only addon import boundaries.
- Preserve initial platform, market, retention, internal-release constraints
  and Phase 0 gates. Recipe/vendor metadata and additional reference rendering
  require evidence before production acceptance. No visual spike proves them.
- Quantity near the cheapest price levels is a candidate follow-up visual for
  understanding a misleading single-unit minimum, not a finalized aggregation
  rule or an agreed replacement for the existing all-listed-stock graph.

## Testing Decisions

- Retain the owner's previously confirmed primary acceptance seam: controlled
  upstream inputs pass through the real backend, companion cache/export and
  addon, with visible results in the target client after login or user-initiated
  `/reload`. Extend controlled fixtures with vendor and recipe inputs at public
  ingestion boundaries. Do not add a separate internal test API or treat private
  helper tests as the acceptance boundary. No new testing seam is proposed.
- Continue prerequisite target-client capability checks and a live target-market
  smoke test to establish that deterministic fixtures match actual field, stack,
  vendor and recipe semantics. Existing client-probe evidence covers only its
  observed sample paths, not these new comparisons or their exact layout.
- Assert externally visible prices, costs, labels and margin signs. For example,
  a recipe using two vendor ingredients at 10 copper each plus three AH inputs
  at 20 copper each costs 80 copper per craft; with two outputs it costs 40 copper
  per output. A lowest output buyout of 70 copper yields a 30-copper estimated
  margin per unit, without a deposit or separate sale-cut deduction.
- Exercise differently sized listings, bid-only listings, an isolated cheap
  unit, positive/zero/negative margins, multi-output recipes, unknown or variable
  yields, unsupported variants, missing vendor values, missing component prices
  and ambiguous recipe/source mappings. Unknown inputs must withhold complete
  estimates rather than silently become zero.
- Cover contemporaneous history, component gaps and stale inputs, recently
  imported old source data, observed empty supply and collection failures.
  Verify historical costs do not reuse future/current component prices.
- Preserve the existing outage, retention, cached browsing and import-boundary
  scenarios. Component collection and cost data must respect the same retention
  policy rather than creating an unbounded side cache.
- Review the synthetic UI at a realistic addon window size; test search/ranges,
  aligned reference lines, readability of vendor versus craft cost and honest
  missing/aged states. Browser checks support design review only. Owner feedback
  and target-client readability remain separate evidence, not automatic passes.
- Follow the existing delivery probe's public-boundary integration testing
  approach without treating its experimental payload as a production contract.
  No production tests or implementation are claimed complete by publishing this
  specification.

## Out of Scope

- Posting, buying, automatic undercutting, one-click sale execution or automated
  pricing strategies.
- Guaranteed quick sales, inferred sale probability, sale-speed predictions,
  confirmed-sale claims, realized profit or personal cost-basis accounting.
- Deposit-loss modelling across failed/repeated listings, deposit optimization
  and auction duration recommendations.
- Recursive crafting optimizers, automatic source/recipe selection, crafting
  queues and production planning beyond the specified recipe-cost comparison.
- Watchlists, alerts, unsupported equipment variants, public distribution,
  additional platforms/markets and the other unchanged V1 deferrals.
- Bypassing feasibility gates, continuous in-session imports or silently choosing
  unresolved evidence/freshness thresholds and production data contracts.

## Further Notes

Synthesized from the owner's 2026-11-14 feedback on ticket 17 using `to-spec`.
The owner questioned the median's usefulness, established quick profitable
selling as the product goal, specified vendor and crafting reference lines,
defined ingredient source costs, elected to exclude refundable posting deposits,
and explicitly stated there is no separate sale cut in this target environment.
The fee model is an owner-specified product assumption; this spec does not claim
independent verification of fee amounts or client behavior.

`ready-for-agent` makes this specification available for ordered design and
implementation work; it does not declare feasibility complete. The current UI
study still shows the earlier median/spread exploration. Update that study next
to explore this amendment; do not imply the requested new lines already exist.
Reconcile implementation tickets through the ticket-planning workflow before
treating the old trend-only acceptance criteria as sufficient for this scope.

Remaining questions are recorded rather than interviewed here: recipe/vendor
metadata availability, dual-source components, recipe selection and variable
yields, historical input alignment policy, and final visual treatment of the
minimum alongside broader price spread and quantities near the cheapest prices.
