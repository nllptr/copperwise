# Copperwise inventory, crafting and auction-house workflows

Status: open
Labels: ready-for-agent
Owner approval: 2026-11-14 — integrated scope and testing boundaries approved; explicit open decisions remain to be resolved during follow-up work.

## Problem Statement

The owner wants to sell quickly at a profit without the complexity they
associate with TradeSkillMaster. Auctionator provides the desired simplicity,
but the owner wants a standalone addon that connects inventory review, market
history, crafting economics and actions at the auction house.

A median asking price alone does not answer whether to vendor an item, post it
now or wait. The player needs the cheapest observed competition, listed supply,
vendor sell value and, for crafts, ingredient costs. After deciding, the player
should be able to mark items for sale or queue crafts and carry those decisions
to the auction house instead of rebuilding lists manually. Ingredient shopping
must account for owned materials and show whether they are in bags or the bank.

Asking prices do not prove completed sales, realized profit or future price
movement. The product supports the player's judgment without guaranteeing a
quick sale or predicting that a rising historical price will keep rising.

## Solution

Use Auctionator's simplicity as the usability target, with the depth needed for
the agreed selling and crafting decisions. This is not TradeSkillMaster feature
parity. Use plain labels, useful defaults, explainable estimates and explicit
queues; do not require pricing expressions or complex rules before basic use.

Shared design guideline: Copperwise should feel integrated with the target
client's native World of Warcraft UI, following the quality the owner values
in Auctionator. Use supported native frames, controls, fonts, item icons, coin
presentation and tab conventions where suitable. Match familiar spacing,
selection/disabled states, window behavior and UI scaling; preserve normal game
shortcuts and existing auction-house interactions. Apply this consistently to
the main Inventory/Crafting window and the Copperwise AH tab. Custom graphs and
queue views should extend that visual and interaction language. Evaluate the
result in the actual target client at the owner's normal UI scale; a standalone
browser mockup does not establish native fit. Auctionator is a reference for
integration quality, not a required dependency or an instruction to reproduce
its layout. This is a shared product guideline, not repeated ticket boilerplate.

The main addon window has two tabs sharing selected-item market detail:

- **Inventory:** list the current character's bag items, with bank holdings as an
  optional inclusion where observable. Select an item to inspect market data,
  sort by an explicitly labelled estimate of selling value, and mark owned items
  for sale. Without personal acquisition costs, extra auction value above vendor
  value is a comparison baseline, not actual profit.
- **Crafting:** list recipes for the character's professions, select a recipe's
  output to inspect market data and crafting cost, sort by estimated crafting
  margin, and queue desired crafts. Provide an option to include unlearned
  recipes for evaluating whether to obtain them. Unlearned is distinct from
  currently craftable; discovering a recipe does not imply it is owned.

Market detail brings together lowest observed buyout per unit, vendor sell
value, a separate crafting-cost line where applicable, and aligned price/supply
history. Preserve 24-hour, seven-day default and all-retained ranges, actual
coverage, local time, gaps and honest missing-data states. Median and middle-50%
price spread may remain secondary context; their final prominence is unresolved.
The player uses this information to weigh vendor now, post now or wait.

Prefer Copperwise's own auction-house tab for the next actions. Carry marked
inventory into a rapid posting workflow and expand the crafting queue into
ingredient shopping requirements. Subtract owned materials automatically, show
bags and bank quantities separately, and flag withdrawal needs. Purchases and
posts use supported game mechanisms and required user actions. Queueing itself
neither buys nor posts nor crafts anything. Auctionator is a fallback only if
native integration proves difficult and a suitable supported interface exists.

Use two clearly identified market sources: supported in-game auction scans for
recent observations while at the auction house, and backend/API collection plus
the companion for accumulated history, including offline periods. Client scan
work can begin while API credentials are pending. Local scan observations do
not change the login/user-initiated `/reload` boundary for companion imports.

## User Stories

