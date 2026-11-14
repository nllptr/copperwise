# 18: Probe native auction-house scanning

Type: prototype
Status: in-progress — implementing bounded native query probe; runtime acceptance pending
Labels: ready-for-agent
Blocked by: None — requires target-client runtime access, not upstream API credentials.

## Purpose

The owner wants recent prices from Copperwise's own auction-house tab while
API credentials are pending. The backend/API and companion will provide history
across offline periods. Establish the client scan path before building a full
posting or ingredient-purchasing workflow.

## Scope

- Inspect supported scanning/query APIs for the actual Forever client and the
  installed Auctionator/TSM implementations as research material where available.
  Prefer a standalone Copperwise tab; Auctionator integration remains a fallback.
- Build a bounded, user-initiated, read-only scan probe using supported APIs.
  Record client/platform builds, required AH access, query/cooldown behavior,
  results/coverage and errors. Do not assume a full-market scan is available.
- For comparable sample trade goods, expose lowest buyout per unit, stock that
  the scan actually covers, scan time and result completeness. Distinguish
  bid-only coverage and confirm quantity/buyout semantics in the target client.
- Show progress, throttling, incomplete coverage, failures and observed empty
  results distinctly. A cancelled or partial scan must not appear complete.
- Keep local observations separate from imported backend history and its
  provenance. Do not fabricate offline history or change the companion import
  model. Do not claim a continuously live market feed.
- Record runtime evidence and limitations. Check coexistence when Auctionator
  is installed; do not assume another addon's active scan can be interrupted.

## Acceptance boundary

Use the existing target-client capability-probe seam: a real supported query
produces visible sample results with recorded timestamps/coverage in the actual
client. Syntax checks or an installed third-party source tree alone are not
runtime proof. No API credentials are needed for this probe. Full production
collection, historical reconciliation, buying/posting transactions and crafting
queue execution remain separate work and retain their feasibility requirements.

## Origin

2026-11-14: Owner proposes native AH scanning for current observations, while the
API/backend/companion accumulates market history during offline periods. See
the selling-context specification for the broader UX direction. No scanning
implementation or runtime acceptance is claimed by this ticket.

## Comments

2026-11-14: Implemented the standalone [native AH probe](../../../probes/auction-house/README.md)
with a Copperwise tab, three sample trade goods, user-triggered bounded modern
queries, covered stock/unit buyout, completeness/time diagnostics and explicit
partial/empty/cancel/error states. Forever UI source selects the modern path;
installed Auctionator's legacy files alone do not establish the active API.
Read-only query hooks stop Copperwise on competing requests; no other scan is
aborted. Added a public target-client acceptance checklist and bounded evidence.
[Runtime report](../../../probes/auction-house/REPORT.md) remains pending; M18 is
not complete until actual-client query and coexistence evidence is recorded.

2026-11-14: Owner screenshot confirms native panel opens with Auctionator enabled
but exposes incorrect upper/rightward tab placement. Corrected the probe's native
tab anchor to follow Auctions at the bottom; template parentArray registration
had made Auctionator follow the misplaced probe. Layout retest and scan runtime
evidence remain pending; screenshot contains no query result.

2026-11-14: Owner screenshots verify corrected bottom-tab placement and selecting
Copperwise then Buy. Initial selected-texture artifact clears after interaction;
added explicit initial tab deselection, pending retest. Peacebloom scan reports
complete, 23 rows, 2,439 units, minimum 38 copper/unit, no bid-only units, one
request, full=true at 22:38:03 CET. Recorded in report. Independent native
quantity/price comparison, build/market diagnostics and remaining coexistence/
failure-path checks remain pending; M18 stays in progress.

2026-11-14: Owner independently confirms the Peacebloom price result is correct.
Recorded the 38 copper/unit comparison. More-after-complete screenshot confirms
no extra request was sent; disabled that button outside eligible partial results
and clarified the local request-cap label. Remaining runtime checks stay open.

2026-11-14: Owner reports Copper Ore succeeds after an initial uncached-metadata
refusal. Replaced the refusal with bounded, cancellable item-information loading
that continues the same user-initiated scan once ready, without retrying an AH
search. Added build/market/result diagnostics to status for remaining evidence.
Updated the acceptance checklist; actual-client loading/cancellation, independent
stock comparison and active-Auctionator coexistence checks remain outstanding.

2026-11-14: Inspected only dedicated saved probe evidence. Recorded actual client
1.60.1/build70938/interface16001/macOS, native realm/faction/region context and
Auctionator-loaded=true. Both samples are commodities; Copper Ore full results
show 33 rows, 5,396 units and 88 copper/unit. Build/context evidence is no longer
missing; independent stock/Copper Ore price comparisons and cancellation/active
scan coexistence remain pending. No upstream-market mapping claim follows.

2026-11-14: Owner screenshot verifies full Rough Stone (2835) results at 22:57:25
CET: 16 rows, 1,615 units, minimum 9 copper/unit, no bid-only units, one request.
More is correctly disabled after completion. Initial cache state and independent
price/stock comparison are not established by this screenshot. Remaining
cancellation and active-search coexistence checks stay open.

2026-11-14: Owner confirms Rough Stone completed with one click and no errors,
and native AH price/stock match: 9 copper/unit and 1,615 units. This passes the
sample commodity price/covered-stock comparison. Cancellation, close/reopen and
active-Auctionator search coexistence still require runtime evidence.

2026-11-14: Owner cancellation-macro screenshot shows Peacebloom cancelled at
23:00:20 CET after one request, with no accepted results, unavailable price/stock
and full=false. Immediate local cancellation passes; late-response stability and
close/reopen recovery remain to be confirmed.
