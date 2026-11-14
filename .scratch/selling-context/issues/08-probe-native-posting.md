# 08: Verify one native posting action

**What to build:** An operator can post one supplied sample item through a minimal native Copperwise AH surface using supported client actions.

**Blocked by:** M18: Probe native auction-house scanning.

**Status:** in-progress — direct posting blocked in client; native Sell handoff implemented, awaiting runtime verification

**Labels:** ready-for-agent

**Type:** prototype

- [ ] Investigate supported AH tab and posting APIs on the actual client; record required user actions, bag eligibility, quantity and price semantics.
- [ ] With an operator-supplied sample and operator-selected terms, perform one deliberate post and record the confirmed result rather than treating a button click as success.
- [x] Observe an invalid/unavailable-item or cancelled attempt and show honest feedback without repeated or unintended submissions.
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

Runtime follow-up: owner verified native tab opening, preview/cancellation with
item retained, 2/8/24-hour duration choices and matching 1-silver client deposit.
Repeated direct PostCommodity attempts were addon-blocked, including after
removing wrappers/hooks and deferring chat. Native Sell posted the same chosen
Rough Stone ×1 at 15 copper for 8 hours with the probe disabled. Replaced the
failed direct posting button with a preparation-only native Sell handoff; final
review and posting remain on Blizzard's native button. Handoff runtime evidence
is pending; native control success does not complete Copperwise acceptance.

Validation after handoff revision: Lua syntax, whitespace check, Go vet and
full Go suite passed. Preview cancellation acceptance is supported by the
owner's explicit observation that the button disabled and the item remained.
Integrated posting and coexistence acceptance remain pending.

Follow-up review: standards found no actionable findings. Spec review found
a stale native duration-dropdown label risk; fixed by regenerating its menu
after changing duration. Actual-client test must include a changed duration.
