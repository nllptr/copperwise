# 17: Explore the addon history-view UI

**What to build:** A disposable UI prototype using clearly labelled synthetic history, to evaluate the in-game browsing experience before production implementation.

**Type:** prototype

**Blocked by:** None. Uses the capabilities verified in 03; requires no upstream credentials. Production implementation remains subject to 05.

**Status:** ready-for-agent

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

2026-11-14: Added following the owner's suggestion of a UI design spike while ticket 02 awaits upstream credentials. This is independent exploratory work; existing feasibility gates and blocking edges remain in force.
