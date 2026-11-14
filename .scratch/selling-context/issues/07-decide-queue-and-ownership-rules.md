# 07: Choose queue and ownership rules

**What to build:** The owner can review small queue scenarios and settle quantity, lifecycle and counted-ownership semantics before transactions are built.

**Blocked by:** S02: Explore the Crafting screen; S04: Verify bank observations and freshness.

**Status:** completed — owner approved queue and ownership rules

**Labels:** completed

**Type:** task

- [x] Resolve craft count versus desired output count, sale quantity selection, queue edits/removal and what intent persists across window changes, reload and logout.
- [x] Choose an explicit cached-bank subtraction policy using the bank probe evidence; distinguish counted holdings, age, withdrawal needs and unknown availability.
- [x] Resolve how shared owned ingredients are allocated across queued crafts without counting the same unit twice, and how quantity changes affect remaining needs.
- [x] Record agreed policies with examples for cancelled, partial and successful actions; queue intent must not itself buy, post, craft or transfer anything.

## Scope and verification

One bounded queue-state decision document and example walkthrough; no broad transaction implementation or cross-character tracking.

Use the approved integrated inventory, crafting and auction-house workflow
specification. S identifiers refer to this selling-context ticket series;
M identifiers refer to the existing market-trends series. A ready-for-agent
status does not bypass blockers or turn unverified capabilities into facts.

## Comments

2026-11-14: Published using to-tickets after the owner approved the 23-slice
breakdown and requested tickets small enough for a single fresh context.
Testing follows the owner-confirmed public pipeline and actual-client boundaries.

2026-11-14: Prepared [queue rules and synthetic walkthrough](../queue-rules.md)
from the approved S02/S06 presentation and S04 runtime evidence. Defaults are
proposals, including persistence, cached-bank eligibility, shared allocation and
cross-queue priority. Acceptance remains open pending owner decisions. This is
documentation work; no production queue or runtime behavior is claimed.

2026-11-14: Owner approved craft counts rather than desired output counts.
Recorded in the decision document; remaining quantity, lifecycle and ownership
policies are still under discussion, so acceptance remains open.

2026-11-14: Discussing whether manually queued craft outputs can supply later
crafts. Owner states crafts cannot fail, anticipates possible extra yields and
prefers compact quantities with tooltip detail (example `Needed: 3 (4)`). Exact
notation and dependency policy remain open; captured in the decision document.

2026-11-14: Owner approved ordered projection from explicitly queued crafts,
manual reordering, green/yellow/red borders plus coverage counts on one row per
recipe, and generating a shopping list for the whole queue accounting for earlier
producers. Only covered crafts supply the current coverage projection; shopping
calculates inputs needed to complete all queued crafts. Automatic subcraft
insertion remains excluded. Supersedes the earlier tentative quantity notation.
Bank eligibility, sale priority and lifecycle decisions remain open.

2026-11-14: Owner approved persistent per-character sale and craft queues across
reload/logout, retaining intended quantities while recalculating coverage from
revalidated holdings on return. Remaining policies stay open.

2026-11-14: Owner approved an Include bank checkbox, prioritizing bag materials,
and warning icons on craft-queue rows requiring bank materials even when covered.
Recorded tooltip withdrawal detail. Checkbox initial state, preference persistence
and eligibility of dated cached counts remain to be confirmed.

2026-11-14: Owner approved remembering Include bank per character and using
last-observed bank counts away from the bank when enabled, with observation age
shown. Initial checkbox state before first use remains open.

2026-11-14: Owner approved sale-before-craft material allocation: ten owned herbs
minus six marked for sale leaves four eligible for crafts needing eight, so
shopping needs four. Removing sale intent releases its allocation; the same
owned units cannot satisfy both queues.

2026-11-14: Owner approved completion bookkeeping: subtract completed crafts or
successfully posted units, preserve unfinished quantities after cancellation or
interruption, remove entries at zero, and reduce shopping needs when purchased
ingredients arrive in bags without reducing queued craft counts. Manual removal
does not undo purchases or cancel posted auctions.

2026-11-14: Owner approved final sale-quantity defaults, initially unchecked bank
inclusion and additive duplicates. All S07 policies are settled in the linked
decision document; ticket complete as design work. Runtime implementation and
acceptance remain in S15–S20. Ordered manually queued output projection is now
approved scope; automatic recursive recipe insertion remains excluded.
