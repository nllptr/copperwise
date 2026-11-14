# Copperwise internal market-trends V1

Status: open
Labels: ready-for-agent

## Scope amendment — 2026-11-14

The [inventory, crafting and auction-house workflow spec](../selling-context/spec.md)
is the integrated current scope for the owner's expanded direction. It takes
precedence over the trend-only, crafting, queue, buying/posting and local-scan
exclusions below for the specific workflows it describes: two main tabs,
lowest-buyout/vendor/craft-cost comparisons, sale and craft queues, queued
ingredient purchasing, marked-item posting and native AH scanning. Native
Copperwise integration is preferred, Auctionator is a fallback. Other scope,
companion import boundaries and feasibility decisions remain in force. Existing
implementation tickets need reconciliation; their original acceptance criteria
alone do not complete the expanded scope. Local scans do not replace imported
history or independently satisfy full pipeline feasibility.

## Problem Statement

As a casual seller in World of Warcraft: Forever, the owner wants to understand where most stock is priced, whether asking prices are moving up or down, and how available stock changes over time without leaving the game. Individual listings and extreme prices can mislead; incomplete or outdated history can look more authoritative than it is. The owner also wants to inspect time-of-day and longer patterns personally without the product making unsupported predictions about sales or recurring patterns.

## Solution

Provide an internal-only addon history viewer, supported by a required desktop companion and continuously collecting backend. Initially target macOS 26 on Intel and the verified EU RP Alliance market, covering comparable trade goods.

The addon offers a searchable window accessible anywhere, two aligned history graphs, compact tooltip context where readable, and honest data status. The price graph shows a unit-weighted median buyout price and middle-50% band. The stock graph shows all listed units, including bid-only and extreme-price listings. Default to seven days, with 24-hour and all-retained-history views, explicit gaps, local timezone labels, and actual coverage.

The backend accumulates shared history independently of play sessions. The companion downloads and caches that history locally and exports a dataset for the addon. The addon imports the latest successfully exported dataset only at login and user-initiated `/reload`. Downloads and exports during play become available at the next login or `/reload`; the loaded dataset stays unchanged in between. Phase 0 must verify this delivery path on the target client before full implementation.

## User Stories

