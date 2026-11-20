# Avoid idle addon CPU work

Status: resolved — owner accepted the in-client CPU check after reload

## Request

Owner reports high CPU while Copperwise is closed. Stop hidden-window bag scans
and rendering, observe bag changes rather than polling settled holdings, stop
continually rebuilding AH review, and rebuild item views only after a scan ends.

## Changes

- Build a transient item-ID lookup index once per retained market snapshot,
  preserving unsupported/ambiguous observation behavior and market isolation.
- Bag/native metadata events invalidate holdings. Only a visible Inventory/AH
  review or unresolved posting outcome consumes and settles them. Idle settled
  views do not poll bags. Reopening consumes changes deferred while hidden.
- Inventory never renders hidden. Saved choices synchronize after settled
  observations independently of Inventory visibility, preserving AH posting.
- AH review rebuilds after inputs/readiness/outcome changes rather than on a
  quarter-second timer. Existing Refresh item explicitly requests price levels.
  Native posting still revalidates sources, intent, quantity, deposit and funds.
- Full and targeted scans defer item-view rendering until completion/stop.
  Small progress/Stop controls remain operational. Identical full-scan status
  text/control values are not rewritten. Active batches render on state changes.
- Idle posting/listing workers return immediately. Hardware-click batch mode
  waits for a click without repeatedly preparing/revalidating the selected item.

## Verification

Production-module tests verify no bag reads/list text writes for idle Inventory,
no reads/writes for hidden Inventory despite bag events, correct holdings after
reopen, no recurring bag/deposit work in idle AH review, and no selected-item
rebuild during full-scan pagination. Existing posting, storage, scan, item-choice
and minimap regressions pass.

## Owner acceptance — 2026-11-17

After loading the installed update with reload, the owner reported a big
improvement and explicitly passed test 1 (CPU check). Earlier screenshots were
reported before confirming the updated version had loaded. This records the
owner's qualitative acceptance; no numerical before/after profile was supplied.
No separate bag-change/reopen result is inferred from this report. Batch posting,
filters, native click requirements and stopping remain pending under selling-MVP
ticket 06; CPU acceptance does not resolve that ticket.

## Selected-item price correction — 2026-11-17

Owner reports a snappier AH screen but expects an explicit item click to fetch
current listings and suggest the lowest buyout. Restore one-shot fetching on
sidebar clicks, refreshing the owned-posting baseline too. Automatic first-row
selection and idle rendering do not start item queries; Post all still uses its
targeted summaries. Once complete current results arrive, unedited price drafts
adopt the lowest price and the selected quantity drives deposit/total/Post item.
Existing explicit price edits remain preserved. A production boundary regression
verifies the click, populated terms, enabled post, dispatched price and no repeat
query/deposit work while idle. Target-client confirmation is pending.

## Incremental listings — 2026-11-17

Owner requests visible arrivals rather than withholding the entire selected-item
table until full coverage. Each validated cumulative cache response now publishes
its sorted price levels immediately. Rebuild quantities from the cache rather
than summing successive replies. Unedited suggestions follow the lowest price
seen so far; explicit edits survive subsequent pages. The UI and native posting
entry point both withhold individual posting until the selected item's latest
fetch completes successfully. Partial, queued, failed and cancelled fetches never
enable posting. Post all retains its separate complete-summary eligibility path.
Tests cover partial/final sorted UI rows, cumulative quantities, posting blocked
until completion, preserved manual edits and a failed fetch with visible prices.

## Initial selection fetch — 2026-11-17

Owner reports the automatically selected first item does not fetch on tab open.
Automatic first selection now starts the same one-shot listing/owned-baseline
refresh as an explicit sidebar click. This supersedes the earlier no-query
automatic selection decision. Selections made while a batch is active do not
start per-item searches. A boundary test verifies one automatic fetch, readiness
after completion and no repeat fetch while idle. Hardware Continue posting also
waits for native posting readiness before enabling its button.

## Price-row selection — 2026-11-17

Owner requests a persistent highlight matching the suggested/selected buyout.
The row matching the current draft price now has a gold background. Unedited
suggestions and their highlight follow arriving lowest prices; choosing another
price moves the highlight and preserves the choice through later pages/re-sorts.
Highlighting is keyed by price rather than row position. Production UI checks
cover default selection, repeated row changes, and lower-price arrivals both
with and without a prior manual choice.

## Item-switch price reset — 2026-11-17

Owner reports lowest price is not selected after switching items. Re-entering
an item's saved draft previously preserved its edited-price flag. Switching
items now resets only price/edited state to the scan default, then adopts and
highlights the fresh lowest arriving price; reviewed quantity remains intact.
Manual price choices survive arrivals/refresh while staying on the same item.
A regression switches A (manually higher price) → B → A and verifies the fresh
lowest row is selected on return.
