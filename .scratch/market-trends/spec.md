# Copperwise internal market-trends V1

Status: open
Labels: ready-for-agent

## Problem Statement

As a casual seller in World of Warcraft: Forever, the owner wants to understand where most stock is priced, whether asking prices are moving up or down, and how available stock changes over time without leaving the game. Individual listings and extreme prices can mislead; incomplete or outdated history can look more authoritative than it is. The owner also wants to inspect time-of-day and longer patterns personally without the product making unsupported predictions about sales or recurring patterns.

## Solution

Provide an internal-only addon history viewer, supported by a required desktop companion and continuously collecting backend. Initially target macOS 26 on Intel and the verified EU RP Alliance market, covering comparable trade goods.

The addon offers a searchable window accessible anywhere, two aligned history graphs, compact tooltip context where readable, and honest data status. The price graph shows a unit-weighted median buyout price and middle-50% band. The stock graph shows all listed units, including bid-only and extreme-price listings. Default to seven days, with 24-hour and all-retained-history views, explicit gaps, local timezone labels, and actual coverage.

The backend accumulates shared history independently of play sessions. The companion caches that history locally and supplies the addon. Automatic repeated updates during a running game session are a Phase 0 feasibility gate; manual reload is not an accepted fallback. If a supported transport cannot be demonstrated, return evidence and alternatives to the owner before proceeding with the full implementation.

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
29. As a casual seller, I want newly available backend data to appear automatically if a supported mechanism exists, so that normal use does not require a manual reload.
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
45. As the owner, I want a runnable automatic-import probe before full implementation, so that an unproven transport does not undermine the product architecture.
46. As the owner, I want failed feasibility gates reported with evidence and alternatives, so that I can choose any necessary scope change explicitly.

## Implementation Decisions

- Build three cooperating components: a continuously collecting backend, a required desktop companion with a local cache, and a Lua addon. Run the backend locally for testing while preserving remote deployment as an architectural option. Prefer a modular monolith to microservices.
- Initial acceptance targets macOS 26 Intel, Forever EU RP Alliance, and comparable ordinary trade goods. Exact API market identifiers, item coverage, and client capabilities must be verified. Cross-compilation alone is not platform acceptance.
- Use Go for the companion. Go with Wails and React/TypeScript for the desktop UI, Go for the backend, PostgreSQL for storage, and Docker Compose for development remain proposed technologies, not validated prerequisites.
- The backend owns upstream credentials, market discovery, compliant collection, normalization, per-snapshot distributions, stock totals, retained-history publication, timestamps, and gap information. No Blizzard secrets belong in the addon or a distributed client.
- The companion owns backend configuration, downloads, local history storage, addon delivery, and diagnostics. Manual addon installation is acceptable for internal releases.
- Preserve source observation timestamps independently of collection, download, and import times. Do not count a repeated unchanged upstream snapshot as a new observation or pool persistent listings as independent new sales evidence.
- Normalize comparable buyout prices per unit. Price statistics are weighted by quantity; bid-only listings do not contribute to price statistics. Total stock includes all observed listed units regardless of price or buyout availability.
- Initially visualize a unit-weighted median and middle-50% price band, with total stock in a separate aligned graph. Validate the graph against real distributions before finalizing calculation conventions and insufficient-evidence thresholds. No specific outlier-removal algorithm, confidence score, or quantile interpolation convention has been agreed.
- Do not describe the band as confidence or a guarantee of manipulation resistance. Withhold reference estimates or summaries when evidence is inadequate, preserving honest presentation of available observations.
- Provide 24-hour, seven-day default, and all-retained views with explicit coverage, local timezone, and gaps. A successful empty-market observation differs from a collection failure; zero stock does not imply a zero asking price.
- Provide a dedicated searchable window accessible anywhere, a configurable open-window binding, and compact tooltip context where readable. Hovered-item bindings and modifier-click require client validation and preservation of normal game actions. Ordinary tooltips are not assumed clickable.
- Green means normal data operation; yellow means a problem prevents normal updates or use; red means no usable dataset loaded. Explain the reason without treating yellow as exclusively stale data. The addon must not claim a live connection it cannot observe. Precise freshness thresholds and observability remain Phase 0 outputs.
- Preserve cached graphs and item search during backend or companion outages. Show age and relevant update problems; do not fabricate samples during missing periods.
- Require a supported repeatable backend-to-running-addon update proof. File exports, initial loading, or a single demand-loaded import are not sufficient evidence. Manual reload is not an accepted fallback. If the gate fails, stop downstream full implementation and obtain the owner's decision on evidenced alternatives.
- Phase 0 delivers runnable probes and a report for automatic imports, target-client APIs, market mapping, item identity and partial-stack semantics, source cadence, empty/error responses, basic plotting, keybindings, sparse/extreme distributions, and applicable retention rules. Record actual builds, observations, limits, and outcomes.
- Backend history and companion caches have configurable retention with an initial maximum of 30 days for API-derived data. Verify upstream terms before deployment; do not assume derived aggregates permit indefinite storage. New installations can receive the backend's already accumulated retained history.
- Initial releases are owner-only and need no product accounts. Upstream authentication is still necessary. Authentication/accounts and improved companion distribution are prerequisites to inviting others, with design deferred.
- No concrete database schema, wire format, endpoint layout, or addon transport has been selected. Set those after the feasibility evidence rather than inventing a contract in this specification.