1. As a casual seller, I want to view an item's asking-price history in the game, so that I can understand its recent price movement without switching applications.
2. As a casual seller, I want to view available-stock history, so that I can see how listed supply changes over time.
3. As a casual seller, I want the history window to open away from the auction house, so that market context is available wherever I play.
4. As a casual seller, I want to search supported items by name, so that I can inspect items I do not currently carry.
5. As a casual seller, I want a configurable keybinding to open the window, so that access is quick and convenient.
6. As a casual seller, I want hovered-item access if supported, so that I can inspect an item without retyping its name.
7. As a casual seller, I want an item modifier-click shortcut if supported, so that I can open relevant history directly from an item icon.
8. As a casual seller, I want shortcuts to preserve existing game interactions, so that inspecting history does not break familiar controls.
9. As a casual seller, I want a compact tooltip summary where readable, so that I can see price range, stock, and data age at a glance.
10. As a casual seller, I want unsupported items identified clearly, so that I do not mistake missing or incompatible data for valid history.
11. As a casual seller, I want price statistics weighted by individual units, so that the graph reflects where stock is offered rather than how sellers divide listings.
12. As a casual seller, I want a median buyout unit-price line, so that I can follow the center of observed asking prices over time.
13. As a casual seller, I want a middle-50% price band, so that I can see the price spread around much of the available stock.
14. As a casual seller, I want bid-only listings excluded from price statistics, so that the graph describes immediate buyout asking prices consistently.
15. As a casual seller, I want every listed unit counted in stock totals, so that extreme prices or bid-only listings do not hide available supply.
16. As a casual seller, I want the different coverage of the price and stock graphs explained, so that I can interpret them correctly.
17. As a casual seller, I want price spread distinguished from confidence, so that a narrow band does not falsely imply trustworthy evidence.
18. As a casual seller, I want insufficient evidence disclosed, so that sparse or suspicious listings do not produce an unjustified reference estimate.
19. As a casual seller, I want comparable items kept separate from incompatible variants, so that the graph does not combine unlike goods.
20. As a casual seller, I want both graphs aligned in time, so that I can compare price movement with changes in supply.
21. As a casual seller, I want a seven-day default view, so that recent context appears without configuration.
22. As a casual seller, I want a 24-hour view, so that I can inspect changes within a day.
23. As a casual seller, I want an all-retained-history view, so that I can inspect longer patterns myself.
24. As a casual seller, I want local times and a visible timezone, so that I can relate observations to my play schedule.
25. As a casual seller, I want the actual available history disclosed, so that a partial week does not look like a complete week.
26. As a casual seller, I want missing observations shown as gaps, so that the display does not invent continuity.
27. As a casual seller, I want an observed empty market distinguished from collection failure, so that zero supply has an honest meaning.
28. As a casual seller, I want source observation age shown separately from import time, so that a recent download does not disguise old observations.
29. As a casual seller, I want the latest companion-exported history loaded at login and `/reload`, so that I can refresh my in-game history at an explicit import boundary.
30. As a casual seller, I want a green indicator for normal operation, so that I can recognize a healthy data state quickly.
31. As a casual seller, I want a yellow indicator when a problem prevents normal updates or use, so that I know to inspect the details.
32. As a casual seller, I want a red indicator when no usable dataset is loaded, so that I do not mistake unavailable history for a functioning display.
33. As a casual seller, I want status details in the tooltip or companion, so that I can understand the specific problem instead of guessing from a color.
34. As a casual seller, I want loaded data status distinguished from a live companion connection, so that the addon does not claim connectivity it cannot observe.
35. As a casual seller, I want cached history and item search to work during an outage, so that an update failure does not remove useful existing context.
36. As the owner, I want to configure the companion's backend, so that I can use a local backend during development and a remote service later.
37. As the owner, I want collection to continue while the companion and game are closed, so that history does not depend on my play schedule.
38. As the owner, I want the companion to cache backend history on the gaming computer, so that existing history remains available when the backend is unreachable.
39. As the owner, I want a new installation to receive already accumulated backend history, so that it does not need to wait a week to become useful.
40. As the owner, I want collection cadence based on actual upstream updates and limits, so that repeated downloads do not pretend to create fresher observations.
41. As the owner, I want configurable retention capped initially at 30 days, so that backend and companion storage follow the agreed conservative policy.
42. As the owner, I want diagnostics for downloads and addon delivery, so that I can investigate problems in the companion.
43. As the owner, I want the initial release to work without product accounts, so that internal testing avoids unnecessary onboarding.
44. As the owner, I want verified market mapping, so that attractive graphs do not silently describe a different market.
45. As the owner, I want a runnable login-and-reload import probe before full implementation, so that addon delivery is verified on the actual target client.
46. As the owner, I want failed feasibility gates reported with evidence and alternatives, so that I can choose any necessary scope change explicitly.
47. As a casual seller, I want to know that newer companion exports require login or `/reload`, so that I do not mistake loaded history for a continuously updating feed.

## Implementation Decisions