1. As a casual seller, I want the addon to be understandable without expert configuration, so that I can make useful decisions quickly.
2. As a casual seller, I want an Inventory tab listing my bag items, so that I can review what I already own.
3. As a casual seller, I want an option to include observable bank holdings, so that I can consider stored items without confusing them with bag items.
4. As a casual seller, I want owned quantities identified by location and freshness, so that I know what is immediately available.
5. As a casual seller, I want to select an inventory item and see its market detail, so that I can decide whether to vendor, post or wait.
6. As a casual seller, I want inventory sorting by a clearly defined selling-value comparison, so that I can find promising items without mistaking it for recorded profit.
7. As a casual seller, I want to mark owned items for sale while away from the auction house, so that my decision carries into the posting workflow.
8. As a casual seller, I want sale selections carried to the auction-house tab, so that I do not have to reconstruct my list there.
9. As a casual seller, I want to review selected quantity and price before posting, so that an old selection does not cause an unintended auction.
10. As a casual seller, I want posting results and unavailable items identified, so that I can see what remains to be sold.
11. As a casual seller, I want a Crafting tab for my professions' recipes, so that I can explore what to produce.
12. As a casual seller, I want to select a recipe and inspect its output's market detail, so that production and sale comparisons stay connected.
13. As a casual seller, I want recipes sortable by estimated crafting margin, so that I can find promising crafts.
14. As a casual seller, I want an option to include unlearned recipes, so that I can investigate recipes worth obtaining.
15. As a casual seller, I want unlearned recipes clearly marked, so that a planning opportunity does not appear immediately craftable.
16. As a casual seller, I want to queue a chosen craft and quantity, so that I can plan ingredient shopping.
17. As a casual seller, I want craft counts distinguished from output quantities, so that multi-output recipes produce the right requirements.
18. As a casual seller, I want the crafting queue expanded into ingredient quantities, so that I know what materials are needed.
19. As a casual seller, I want owned ingredients automatically subtracted from shopping needs, so that I avoid buying materials I already have.
20. As a casual seller, I want required, bag-owned, bank-owned and remaining-to-buy amounts visible, so that I can understand the subtraction.
21. As a casual seller, I want bank withdrawals flagged, so that owned materials are not mistaken for immediately usable materials.
22. As a casual seller, I want cached bank holdings identified with their observation age, so that stale counts are not presented as fresh certainty.
23. As a casual seller, I want vendor and auction-house ingredients distinguished, so that I shop at the appropriate source.
24. As a casual seller, I want to purchase required AH ingredients from the queue workflow, so that crafting plans lead directly to supported shopping actions.
25. As a casual seller, I want current purchase prices distinguished from prior estimates, so that I can review changed economics before spending.
26. As a casual seller, I want purchase outcomes and remaining requirements visible, so that partial shopping does not appear complete.
27. As a casual seller, I want a native Copperwise auction-house tab where feasible, so that Auctionator is not a default dependency.
28. As a casual seller, I want the lowest observed buyout per item unit prominently shown, so that I can inspect the cheapest observed competition.
29. As a casual seller, I want differently sized listings normalized per unit, so that price comparisons are consistent.
30. As a casual seller, I want lowest-buyout history aligned with listed supply, so that I can compare price movement and competition over time.
31. As a casual seller, I want vendor sell value for crafted and non-crafted items, so that I can compare auction value with direct vendor disposal.
32. As a casual seller, I want vendor sell value distinguished from vendor purchase price, so that sale proceeds are not confused with ingredient costs.
33. As a casual seller, I want a separate crafting-cost reference line, so that I can compare production cost with potential sell value.
34. As a casual seller, I want vendor-sourced ingredients costed at vendor purchase price, so that the estimate follows the agreed acquisition basis.
35. As a casual seller, I want AH-sourced ingredients costed at their lowest observed buyout unit price, so that the estimate follows the agreed market basis.
36. As a casual seller, I want recipe quantities and output yield included in unit cost, so that the comparison covers the full recipe.
37. As a casual seller, I want estimated crafting margin shown as lowest output buyout minus crafting cost per output unit, so that positive, zero and negative comparisons are clear.
38. As a casual seller, I want refundable posting deposits excluded under the successful-sale assumption, so that the estimate follows the agreed fee model.
39. As a casual seller, I want no separate auction-house sale cut deducted in this environment, so that the comparison follows the owner's stated rules.
40. As a casual seller, I want excluded failed-listing deposit losses disclosed compactly, so that I understand the estimate's limit.
41. As a casual seller, I want missing recipe, vendor or ingredient data disclosed, so that unknown inputs do not appear as zero costs.
42. As a casual seller, I want incomplete crafting margins withheld, so that missing inputs do not make a craft appear profitable.
43. As a casual seller, I want historical costs based on contemporaneous inputs, so that today's component prices do not rewrite the past.
44. As a casual seller, I want observed empty supply distinguished from missing collection, so that no price is not drawn as a zero price.
45. As a casual seller, I want thin or questionable observations disclosed, so that one cheap unit does not imply plentiful supply or an achievable purchase.
46. As a casual seller, I want price spread distinguished from confidence and sales evidence, so that secondary context is not overstated.
47. As a casual seller, I want item search and three history ranges preserved, so that deeper browsing remains accessible from either tab.
48. As a casual seller, I want actual coverage, local time and timezone visible, so that partial history is apparent.
49. As a casual seller, I want cached history usable during outages, so that an update problem does not erase existing context.
50. As a casual seller, I want source observation and import times separate, so that a new import cannot disguise old market data.
51. As a casual seller, I want history imports at login or user-initiated `/reload`, so that the addon follows the accepted delivery model.
52. As a casual seller, I want in-game scanning for recent AH observations, so that current competition can inform my actions while playing.
53. As a casual seller, I want scan time and coverage identified separately from imported history, so that I know which source I am viewing.
54. As a casual seller, I want incomplete, throttled, cancelled and failed scans distinguished from observed empty results, so that missing coverage is not mistaken for zero supply.
55. As a casual seller, I want offline periods covered by backend history where collected, so that trends do not depend on my play sessions.
56. As a casual seller, I want scanning and price checks to respect supported client behavior, so that the workflow does not depend on bypasses.
57. As the owner, I want the revised journeys explored with synthetic fixtures, so that I can review usability before production implementation.
58. As the owner, I want native AH scanning investigated without waiting for API credentials, so that independent capability work can proceed.
59. As the owner, I want inventory, recipe and transaction capabilities checked on the target client, so that the design does not silently assume unverified behavior.
60. As the owner, I want cross-character holdings left for a later decision, so that banking-alt tracking does not silently expand the initial implementation.

