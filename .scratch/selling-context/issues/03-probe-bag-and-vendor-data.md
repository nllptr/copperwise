# 03: Verify bag quantities and vendor values

**What to build:** A target-client probe displays actual bag quantities and vendor sell values for a few comparable sample items.

**Blocked by:** None (can start immediately).

**Status:** completed — settled counts and vendor metadata verified; transient update limitations recorded

**Labels:** completed

**Type:** prototype

- [x] Record the actual client/platform build and supported item/container metadata access used; show counts for selected sample bag items.
- [x] Move or split a sample stack and verify the displayed count reflects observed changes without double counting. Verified for settled snapshots; transient over/undercounts are a recorded limitation, not an atomic-count guarantee.
- [x] Distinguish vendor sell value from vendor purchase price, and known zero value from unavailable metadata.
- [x] Record actual-client outcomes, item-identity limitations and failures; syntax checks or third-party source alone do not pass the probe.

## Scope and verification

Read-only capability probe, independent of API credentials. Does not establish bank, alt or transaction access.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14 completion: client 1.60.1/70938/interface 16001 and local macOS
26.6.2/25G83 Intel recorded. Bogling Root remains total 2 after splitting,
merging and moving across bags 2 and 4; vendor tooltip matches metadata. S03
closes as a capability probe with the explicit limitation that intermediate
container observations can over/undercount. Production inventory must handle
updating states; neither BAG_UPDATE_DELAYED nor an unlocked slot alone proves
stability. See the report for timestamps, evidence and remaining production
boundaries. Earlier pending acceptance notes below are superseded.

2026-11-14 runtime follow-up: owner confirmed Bogling Root (5206) vendor sell
tooltip matches 37 copper/unit and 74 for two. Split and merge snapshots retain
settled total 2, but one intermediate split observation reports 3. Recorded in
the evidence report; no-double-counting acceptance remains open pending handling
and runtime retest. Client/build/platform evidence remains pending.

2026-11-14: Added the standalone [bag probe](../../../probes/bags/README.md)
with fresh slot-based sample totals, vendor sell metadata, zero/unavailable
distinction, bag/cache event refresh and bounded saved diagnostics. The existing
actual-client seam remains the acceptance boundary. Runtime checklist and
[evidence report](../../../probes/bags/REPORT.md) are ready; all acceptance
criteria remain open until observed in the target client.

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.