## Testing Decisions

The owner confirmed the following testing seams: one primary end-to-end acceptance boundary, preceded by prerequisite in-client capability probes.

- Prefer one primary acceptance boundary: controlled upstream snapshot sequences enter the backend, pass through the real companion cache and validated addon transport, and produce observable addon behavior in the target client. Exercise the cooperating components through public behavior rather than testing private helpers or mirroring the implementation.
- Use deterministic upstream fixtures for repeatable acceptance scenarios while keeping the backend, companion delivery, and addon rendering real. Pair those scenarios with a live target-market smoke test to establish that fixtures match actual upstream semantics. Automate outside the client where practical; use recorded in-client probe/manual acceptance evidence where automation is unavailable.
- Before that end-to-end boundary can exist, use narrowly scoped Phase 0 capability probes. These establish platform facts, not substitute mocks for an unverified addon transport. Record whether a second and subsequent dataset revision becomes visible during the same session without reload; one initial import is insufficient.
- Cover per-unit weighting with differently sized listings, buyout unit-price normalization, bid-only stock, extreme prices, sparse evidence, empty markets, missing samples, unchanged upstream snapshots, and incompatible item identities. Assert the visible series, coverage, explanations, and status outcomes rather than internal storage layouts or calls.
- Cover aligned time ranges, local timezone labeling, actual coverage, gaps versus zero stock, source age versus download age, searchable supported items, unsupported-item feedback, window keybinding, and readable tooltip summaries. Validate optional item gestures only if the client supports them.
- Exercise backend/companion outages, stale or unusable loaded data, and retained cached browsing. Verify red/yellow/green against observable evidence, and ensure a loaded status never masquerades as a proven live process connection. Exact stale-data thresholds await Phase 0 evidence.
- Test backend and companion retention with controlled time at their public storage/publication boundaries. Verify expired API-derived history is no longer served or retained by either component under the configured cap, and a newly initialized companion receives retained backend history.
- Verify the real pipeline on macOS 26 Intel against the actual Forever build and verified EU RP Alliance data. Include representative payload/performance observations; a quantitative performance target is not yet agreed.
- There is no application implementation or existing test suite in the repository, so there is no codebase testing prior art or existing application seam to extend. Do not introduce a separate test API into every module merely to make testing convenient.

## Out of Scope

- Auction selling, posting, buying, price recommendations, strategy presets, and claims about confirmed sales, sale likelihood, profit, or forecast prices.
- Automatic interpretation of recurring daily, weekly, or monthly patterns; users inspect history themselves.
- Equipment variant pricing and unsupported item categories.
- Watchlists, alerts, crafting analysis, accounting, community scans, and web dashboards.
- Automatic addon installation or updates, backups, restoration, and personal-data synchronization.
- Product accounts, multi-user access, public distribution polish, additional markets, and additional desktop platforms in the initial release.
- Kubernetes, microservices, and a public hosting rollout.
- A claim that generated Lua files provide repeatable automatic updates, or acceptance of reload-based updates without a later explicit owner decision.
- Arbitrary fixed fresh-data guarantees independent of upstream cadence, indefinite aggregate retention, and an assumed legal interpretation of upstream terms.

## Further Notes

The owner confirmed the revised trend-viewer scope after the grilling session. This replaces earlier selling-centered goals; the original broad trading roadmap is not an implementation commitment.

Phase 0 is the first implementation milestone. Phase 1 proceeds only after its gates pass or the owner explicitly decides an alternative for a failed gate. The eventual ready-for-agent label means the spec is actionable in that order, not that unverified capabilities have already passed.

The installed Forever client and Auctionator source are available as research material. Neither the presence of a client nor installed addon source proves runtime compatibility. Upstream API discovery, supported automatic imports, precise evidence thresholds, retention requirements, and final contracts must remain evidence-driven outputs.

## Comments

Prepared from the confirmed product brief and interview. The owner confirmed the primary end-to-end acceptance boundary and prerequisite client capability probes. Published to the local issue tracker as ready-for-agent; Phase 0 remains the first implementation milestone.
