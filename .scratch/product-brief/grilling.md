# Product brief grilling

Status: resolved

## Confirmed decisions

### Current scope (supersedes earlier selling decisions)

- V1 focuses on in-addon price-trend and available-stock graphs. Selling, posting, price recommendations, and pricing strategies are deferred.
- Earlier selling-centered success criteria must be replaced with trend-viewer acceptance criteria.
- Requested addon status indicator: red = companion not connected; yellow = connected with an issue, check companion; green = good. Companion provides diagnostics such as outdated data. Live connection detection feasibility and truthful status semantics remain unresolved.
- Dedicated history window accessible anywhere, with item-name search. Include a tooltip view if it fits legibly; precise tooltip scope remains open.
- Price statistics use buyout unit prices, excluding bid-only listings; total stock includes bid-only units, with that distinction labeled.
- V1 acceptance goal: select an item and understand its price range, movement, and available-stock history without leaving the game, including visible missing history and honest data status.
- Status indicator is data status rather than a proven live companion connection. Yellow means unusable for any reason; details belong in tooltip or companion. Green/red boundaries and treatment of usable offline history need clarification.
- Automatic display of new backend data is strongly desired, if technically possible. User rejected accepting reload-based updates; supported transport feasibility is unresolved and must be investigated before choosing a fallback.
- Tooltip summary accepted in principle, but a directly clickable shortcut inside an ordinary item tooltip is not a viable assumed interaction; choose an alternative gesture.
- Continue displaying last usable history while backend/companion is unavailable, with age visible and unavailable periods as gaps. Do not assume stale automatically means unusable.
- Status meanings settled: red = no usable dataset loaded; yellow = a problem prevents normal updates or use; green = normal operation. Cached graphs may remain visible during yellow; tooltip/companion explains the reason.
- Investigate configurable modifier-click on inventory items without conflicting with game shortcuts, and keybindings for opening the history window. Name search remains the dependable entry point; precise shortcut behavior is not yet settled.
- Phase 0 gate: prove a second backend dataset appears in an already-running addon without manual reload, using a supported mechanism. Do this before building the full companion and graphs; if unsupported, present evidence and alternatives for a user decision rather than assuming a fallback.
- Provide a configurable keybinding to open the window. Hovered-item binding and modifier-click remain subject to client validation.
- Initial supported items: comparable ordinary trade goods (e.g. herbs, ore, cloth, consumables); defer equipment variant pricing and clearly identify unsupported items. Exact category/identity coverage must be validated against API data.
- Backend runs locally for testing and can later run on a remote server. It continuously fetches new upstream data as allowed; the companion downloads from it, caches locally on the gaming computer, and feeds the addon. This does not settle the addon transport.
- Measure upstream snapshot cadence in Phase 0, preserve source timestamps, and choose collection frequency accordingly; do not promise fresher observations than upstream provides.
- Initial retention cap: configurable, at most 30 days for API-derived backend history and companion caches, pending verification of terms before deployment. No assumed indefinite aggregate retention.
- Initial releases are internal, owner-only. Improve companion onboarding/distribution before public access; public accounts remain deferred.
- V1 companion handles backend configuration, downloads, local caching, addon delivery, and diagnostics. Manual addon installation is acceptable; defer automatic addon updates, backups, and personal-data synchronization.
- Backend outages do not block cached history or item search; show yellow status with details.
- First implementation milestone: feasibility report and runnable probes for repeatable automatic imports, EU RP Alliance API market mapping, item identity, source cadence, basic graph drawing, and keybindings. Failed automatic imports return to the user for a decision.

### Decisions from earlier rounds

