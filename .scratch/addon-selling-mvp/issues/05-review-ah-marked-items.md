# 05: Review AH-marked items in the native AH tab

**What to build:** Open Copperwise's native AH tab to review the entire AH-marked sale plan in one compact list, with proposed posting terms and optional edits. This prepares the simple mark → visit AH → Copperwise → Post all flow; it submits no transactions.

**Blocked by:** 04: Mark and maintain sale intent (resolved).

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Extend the existing Copperwise AH tab with a compact review of all AH-marked items; retain Full scan, the separate Inventory marking window and normal native navigation.
- [ ] Populate the review only from explicit AH intent, including restored intent. Vendor-marked and unmarked holdings never become posting candidates. Keep unavailable or unsupported marked entries visible with a reason rather than silently dropping the plan.
- [ ] Show each item's identity, intended units, currently eligible units, proposed unit/total buyout, duration and native-calculated deposit where available. Show shortages and unavailable terms distinctly; do not present unknown prices or deposits as zero.
- [ ] Provide sensible proposed posting terms, optional per-item edits and a shared duration setting. Review the batch at a glance: do not require selecting, configuring or separately approving every row or source stack. Price defaults and refresh policy must be explicitly settled and recorded before enabling posting; no automatic undercut strategy is mandated.
- [ ] Prepare supported source stacks within current bag availability, allowing multiple stacks to fulfill one marked item without automatic stack consolidation. A stack boundary must not force the player to rebuild or individually review the same item repeatedly.
- [ ] Show which entries are ready and which remain pending, with a compact batch quantity/proceeds/deposit summary where those values are known. Provide a clear Post all entry point/layout for ticket 06; it remains non-operational in this review-only slice.
- [ ] Refresh or invalidate preparation when identity, holdings, eligibility or terms change. AH closure/cancellation discards preparation without discarding saved intent; reopening rebuilds the review and never starts posting.
- [ ] Verify the complete marked-list handoff, filtering, shortages, proposed terms, optional edits, stack coverage, invalidation, cancellation, native tab layout and Auctionator coexistence in the target client. This slice submits no posts.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.

Owner clarification 2026-11-15: the AH tab hosts Full scan as well as later
posting review. Its posting queue remains restricted to AH-marked items; the
full scan covers the market independently of that queue.

### Batch review alignment — 2026-11-15

Owner wants a dead-simple flow: mark items, visit the AH, open Copperwise and
Post all. Ticket 05 remains the review surface for everything marked for AH;
it is not a mandatory one-item-at-a-time wizard. Ticket 06 owns execution of
the reviewed list through successive native postings. The default price rule,
price-refresh policy and shared duration default remain product decisions to
settle during implementation; matching the lowest buyout was suggested but
has not been approved as the required pricing rule.

### Implementation — 2026-11-15

Owner approved proposed terms: compatible retained complete-scan lowest unit
buyout, no undercut; refresh unedited defaults after a new complete scan; retain
item overrides until cancellation/closure; shared duration defaults to 24 hours.
Native duration indices are 2/8/24 hours (posting probe evidence), not retail's
12/24/48 hours. Tab departure also discards ephemeral review terms.

Implemented the full AH-only review, optional unit-price edits, shared duration,
source-stack eligibility/native deposits, shortages and known batch totals in
`addons/Copperwise/Review.lua`. Post all remains disabled; no posting call exists.
Saved intent and account schemas are unchanged. Review preparation is ephemeral
and must be revalidated by ticket 06 before dispatch.

Actual-client acceptance is pending using the checklist in
[addon README](../../../addons/Copperwise/README.md#ticket-05-target-client-acceptance--pending).
Implementation and supporting repository checks do not resolve this ticket.

Supporting validation: production Lua files compile with LuaJIT; existing Inventory,
storage and scan regression suites and `CGO_ENABLED=0 go test ./...` pass.
Review against starting commit `ea56479`: Standards found no violations or
baseline smells. Spec found missing reasons for partially ineligible quantities
(fixed by recording native eligibility/classification/locked-stack reasons) and
pending required actual-client acceptance (still outstanding). No transaction
calls were added. Native layout/coexistence and integrated handoff remain unverified.
