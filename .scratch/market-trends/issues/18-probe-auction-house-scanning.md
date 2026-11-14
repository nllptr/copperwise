# 18: Probe native auction-house scanning

Type: prototype
Status: ready-for-agent
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
