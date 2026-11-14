# 17: Explore the addon history-view UI

**What to build:** A disposable UI prototype using clearly labelled synthetic history, to evaluate the in-game browsing experience before production implementation.

**Type:** prototype

**Blocked by:** None. Uses the capabilities verified in 03; requires no upstream credentials. Production implementation remains subject to 05.

**Status:** in-progress — browser study ready for owner review; in-game readability pending

- [ ] Explore the main addon window: item-name search and selection, market identity, two aligned price/stock graphs, and 24-hour, seven-day default, and all-retained range controls.
- [ ] Show median buyout unit price, middle-50% price spread, and all-listed-unit stock with readable units, local time labels, timezone, and actual coverage. Synthetic values and provisional evidence rules must be explicit.
- [ ] Explore adequate history, sparse evidence with withheld estimates, observed empty supply, collection gaps, supported items without history, unsupported items, aged source data, and no usable dataset.
- [ ] Show source observation age and import time separately. Explain login and user-initiated `/reload` refreshes without claiming live connectivity or knowledge of newer exports.
- [ ] Evaluate readability at a realistic in-game window size and record which interactions use already verified client capabilities. Browser-only behavior is illustrative until checked in the target client.
- [ ] Record screenshots or a runnable local prototype, owner feedback, design decisions, and remaining questions. Feed findings into dependent implementation tickets without claiming their acceptance criteria are complete.

## Scope

Focus on the addon history window first. Companion configuration and diagnostics can be a separate spike. Use synthetic fixtures; no backend, authentication, production export contract, finalized quantile rules, or freshness thresholds are required or established by this work.

## Questions to answer

- Can the seller quickly find an item and compare asking-price movement with listed supply?
- Are gaps, zero supply, and withheld prices visibly distinct?
- Is the price band understandable as spread rather than confidence or sales evidence?
- Are coverage, source age, and the refresh model clear without dominating the graphs?

## Comments

2026-11-14: Second `to-spec` synthesis integrates the expanded direction into
the [current workflow spec](../../selling-context/spec.md): Inventory/Crafting
tabs, revised price references, owned-material visibility, queues and native AH
workflows. Use it as the current scope rather than reconstructing decisions
from the historical comments below. The owner confirmed the existing pipeline
test boundary plus extended actual-client checks for native workflows. The
browser prototype remains the earlier screen; new UX and client acceptance
are not claimed complete.

2026-11-14 — Owner's product positioning: Auctionator is valued for simplicity;
TradeSkillMaster for power, but its complexity is the gap Copperwise should
close. Favor understandable defaults, plain labels, clear costs and queues over
expert configuration. This is a usability goal for the agreed workflows, not a
request for full TSM feature parity. Recorded in the broader spec and brief.

2026-11-14 — Owner confirms automatically subtracting owned ingredients from
the crafting shopping list, with visible location flags/breakdowns for bags
versus bank. Keep owned amounts and remaining-to-buy amounts distinct, with
withdrawal/transfer needs visible. Bank observation freshness and subtraction
eligibility still need definition. Tracking holdings of other characters,
including a banking alt, is explicitly a later decision, not an accepted
implementation commitment. Record this in the expanded queue UX; it is not
implemented by the current prototype.

2026-11-14 — Owner supersedes Auctionator-first preference: prefer a standalone
Copperwise auction-house tab; Auctionator is a fallback if native integration
is difficult. Also extend Crafting with a "to craft" queue whose recipes drive
ingredient purchasing at the auction house. Keep craft/output counts, ingredient
sources, estimated versus actual prices, and explicit purchasing actions clear.
This extends purchasing/planning scope for queued ingredients; it does not
establish automatic buying/crafting or target-client feasibility. Quantity,
ownership subtraction, partial completion and queue persistence need design.
Latest direction is recorded in the selling-context spec; prototype work has
not yet implemented either queue or the auction-house tab.

2026-11-14 — Owner extends Inventory UX with "mark for sale" intent while
browsing owned items; at the auction house these marked items should feed a
rapid posting workflow. Research Auctionator's actual supported selling-list
integration first. A shopping-list API is not proof of a selling-list API. If
unsuitable, explore a Copperwise auction-house tab using supported posting APIs
and required user actions. This reopens the prior posting exclusion for this
flow; no API, automatic posting or compatibility is established. Include bag
availability versus bank holdings, quantities, current price review and posting
outcomes in follow-up design. The broader direction is recorded in the
selling-context spec; this prototype still does not implement the selling queue.