## Implementation Decisions

- This revision replaces the prior pricing-only amendment as the current scope
  for inventory/crafting review, sale and craft queues, queued ingredient buying,
  marked-item posting and native scanning. It supersedes the original trend-only
  exclusions for these specific workflows. Automated pricing strategies, profit
  accounting and unrelated trading features remain excluded.
- Retain the initial target: Forever EU RP Alliance, macOS 26 Intel for the
  companion, owner-only releases and comparable supported trade goods. Verify
  item/recipe identity, market mapping and metadata in that environment.
- Keep the backend, companion and addon architecture. The backend collects
  shared history independently of play; the companion caches/exports it; the
  addon imports at login or user-initiated `/reload`. Native scan observations,
  bag changes and queue actions may occur during play through supported client
  APIs without implying in-session companion imports.
- The addon gains two main navigation contexts, shared selected-item market
  detail, inventory/recipe lookup, owned-material accounting, sale/craft queue
  intent, and AH scanning/transaction presentation. Specific schemas, wire
  contracts, storage formats, metadata providers and module APIs remain unset.
- Prefer a standalone Copperwise AH tab. Investigate target-client tab, query,
  buy and post APIs before selecting an implementation. Auctionator integration
  is a fallback, not a default dependency; a shopping-list API does not prove
  a selling interface exists. Third-party source is research, not runtime proof.
