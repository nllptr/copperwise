# Copperwise – Product Brief

**Status:** Agreed product scope; Phase 0 technical validation pending
**Target:** World of Warcraft: Forever
**Initial environment:** macOS 26 on Intel; EU, RP ruleset, Alliance
**Date:** 2026-11-13

## 1. Purpose and audience

Copperwise helps casual sellers understand auction-house asking prices and available stock without leaving the game. It aims for Auctionator-like simplicity and useful market context inspired by TradeSkillMaster.

V1 is a trend viewer for the project owner. Initial releases are internal only. Selling, posting, purchasing, price recommendations, and pricing strategies are outside V1.

The player should be able to select an item and understand its observed price range, movement, and available-stock history. The product describes listings, not confirmed sales, sale probability, future prices, or realized profit. The player interprets recurring daily, weekly, or monthly patterns; Copperwise does not infer claims such as “usually cheapest on Thursdays.”

## 2. Product principles

- Simple, understandable presentation with minimal configuration.
- Show data age, actual history coverage, missing observations, and meaningful status details.
- Resist price outliers without hiding uncertainty or confusing price spread with confidence.
- Keep cached history usable when upstream services are unavailable.
- Use supported game mechanisms. Validate Forever behavior in the actual client.
- Keep the initial scope narrow while allowing later markets and platforms.
- Develop as open source; license selection remains deferred until distribution requires it.

## 3. V1 experience

### Access and item selection

A dedicated addon window opens anywhere in the game, including away from the auction house. It supports item-name search and a configurable keybinding.

An item tooltip should provide a compact summary where it remains readable: median buyout unit price, middle-50% price range, listed stock, and data age. Full graphs live in the dedicated window. Investigate a separate hovered-item keybinding and configurable modifier-click on item icons, preserving existing game shortcuts. Do not assume ordinary item tooltips are clickable.

Initially support comparable ordinary trade goods, such as herbs, ore, cloth, and consumables. Validate precise categories and item identity against real data. Defer equipment with variant-specific pricing; identify unsupported items rather than combining unlike variants.

### Price graph

- Show a unit-weighted median buyout price over time.
- Shade the middle 50% of listed units by buyout unit price.
- Count individual item units rather than treating each listing equally.
- Exclude bid-only listings from price statistics.
- Treat this graph design as an initial hypothesis to test against real auction distributions.
- Withhold a reference estimate or trend summary when evidence is insufficient; show available observations without inventing certainty.

The median and middle-50% band must not be described as immune to manipulation. Thin markets or concentrated stock can distort them. Determine evidence thresholds and any additional outlier treatment through Phase 0 data analysis before assigning confidence labels.

### Available-stock graph

Show total observed listed units, including units at outlier prices and in bid-only listings. Label this coverage difference from the buyout-only price graph.

### Shared graph behavior

- Use an aligned time axis for the two graphs.
- Offer 24-hour, seven-day, and all-retained-history views; default to seven days.
- Display local time and identify the timezone.
- Show how much history is actually available. A partial week must not appear to be a complete week.
- Represent missing observations as gaps. Distinguish collection failure from a successfully observed empty market.
- Keep source observation timestamps distinct from download/import times.

### Data status

The addon indicator describes data status, not a proven live connection to the companion:

| Color | Meaning |
|---|---|
| Green | Normal operation |
| Yellow | A problem prevents normal updates or use |
| Red | No usable dataset is loaded |

Yellow can have many causes. Explain the specific reason in the tooltip or companion rather than making it mean only “stale.” Cached graphs can remain visible during yellow. The companion provides detailed collection/download/export diagnostics; the addon reports only status it can actually observe. Do not imply that a loaded status proves the companion is currently running.

A backend outage must not block browsing cached history or searching cached items. Display data age and the update problem honestly.

## 4. Architecture and responsibilities

The intended flow is:

**Blizzard API → continuously collecting backend → companion's local cache → addon.**

### Backend

Run locally during testing, with the ability to run on a remote server later. Collection continues independently of the companion or game being open.

Responsibilities:

- Hold Blizzard API credentials and authenticate upstream requests.
- Discover and verify the actual EU RP Alliance market.
- Collect newly available snapshots within upstream limits.
- Normalize item identities, quantities, and unit prices.
- Produce per-snapshot price distributions and stock totals.
- Publish retained history to the companion.
- Enforce retention and preserve source timestamps and collection gaps.

Measure upstream update cadence rather than promising an arbitrary fresh-data interval. Re-fetching an unchanged snapshot is not a new observation. Avoid pooling persistent listings across repeated snapshots as if they were independent new listings.

### Desktop companion

Required for V1, initially targeting macOS 26 on Intel. It connects to the configured backend, downloads history, stores it locally on the gaming computer, and feeds it to the addon through a mechanism validated in Phase 0.

V1 responsibilities are backend configuration, downloads, local caching, addon data delivery, and diagnostics. Manual addon installation is acceptable. Defer automatic addon installation/updates, SavedVariables backups, restoration, and personal-data synchronization.

Go is the intended implementation language; Go + Wails with React/TypeScript is the proposed desktop stack. Cross-compilation does not replace platform packaging and runtime validation. Additional platforms are outside initial acceptance criteria.

