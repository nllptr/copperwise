# 08: Verify one native posting action

**What to build:** An operator can post one supplied sample item through a minimal native Copperwise AH surface using supported client actions.

**Blocked by:** M18: Probe native auction-house scanning.

**Status:** in-progress — reopened; direct posting from Copperwise required, native Sell handoff is insufficient

**Labels:** ready-for-agent

**Type:** prototype

- [x] Investigate supported AH tab and posting APIs on the actual client; record required user actions, bag eligibility, quantity and price semantics.
- [ ] With an operator-supplied sample and operator-selected terms, perform one deliberate post and record the confirmed result rather than treating a button click as success.
- [x] Observe an invalid/unavailable-item or cancelled attempt and show honest feedback without repeated or unintended submissions.
- [x] Record coexistence limitations and any native integration failure. Investigate Auctionator only as an evidenced fallback, not an assumed dependency or sell-list API.

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

2026-11-15 completion: the owner supplied a screenshot after Review native
Sell showing Rough Stone ×1, unit/total buyout 15 copper, duration 8 Hours and
deposit 1 silver. After clicking native Create Auction, the owner explicitly
confirmed both the new owned listing and one fewer bag item, with no errors.
The screenshot also shows native tabs and Auctionator tabs present; this is
one successful idle-coexistence sample, not concurrent-operation validation.
S08 closes as a bounded commodity capability investigation via native Sell
handoff. Direct addon posting remains blocked; a fully custom-tab transaction,
noncommodity posting, batch semantics and broad coexistence remain unverified.
Earlier pending notes above are superseded for this verified sample only.

2026-11-15 reopened by owner: native Sell handoff is not a satisfactory
implementation of the Copperwise posting workflow. The prior completion
was premature. Retain handoff/control evidence as diagnostic evidence only;
S08 requires a deliberate post directly from Copperwise's own surface.
Compare the installed Auctionator direct call path and isolate the exact
restricted-action failure before another posting trial.

Direct-post revision: owner confirms Auctionator's own Selling tab posts on this
client. Current candidate matches its named XML-button -> parent PostItem ->
direct PostCommodity/PostItem shape, retains reviewed ItemLocation and rechecks
link/count/deposit. Unlike the original probe, the clicked button is not disabled
before the restricted call. No root cause is claimed before runtime evidence.
Lua/XML parsing, whitespace, Go vet and full Go suite pass. Standards review's
stale handoff-only wording was corrected. Spec review's exception-feedback issue
was addressed with expected-readiness refusals and deferred consumed-state UI
rendering; no protected-call wrapper surrounds transaction dispatch. Direct
posting acceptance remains unchecked pending an actual listing and bag change.