- Inventory is current-character bag holdings, optionally including observable
  bank holdings. Show location and cached-bank age. Cross-character inventory
  aggregation and unseen banking-alt contents are deferred. Unknown holdings
  are not a confirmed zero or freshly observed supply.
- Support inventory and crafting estimate sorts. Inventory auction value above
  vendor value is a candidate meaningful comparison when acquisition cost is
  absent; it is not personal profit. Whole-owned-stack versus per-unit ranking,
  and per-output versus per-craft recipe ranking, remain unconfirmed policies.
  Label the chosen basis explicitly; do not treat proposed defaults as approved.
  Missing estimates must remain identifiable rather than rank as free inputs.
- The recipe list covers the character's professions and can include unlearned
  recipes. Validate catalog completeness and discovery; do not imply unavailable
  recipe metadata is a complete list. Unlearned recipes are planning references,
  not proof of executable crafting. Recipe acquisition instructions and costs
  are not established by the include-unlearned option.
- Sale selections and craft selections are distinct intent. Selections must
  carry between the main window and AH workflow. Quantity editing, cancellation,
  persistence across logout/reload, stack policy and completion bookkeeping need
  design; no automatic posting, buying or crafting follows from selecting a row.
- Expand a selected recipe and craft count using required input quantities and
  known output yield. Show total required materials, owned by location and
  remaining to buy. Aggregate common ingredient needs without crediting the same
  owned unit more than once; a specific allocation/reservation policy is open.
- Automatically subtract eligible owned materials, with visible flags for bag
  versus bank counts and any withdrawals needed. Remaining shopping need cannot
  be negative. Cached-bank subtraction eligibility is unresolved; counts used in
  an estimate must be explicit, dated and distinguishable from confirmed bags.
  Do not assume automatic withdrawal or inter-character transfer.
- Keep vendor-sourced shopping requirements distinct from AH requirements.
  The AH workflow purchases queued AH inputs through supported user actions;
  automatic vendor purchases and craft execution are not included. Recheck
  bag quantities as purchases or inventory changes occur. Partial, failed and
  cancelled actions must not count as completed purchases/posts.
- At AH execution time, review available bag quantity and price before posting
  or purchasing. Bank-held items are not immediately postable. A historical
  lowest buyout does not prove sufficient purchase quantity at that price.
  Exact price selection, undercut policy, stack size, duration and number of
  actions required depend on design and supported client capabilities; no
  specific undercut amount or one-click batch transaction is agreed.
- Maintain separate provenance for local scans and imported backend history:
  source, market, observation time and coverage. Choose/label the source used
  for a comparison or transaction preview; do not silently merge minima across
  observations or overwrite historical points. Source-priority and reconciliation
  policies remain open, so estimates must expose the selected input basis.
- A scan is a bounded observation at the AH, not a guaranteed full-market or
  continuously live feed. Establish available query scope, throttling, result
  completeness, cancellation, market identity and stack semantics. Do not equate
  partial/no-response results with observed empty supply. Do not interrupt another
  addon's scan or assume concurrent queries are safe without evidence.
- Price references use the minimum comparable observed buyout per unit, excluding
  bid-only listings. Supply includes all units actually covered by the source,
  including bid-only/extreme-price listings where observed. Do not claim a partial
  scan's stock count covers the whole market. Minimum and median have different
  meanings; neither guarantees resistance to manipulation.
- Vendor sell value is the alternative-disposal baseline for an item. Vendor
  purchase price is an ingredient acquisition cost. Distinguish known zero from
  unavailable metadata. Collected or already-owned materials are not automatically
  zero replacement-cost ingredients.