2026-11-14 — Owner's main-window UX direction: set tooltip exploration aside
for now. Explore two tabs: Inventory lists items owned in bags, potentially
including bank holdings; Crafting lists recipes for the character's professions
and offers an option to include unlearned recipes to investigate acquiring them
for profit. Selecting an item/recipe opens its market data. Both tabs should
support ranking by estimated profitability. This extends the original search-
first browsing spike; bag/bank/profession/recipe-catalog access has not been
established by ticket 03. Do not imply all bank data is current or that an
unlearned recipe is craftable. Inventory profit lacks a recorded acquisition
cost: explore auction value above vendor value with an explicit label rather
than silently equating it to actual profit. Ranking basis (per unit versus owned
stack/recipe output), incomplete-input handling and recipe acquisition metadata
remain design questions. No implementation or owner acceptance is claimed.

2026-11-14: Broader owner feedback is now synthesized in the
[selling-context specification](../../selling-context/spec.md), labelled
ready-for-agent. Use that amendment when revising the synthetic spike's price,
vendor-value and crafting-cost references. The current browser study has not yet
implemented those new references; owner review and in-game readability remain
pending.

2026-11-14 — Owner resolves fee assumption for the design: there is no separate
auction-house sale cut in the target environment; the only fee is the deposit
already discussed. Use this owner-specified rule for this prototype and remove
the proposed "before sale cut" qualifier. Estimated crafting margin per unit is
lowest current buyout unit price minus per-output crafting cost, with deposits
excluded under the successful-sale assumption. This supersedes earlier comments
treating a separate cut as an unresolved design question. It does not establish
that a sale occurs at the observed price or recover deposits on failed listings.

2026-11-14 — Owner clarification of margin and deposits: Use the crafted item's
lowest current buyout unit price as its potential sell value, and the per-output
recipe ingredient cost as its production cost. Present their difference as an
estimated crafting margin at the observed buyout, not realized profit or a
guaranteed executable sale. The owner explicitly elects to exclude the posting
deposit from this successful-sale comparison: they report that it is refunded
on sale and only lost if the auction does not sell. They report a current fee
around 1 silver, a forthcoming change to 1 copper, and duration scaling; these
are owner-supplied context, not verified client fee rules and must not be
hardcoded. Failed/repeated listings can still incur excluded deposit losses.
Any distinct auction-house sale cut remains to be verified; until accounted
for, label the displayed difference as before any sale cut, rather than net
profit. Keep this caveat compact in the proposed interface. No fee or margin
calculation is implemented in the existing browser study yet.

2026-11-14 — Owner clarification of comparison lines:
- Use the item's vendor **sell** value as a comparison for non-crafted items and
  crafted items. This is the alternative disposal value, not acquisition cost.
- For crafted items, show a separate cost-to-craft line based on recipe inputs:
  vendor **purchase** prices for vendor-sourced components and the lowest
  observed auction-house buyout unit price for components sourced through the
  auction house. Multiply by recipe quantities and divide by output quantity
  to compare per-unit values. Component source selection for dual-source items
  remains an open question; do not silently choose a rule.
- Preserve source times and missing-component states. An unavailable component
  price must not become zero cost or a complete craft-cost estimate. A historical
  crafting-cost line needs contemporaneous component observations; do not apply
  today's component prices retroactively without an explicit alternative label.
- These are replacement-cost comparisons, not the player's recorded costs.
  A spread above vendor value or estimated crafting cost is not realized profit;
  auction deductions and any relevant deposit costs need separate treatment.
This records the owner's expanded product direction. Recipe/vendor metadata,
price semantics, cost completeness and the revised production scope still need
design and validation; the existing V1 spec and implementation gates remain as
recorded until reconciled.

2026-11-14 — Owner feedback: The median may not be the most useful reference.
The owner wants the addon to help users sell quickly at a profit and sees the
lowest available asking price as relevant to faster selling. This changes the
intended outcome beyond the currently agreed descriptive trend-viewer V1.
Revisit the price presentation around the lowest buyout and quantity available
at the cheapest price levels; do not replace the median with an unqualified
minimum or infer sale speed from asking-price snapshots. Profit requires a
seller-specific acquisition/crafting cost and applicable selling costs. Those
inputs and an expanded pricing-assistance scope remain to be agreed. The
existing spec has not been silently rewritten and no price recommendation,
sale-speed prediction or profit estimate has been implemented.

2026-11-14: Added a runnable synthetic [UI study](../../../probes/ui-history/README.md)
with Field journal and Compact ledger layouts, all eight requested state fixtures,
item-name search, aligned graphs and three actual range subsets. README records
design decisions, browser checks, ticket 03 capability boundaries and open
questions. Owner feedback and exact target-client readability remain pending;
production acceptance and Phase 0 gates are unchanged.

2026-11-14: Added following the owner's suggestion of a UI design spike while ticket 02 awaits upstream credentials. This is independent exploratory work; existing feasibility gates and blocking edges remain in force.