- Build three cooperating components: a continuously collecting backend, a required desktop companion with a local cache, and a Lua addon. Run the backend locally for testing while preserving remote deployment as an architectural option. Prefer a modular monolith to microservices.
- Initial acceptance targets macOS 26 Intel, Forever EU RP Alliance, and comparable ordinary trade goods. Exact API market identifiers, item coverage, and client capabilities must be verified. Cross-compilation alone is not platform acceptance.
- Use Go for the companion. Go with Wails and React/TypeScript for the desktop UI, Go for the backend, PostgreSQL for storage, and Docker Compose for development remain proposed technologies, not validated prerequisites.
- The backend owns upstream credentials, market discovery, compliant collection, normalization, per-snapshot distributions, stock totals, retained-history publication, timestamps, and gap information. No Blizzard secrets belong in the addon or a distributed client.
- The companion owns backend configuration, downloads, local history storage, dataset exports for addon loading, and diagnostics. It can continue downloading and exporting while the game is running. Manual addon installation is acceptable for internal releases; dataset exports are separate from addon code updates.
- Preserve source observation timestamps independently of collection, download, and import times. Do not count a repeated unchanged upstream snapshot as a new observation or pool persistent listings as independent new sales evidence.
- Normalize comparable buyout prices per unit. Price statistics are weighted by quantity; bid-only listings do not contribute to price statistics. Total stock includes all observed listed units regardless of price or buyout availability.
- Initially visualize a unit-weighted median and middle-50% price band, with total stock in a separate aligned graph. Validate the graph against real distributions before finalizing calculation conventions and insufficient-evidence thresholds. No specific outlier-removal algorithm, confidence score, or quantile interpolation convention has been agreed.
- Do not describe the band as confidence or a guarantee of manipulation resistance. Withhold reference estimates or summaries when evidence is inadequate, preserving honest presentation of available observations.
- Provide 24-hour, seven-day default, and all-retained views with explicit coverage, local timezone, and gaps. A successful empty-market observation differs from a collection failure; zero stock does not imply a zero asking price.
- Provide a dedicated searchable window accessible anywhere, a configurable open-window binding, and compact tooltip context where readable. Hovered-item bindings and modifier-click require client validation and preservation of normal game actions. Ordinary tooltips are not assumed clickable.
- Green means normal data operation under the login-and-reload import model; yellow means an observable problem prevents normal updates or use, including loaded source data exceeding the agreed freshness threshold; red means no usable dataset loaded. Waiting for the next import boundary is expected behavior, not by itself a fault. Show source age and import time, and explain that refreshed exports require login or `/reload`. The addon must not claim a live companion connection, current download failures, or newer exports it cannot observe. The companion reports its own download and export outcomes without claiming addon receipt. Precise freshness thresholds and observability remain Phase 0 outputs.
- Preserve cached graphs and item search during backend or companion outages. Show age and relevant update problems; do not fabricate samples during missing periods.
- Load companion-exported data only at login and user-initiated `/reload`, using ordinary addon loading. Verify an initial login import and multiple later distinct revisions imported after explicit reloads, with no data replacement between those boundaries. Export completion alone is not proof of import. Do not poll load-on-demand addons, automatically trigger reloads, modify the client, or bypass client protections to refresh data. If the revised gate fails, stop downstream full implementation and obtain the owner's decision on evidenced alternatives.
- Phase 0 delivers runnable probes and a report for login/reload imports, target-client APIs, market mapping, item identity and partial-stack semantics, source cadence, empty/error responses, basic plotting, keybindings, sparse/extreme distributions, and applicable retention rules. Record actual builds, observations, limits, and outcomes. A technical import success is not a claim of Blizzard approval or zero account risk.
- Backend history and companion caches have configurable retention with an initial maximum of 30 days for API-derived data. Verify upstream terms before deployment; do not assume derived aggregates permit indefinite storage. New installations can receive the backend's already accumulated retained history.
- Initial releases are owner-only and need no product accounts. Upstream authentication is still necessary. Authentication/accounts and improved companion distribution are prerequisites to inviting others, with design deferred.
- The addon delivery model is companion-exported data loaded at login and `/reload`. No concrete database schema, wire format, endpoint layout, or export layout has been selected. Set those details after the feasibility evidence rather than treating the experimental probe format as a product contract.

## Testing Decisions

The owner confirmed the following testing seams: one primary end-to-end acceptance boundary, preceded by prerequisite in-client capability probes.