- Complete crafting cost is the sum of recipe quantities times selected ingredient
  unit costs, divided by known positive output yield. Use vendor purchase prices
  for vendor-sourced inputs and lowest observed AH buyouts for AH-sourced inputs.
  Dual-source rules, multiple recipes, variable yields and vendor modifiers are
  unresolved; disclose and withhold a complete estimate when inputs are ambiguous.
  Recursive subcraft optimization is not implied.
- Estimated crafting margin equals the output's lowest observed buyout per unit
  minus crafting cost per output unit. Use enough currency precision that display
  rounding does not turn a non-positive margin positive. This is replacement-cost
  margin, not recorded spend, a guaranteed executable sale or realized profit.
- Use the owner's stated target-environment model: no separate sale cut; omit
  posting deposits under the successful-sale/refund assumption. Disclose excluded
  failed-listing losses compactly. Reported deposit amounts and impending changes
  must not become unverified hardcoded fee constants. Do not add a "before sale
  cut" qualifier or require renewed fee confirmation for this design.
- Historical reference lines need contemporaneous component/vendor data with
  temporal validity. Do not project today's inputs backward or bridge missing
  observations silently. Withhold incomplete estimates; preserve stock/coverage
  context where useful. Temporal alignment, evidence and age thresholds require
  validation, not invented constants.
- Preserve source/import age distinctions, coverage, gaps and cached browsing.
  Status must explain the particular source or workflow problem: missing imported
  history must not imply a successful local scan is unusable, and a local scan
  does not prove backend health. No loaded indicator proves a companion heartbeat
  or knowledge of a newer export.
- Backend/companion retention remains capped initially at 30 days under the
  existing policy, subject to terms validation. Local observation persistence,
  if needed, requires an explicit retention/reconciliation design. Do not create
  an unbounded side history by adding scanning.
- Existing Phase 0 gates remain prerequisites for the full pipeline. Credential-
  independent synthetic UX and local capability probes may proceed separately;
  no scan success passes the upstream/history gates or validates transactions.
  Tooltip UX is set aside for this exploration, not silently deleted from all
  prior commitments. Exact layout is still subject to owner review.

## Testing Decisions

- The owner explicitly confirmed the boundaries on 2026-11-14: retain the existing
  backend → companion → addon acceptance path and extend existing in-client checks
  to scanning, queue quantities, purchases and posting outcomes. Do not substitute
  private helper tests, fake client runtime or source inspection for visible
  target-client behavior. Test externally observable outcomes and use the fewest
  public boundaries necessary.
- For imported history, feed controlled upstream/vendor/recipe inputs through the
  real backend and companion cache/export, then inspect the addon after login or
  user-initiated `/reload`. Pair fixtures with live market/metadata smoke evidence.
  Verify no companion dataset replacement between those boundaries.
- For native workflows, use the actual target client at its public UI/API boundary:
  observe bags/bank and profession catalog, mark sale intent, queue a known craft,
  visit the AH, scan and perform explicitly user-initiated test transactions when
  the needed runtime access and test items are available. Record builds, actions,
  quantities, results, failures and limitations. Each new transaction requires
  runtime evidence; the earlier basic graph/binding probe does not establish it.
- Extend deterministic UI scenarios for both main tabs, shared market detail,
  estimate sorting labels, learned/unlearned recipes, both queues, required/owned/
  missing quantities and scan/history provenance. Browser checks validate only
  prototype interaction/readability; in-game evaluation establishes actual client
  behavior. Do not mark acceptance complete from a visual mockup.
- Verify recipe arithmetic through visible outputs. For example, two vendor inputs
  at 10 copper each plus three AH inputs at 20 copper each cost 80 copper per
  craft; two outputs cost 40 copper each. A 70-copper output buyout yields a
  30-copper margin per unit, with no separate sale-cut or deposit deduction.
- Cover per-unit normalization across stack sizes, bid-only observations, isolated
  cheap units, incomplete scan coverage, positive/zero/negative margins, multi-
  output recipes, missing inputs, variable/unknown yields and ambiguous sources.
  Unknowns must not become zero cost, a fabricated price or a complete margin.