- Initial audience: casual sellers selling items they already own.
- Easy visibility into price trends is required; prefer the addon, with a simple desktop or web view acceptable if needed. First-release trend scope remains to be settled.
- First-release outcome: confidently price and post an item without leaving the auction house.
- Recommendations use observed listings and explain their evidence without promising sale speed or profit.
- The desktop companion is required for the first release.
- Basic price trends belong in Phase 1 and compare current asking prices with recent listings without forecasting sales.
- Market-value and trend estimates must resist outlier prices; the method and treatment of thin markets remain open.
- Current auction-house observations guide posting prices; imported data supplies historical context. Show data age and stale status, and require explicit review when only imported data is available.
- First release is for the project owner alone. Accounts/authentication for additional users are deferred until others are invited; no public service commitment is implied.
- Withhold market value and trend direction when evidence is insufficient; show available listings honestly.
- Initial trend comparison window: seven days, with actual available history disclosed.
- The companion connects to our own backend, which accumulates market history up to the permitted retention period. New installations receive already accumulated history; retention interpretation remains to be verified.
- In-addon trends are required: price concentration, overall upward/downward/stable direction, and desired recurring time-of-day/day-of-week/month patterns in asking prices and listed supply. Recurring-pattern release scope remains open.
- Candlestick graphing is a user suggestion to evaluate, particularly whether it communicates spread and confidence accurately.
- Support only the owner's region and platform initially; make later expansion straightforward. Exact OS and market identity remain unspecified.
- Initial environment confirmed: macOS 26 on Intel; EU, RP ruleset, Alliance. Exact API market mapping remains a technical validation gate.
- Weight price concentration by individual item units, not listing count. User reports listed stacks can be purchased partially; validate client behavior during technical research.
- Present two separate graphs: price spread and available stock. Exact representation of historical spread and direction remains open.
- Display observations for the user to interpret recurring patterns; do not produce claims such as "usually lowest on Thursdays." Such inference is outside current scope and may never be needed.
- Initial price graph: unit-weighted median over time with a shaded middle-50% band, subject to real-data testing. Spread is distinct from confidence and freshness.
- Stock graph counts all observed listed units, including those at outlier prices.
- Show missing observations as gaps, distinguishing collection failure from a successfully observed empty market.
- Align graphs on one time axis; offer 24-hour, seven-day (default), and all-retained-history views, displaying local time and the timezone.

## Open branches

- Trend meaning, history window, presentation, and first-release scope.
- Current auction-house observations versus imported historical context; freshness and fallback behavior.
- Hosted service, onboarding, supported market, and operating constraints.
- Minimum workflow, coverage, and acceptance criteria.

## Comments

Round 1: user confirmed the initial audience, outcome, listing-based recommendations, and required companion, adding easy trend visibility as a requirement. The product brief will be reconciled after shared understanding is confirmed.

Round 2: user confirmed descriptive trends, Phase 1 trend scope, and visible staleness, emphasizing resistance to outliers. User clarified that the first release is single-user and accounts will be needed when additional users are invited.

Round 3: user confirmed insufficient-data behavior, a seven-day starting window, in-addon trends, and initial single-region/platform scope. Clarified backend-owned shared history and requested recurring price/supply patterns; suggested candlesticks. Exact platform and market were not supplied.

Round 4: user clarified per-unit weighting and partial-stack purchasing, requested separate price-spread and stock graphs, reserved recurring-pattern judgments for the user, and supplied macOS 26 Intel / EU RP Alliance as the initial environment.

Round 5: user accepted the initial median/middle-50% price graph, all-unit stock totals, explicit observation gaps, and aligned 24-hour/seven-day/all-available controls with local timezone display.

Round 6: user explicitly replaced the selling-centered V1 with trend graphs only, deferring selling and recommendation questions. Requested red/yellow/green companion connection status in the addon and detailed diagnostics in the companion; did not confirm reload-based history updates.

Round 7: user accepted an anywhere-accessible dedicated window with name search, adding tooltip presentation where it fits. Accepted buyout-only price statistics (and the proposed total-stock treatment) and the trend-viewer acceptance goal.

Round 8: user corrected yellow to mean unusable with detailed reasons elsewhere; rejected reload as an accepted update workflow and requested automatic updates if at all possible; challenged tooltip shortcut interaction; confirmed cached offline history remains available.

Round 9: user accepted exact red/yellow/green semantics, investigation of item gestures and keybindings, and automatic imports as a Phase 0 gate with fallback requiring a subsequent decision.

Round 10: user accepted keybindings and initial trade-goods coverage, clarified local-development/remote-capable continuous backend collection and companion-local caching, and accepted cadence based on observed upstream updates.

Round 11: user accepted the conservative configurable 30-day retention cap pending terms verification, minimal companion/manual installation, cached operation during outages, and Phase 0 report/probes. Clarified all initial releases are internal owner-only and the companion will be improved before public access.

## Next step

The owner confirmed shared understanding. Reconciled product-brief.md around the internal trend-viewer V1, keeping technical uncertainties as explicit Phase 0 gates. Implementation remains subsequent work.