### Addon

Lua-based history window, tooltip summaries, item selection, and data-status presentation. New backend history should appear automatically in an already-running addon if a supported mechanism can be demonstrated.

**The transport is not settled.** Generated Lua files are a candidate import format, not proof of repeatable automatic updates. A successful import at login or a first load-on-demand import does not satisfy the automatic-update requirement. A reload-based workflow has not been accepted as a fallback.

### Other proposed technologies

Go backend, PostgreSQL storage, and Docker Compose for local development remain proposals to validate. Prefer a modular monolith over microservices. Public hosting infrastructure, Kubernetes, and a web application are outside V1.

## 5. Retention, accounts, and distribution

Initially cap API-derived history in backend storage and companion caches at a configurable maximum of 30 days. Verify the applicable Blizzard terms before deployment; do not assume aggregates may be retained indefinitely. The agreed cap is a conservative product policy, not a settled interpretation of all upstream obligations.

A new installation receives history already accumulated by the backend, subject to retained coverage. It does not need to collect its own first seven days.

No user accounts are required for owner-only releases. Authentication/accounts are required before inviting other users, with their design deferred until then. Internal-only scope does not remove upstream Blizzard authentication requirements. Never embed Blizzard secrets in the addon or public client distribution.

Improve companion onboarding and distribution before public access. Additional regions, platforms, and markets should be straightforward to add, but their implementation and validation are deferred.

## 6. Phase 0 – Feasibility gates

Before building the full companion and graph interface, produce runnable probes and a short report covering:

1. **Repeatable automatic imports:** demonstrate that a second backend dataset appears in an already-running addon without manual reload, using a supported mechanism. Distinguish initial/deferred loading from repeated refresh. If unsupported, return the evidence and alternatives to the owner before choosing an architecture or fallback.
2. **Client capabilities:** identify the actual Forever build and verify needed drawing APIs, item access, keybindings, and modifier hooks in the client.
3. **Market identity:** authenticate, discover candidate rulesets/auction houses, and establish which data actually represents EU RP Alliance. Do not assume ruleset IDs identify distinct markets correctly.
4. **Item and price semantics:** verify buyout fields, quantities, unit-price normalization, partial-stack purchasing behavior, bid-only coverage, and comparable item identity. Identify missing metadata and unsupported variants.
5. **Source cadence and coverage:** measure changed-snapshot frequency, timestamp semantics, empty responses, failures, and payload sizes. Select a compliant collection cadence from evidence.
6. **Graph feasibility:** draw a minimal price band and stock series, validate performance, and demonstrate window/keybinding access. Test distributions with sparse and extreme-price data before settling evidence thresholds.
7. **Retention requirements:** verify relevant API storage and usage terms before deployment and record any resulting changes to storage policy.

Record observations, sources, limitations, and pass/fail outcomes. Do not turn unverified Forever-specific API claims into architectural facts.

## 7. Phase 1 – Internal usable version

After Phase 0 passes, or the owner explicitly chooses an alternative for a failed gate:

- Collect one verified EU RP Alliance market continuously.
- Store and publish retained trade-goods history with accurate timestamps and gaps.
- Download and cache it using the macOS Intel companion.
- Deliver it to the addon using the validated transport.
- Provide searchable in-addon price and stock graphs, tooltip summaries where readable, keybinding access, and honest data status.
- Preserve cached browsing during backend or companion outages.

Acceptance means the owner can select a supported item and understand price range, movement, and available-stock history without leaving the game. The display must remain honest for sparse data, stale data, incomplete history, collection failures, and empty markets. Verify the full path with real target-market data on the target client and desktop.

## 8. Deferred scope

Selling and buying interfaces, posting, price recommendations, pricing strategies, automated recurring-pattern interpretations, accounting, crafting analysis, watchlists, alerts, community scans, web dashboards, backups, personal synchronization, public accounts, polished distribution, and additional markets/platforms are not V1 commitments. Reassess them after validating the trend viewer.

## 9. Research references

These are research entry points, not proof that every described behavior applies to the current Forever client:

- [Blizzard Developer Portal](https://develop.battle.net/)
- [Blizzard Developer API Terms](https://www.blizzard.com/en-us/legal/a2989b50-5f16-43b1-abec-2ae17cc09dd6/blizzard-developer-api-terms-of-use)
- [TSM desktop setup](https://support.tradeskillmaster.com/en_US/tsm-desktop-application/how-do-i-set-up-the-tsm-desktop-application)
- [TSM data import troubleshooting](https://support.tradeskillmaster.com/en_US/addon/why-does-my-addon-keep-telling-me-no-recent-auctiondb-scan-data-found)
- [Blizzard-generated addon API documentation mirror](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/AddOnsDocumentation.lua)
- [Blizzard-generated frame API documentation mirror](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleFrameAPIDocumentation.lua)
- [NIST box-plot explanation](https://www.itl.nist.gov/div898/handbook/eda/section3/boxplot.htm)

The installed Forever client and Auctionator source provide local material for the Phase 0 probes. Runtime behavior still requires testing.