- Check ownership subtraction with bags, dated bank counts, missing observations,
  over-supply, inventory changes and multiple queued crafts sharing ingredients.
  A proposed counted total must be traceable by location, never count the same
  unit twice and never produce negative shopping need. Apply a confirmed cached-
  bank eligibility policy once chosen; do not invent one inside a test fixture.
- Check queued versus executable quantity, bank-withdrawal flags, changed prices,
  insufficient AH stock, partial shopping, failed/cancelled posts and repeated
  actions. Only confirmed outcomes change completed quantities; do not infer a
  purchase or post from a click or request alone. Queue intent must not cause
  transactions without the required user actions.
- Exercise empty markets versus query failure, throttling/cancellation, other
  addons' active scans, client tab lifecycle and unsupported APIs. Record partial
  results honestly rather than widening their claimed coverage.
- Retain history tests for age, missing intervals, empty supply, stale inputs,
  cached browsing, outages, retention and historical input alignment. Ensure a
  recent local scan does not make old backend history look current or fill its
  missing periods. Confirm local workflows do not accidentally trigger imports.
- Prefer the existing delivery probe's public integration style and client probe's
  recorded runtime-evidence practice. Their current implementations are prior art,
  not finalized data contracts or proof of the expanded workflows. No production
  tests are claimed implemented or passed by publishing this specification.

## Out of Scope

- Guaranteed quick sales, forecast prices, inferred sale probability, automatic
  interpretation of recurring patterns, confirmed-sale analytics and realized-
  profit/personal acquisition-cost accounting.
- Automated pricing expressions/rule engines, strategy presets, unattended
  transactions, bypasses of client restrictions and guaranteed one-click batches.
- Automatic crafting execution, recursive subcraft optimization, automatic recipe
  acquisition, vendor purchasing automation and automatic queue-to-sale transfer.
- Cross-character/banking-alt holdings and automatic bank/character transfers;
  the owner explicitly left other-character tracking for a later decision.
- Failed-listing deposit-loss optimization and auction-duration recommendations.
- Full TradeSkillMaster feature parity, watchlists, alerts, public distribution,
  unsupported equipment variants and additional platform/market commitments.
- Treating local scans as offline collection, assuming full-market scan support,
  silently merging observations, continuous in-session companion imports or
  bypassing existing feasibility/retention requirements.

## Further Notes

This is the integrated result of the second `to-spec` synthesis on 2026-11-14.
It folds later discussion into the actual solution, stories, decisions, tests
and scope instead of retaining contradictory pricing-only exclusions plus a
chronological list of amendments. The latest preference is native Copperwise
AH integration first, Auctionator only as a fallback. Tooltip exploration is
paused while the main-window journeys take priority.

The owner confirmed testing boundaries in both a written selection and spoken
reply. The fee model is owner-specified, not independently measured fee behavior;
no further fee interview is needed for the proposed UX. No design approval of
ranking defaults, exact layout or transaction policy is implied by agreement on
product direction.

Remaining decisions: inventory and recipe ranking units; quantity selection,
queue persistence and cancellation; shared-material allocation; cached-bank
subtraction policy; recipe/vendor catalog access, dual-source inputs and variable
yields; scan scope/cadence and source priority; precise buy/post interaction and
price/stack/duration choices; temporal alignment and evidence thresholds.
Resolve these in focused design/capability work before locking their contracts.
Do not silently choose them as if already approved. Domain-modeling follow-up
should reconcile the glossary's existing casual-seller definition with crafting,
and define queue intent, estimated crafting margin and observation provenance.

`ready-for-agent` authorizes ordered spec/design/capability work, not a claim
that every policy or feasibility gate is resolved. The existing browser study
still demonstrates the earlier median/spread screen, not the new main window,
reference lines, queues or transactions. The scanning probe ticket is the
credential-independent native scan entry point. Reconcile the broader
implementation tickets before treating their original trend-only acceptance
criteria as sufficient. No production implementation is claimed by this spec.
