# 08: Verify one native posting action

**What to build:** An operator can post one supplied sample item through a minimal native Copperwise AH surface using supported client actions.

**Blocked by:** M18: Probe native auction-house scanning.

**Status:** in-progress — runnable probe implemented; awaiting actual-client posting and cancellation evidence

**Labels:** ready-for-agent

**Type:** prototype

- [ ] Investigate supported AH tab and posting APIs on the actual client; record required user actions, bag eligibility, quantity and price semantics.
- [ ] With an operator-supplied sample and operator-selected terms, perform one deliberate post and record the confirmed result rather than treating a button click as success.
- [ ] Observe an invalid/unavailable-item or cancelled attempt and show honest feedback without repeated or unintended submissions.
- [ ] Record coexistence limitations and any native integration failure. Investigate Auctionator only as an evidenced fallback, not an assumed dependency or sell-list API.

## Scope and verification

Single capability transaction, not a batch seller. No automatic purchases, posting strategy or proof of full production readiness.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.

2026-11-14: Implemented the standalone [posting probe](../../../probes/posting/README.md)
with operator-selected bag slot/quantity/price/duration, native deposit preview,
revalidation and a separate single-dispatch button. Inventory changes and tab
lifecycle discard previews; attempted requests lock further posts for the visit.
Native events and API returns are never labelled confirmed listings. Extra
native-confirmation requirements are reported without automatic confirmation.
[Runtime report](../../../probes/posting/REPORT.md) and public-client checklist
are ready. All acceptance boxes remain open pending actual-client evidence.

Repository validation: Lua 5.1 syntax compilation, `go vet ./...` with CGO
and the full `go test ./...` suite without CGO passed. Whitespace check passed.
Standards review found no actionable violations; spec review checked dispatch
and lifecycle behavior separately. These checks do not pass runtime acceptance.