- Preserve the agreed primary acceptance boundary: controlled upstream snapshot sequences enter the backend, pass through the real companion cache and dataset export, and produce observable addon behavior in the target client at login or user-initiated `/reload`. Exercise the cooperating components through public behavior rather than testing private helpers or mirroring the implementation. No new testing seam is introduced by the delivery change.
- Use deterministic upstream fixtures for repeatable acceptance scenarios while keeping the backend, companion delivery, and addon rendering real. Pair those scenarios with a live target-market smoke test to establish that fixtures match actual upstream semantics. Automate outside the client where practical; use recorded in-client probe/manual acceptance evidence where automation is unavailable.
- Before that end-to-end boundary can exist, use narrowly scoped Phase 0 capability probes. Record an initial login import, export newer revisions while the game is running, confirm the loaded revision remains unchanged, then verify each newer revision becomes visible after a user-initiated `/reload`. Include multiple export/reload cycles. Record actual client/platform builds and distinguish exported revisions from observed imports; file export alone does not pass.
- Cover per-unit weighting with differently sized listings, buyout unit-price normalization, bid-only stock, extreme prices, sparse evidence, empty markets, missing samples, unchanged upstream snapshots, and incompatible item identities. Assert the visible series, coverage, explanations, and status outcomes rather than internal storage layouts or calls.
- Cover aligned time ranges, local timezone labeling, actual coverage, gaps versus zero stock, source age versus download age, searchable supported items, unsupported-item feedback, window keybinding, and readable tooltip summaries. Validate optional item gestures only if the client supports them.
- Exercise backend/companion outages, stale or unusable loaded data, and retained cached browsing. Verify that failed downloads or exports preserve the last usable export and loaded history. Recovery downloads and exports may happen automatically; recovered data becomes visible only at the next login or `/reload`. Verify red/yellow/green against observable evidence as source age advances between imports, and ensure a loaded status never masquerades as a proven live process connection or knowledge of unseen exports. Exact stale-data thresholds await Phase 0 evidence.
- Test backend and companion retention with controlled time at their public storage/publication boundaries. Verify expired API-derived history is no longer served or retained by either component under the configured cap, and a newly initialized companion receives retained backend history.
- Verify the real pipeline on macOS 26 Intel against the actual Forever build and verified EU RP Alliance data. Include representative payload/performance observations; a quantitative performance target is not yet agreed.
- The existing Phase 0 delivery probe has a command-level integration test covering controlled revisions through the HTTP backend, companion cache, and Lua export. It establishes no in-client import behavior; its repeated load-on-demand addon experiment targets the superseded requirement and must be adapted before use for revised acceptance. Prefer this public-boundary testing style without treating the experimental format as a production contract or introducing separate test APIs into every module.

## Out of Scope

- Auction selling, posting, buying, price recommendations, strategy presets, and claims about confirmed sales, sale likelihood, profit, or forecast prices.
- Automatic interpretation of recurring daily, weekly, or monthly patterns; users inspect history themselves.
- Equipment variant pricing and unsupported item categories.
- Watchlists, alerts, crafting analysis, accounting, community scans, and web dashboards.
- Automatic addon installation or updates, backups, restoration, and personal-data synchronization.
- Product accounts, multi-user access, public distribution polish, additional markets, and additional desktop platforms in the initial release.
- Kubernetes, microservices, and a public hosting rollout.
- Continuous in-session imports, repeated load-on-demand polling, automatic UI reloads, and client modification or security bypasses to deliver data. Login and user-initiated `/reload` imports are the accepted model.
- Arbitrary fixed fresh-data guarantees independent of upstream cadence, indefinite aggregate retention, and an assumed legal interpretation of upstream terms.

## Further Notes

The owner confirmed the revised trend-viewer scope after the grilling session. This replaces earlier selling-centered goals; the original broad trading roadmap is not an implementation commitment.

Phase 0 is the first implementation milestone. Phase 1 proceeds only after its gates pass or the owner explicitly decides an alternative for a failed gate. The eventual ready-for-agent label means the spec is actionable in that order, not that unverified capabilities have already passed.

The installed Forever client and Auctionator source are available as research material. Neither the presence of a client nor installed addon source proves runtime compatibility. Upstream API discovery, actual login/reload import behavior, precise evidence thresholds, retention requirements, and final contracts must remain evidence-driven outputs.

The owner explicitly replaced the continuous in-session import requirement with login and user-initiated `/reload` imports. This is the accepted delivery model, not a fallback still awaiting approval. The earlier repeated-load probe is historical work, not evidence that the revised gate has passed. Other Phase 0 gates remain in force.

## Comments

Prepared from the confirmed product brief and interview. The owner confirmed the primary end-to-end acceptance boundary and prerequisite client capability probes. Published to the local issue tracker as ready-for-agent; Phase 0 remains the first implementation milestone.

2026-11-14: Updated from the owner's explicit scope decision after reviewing TSM's documented desktop-data workflow. Backend collection and companion downloads remain independent of play sessions; addon imports occur only at login and user-initiated `/reload`. The existing acceptance boundary and ticket structure are retained.
