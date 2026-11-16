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

Owner client run 2026-11-15 21:51:33: opening the review failed at
`Review.lua:10` because `GetCoinTextureString` is absent in this client, including
when rendering the zero-valued empty summary. Fixed by sharing Inventory's
existing currency formatter with Review: prefer available native texture/money
formatters, then use explicit gold/silver/copper text. Missing values remain
unavailable and known zero remains numeric zero. Reload verification is pending.

### Owner-directed layout prototype — 2026-11-15

Owner confirms marked items are listed after the formatter fix, and supplied
screenshots showing the review and Auctionator navigation. The current production
layout is not approved. Owner requests a proper prototype first, under
`probes/ah-layout/`, before reimplementing the appearance:

- AH-marked sidebar with automatic first-item selection.
- Selected-item quantity, unit buyout, deposit, total price and duration radios.
- Current selected-item listings with only unit buyout and available item units.
- A selected-item Post button; Full scan and the Post all placeholder in a shared
  top section, following the supplied Auctionator layout references.

[Interactive prototype](../../../probes/ah-layout/index.html) and its
[review guide](../../../probes/ah-layout/README.md) implement this study with
synthetic fixtures only. Production is unchanged pending layout review.
Current-listing depth requires selected-item queries beyond the retained summary;
price defaults/refresh for that new workflow need reconciliation. Actual posting
remains ticket 06. Screenshots establish rendered marked rows and native/Auctionator
tabs, not full layout approval, deposit acceptance or posting evidence.

### Approved layout implementation — 2026-11-15

Owner approved `probes/ah-layout/index.html` and requested implementing it in the
addon, including the selected-item form, clickable current-listing price levels,
radio duration, individual Post item and global scan/Post all header. This
supersedes the earlier textual whole-list visual presentation. The AH-marked
plan remains complete in the sidebar; Post all stays a placeholder.

Production now separates full-market summary scans from ephemeral selected-item
commodity listings, grouping item units by unit buyout. Unedited defaults use the
compatible retained minimum until complete current-item results supply their
lowest price. Explicit price choices/edits survive item switching/refresh, and
closure/tab departure resets ephemeral terms. This implements the approved
prototype's current-listings behavior without replacing the global saved scan.

Individual Post item uses the verified XML/native path and one revalidated source
stack per click; the same form retains reviewed remainder after confirmation.
New owned-listing identity + exact terms + settled bag decrease confirm intent
consumption. A persisted unresolved-post ledger blocks retries and supports
explicit operator reconciliation. Post all/automatic batch advancement remain
in ticket 06. No synthetic posting is used in production.

Native acceptance is pending under the replacement checklist in the addon README.
The old screenshots establish the earlier marked-list handoff and native tab
navigation only; the owner rejected that layout. This ticket remains open until
the new integrated flow is verified in the actual client.


Supporting implementation checks: LuaJIT compilation, existing Inventory/storage/
scan regression suites and `CGO_ENABLED=0 go test ./...` pass. The native owned
listings path explicitly requires native completeness. Commodity owned buyout is
matched per unit, consistent with installed Auctionator's Cancelling provider;
actual-client verification of that attribution remains required.

Review against `83b9b88`: Standards found no documented violations; two judgment
smells (duplicated numeric validation and an unclear source-stack name) were
addressed. Its coordination concern prompted conservative external-request
completeness checks, including partial result continuations. Spec found an intent
remove/re-mark or edit-away/back race; per-item in-session revisions now prevent
an earlier outcome from automatically consuming changed intent, even at an equal
quantity. Reloaded outcomes still require explicit operator reconciliation.
Client acceptance remains outstanding for both layout and native execution.

### Compact scan header — 2026-11-15

Owner reports the replacement layout is a very good start and requests reclaiming
vertical space. Removed Market scan heading and the multi-line status block.
One right-aligned status now sits immediately left of Full scan/Cancel scan;
relative successful-scan age updates each second while visible, from <1 minute
through minutes, approximate hours, days and weeks. Completion immediately resets
the label from the newly published snapshot; cancellation/failure retains the
previous complete scan's age with a concise status. Full details are on hover.

During collection the native summary API does not expose a total, so show processed
item count instead of inventing a percentage. Processing the final complete cache
shows its actual processed-row percentage, capped below 100 until publication.
The panel moved up 25 UI units and the item area another 46, reclaiming 71 total.
Target-client visual verification of this spacing change is pending.

### Full selected-item quantity — 2026-11-15

Owner confirms the compact top layout and scanning work to satisfaction. Owner
also confirms Post item created a real listing, but only posted 20 of the reviewed
26 units (20 + 6). This verifies the previous single-source path, not full reviewed
quantity acceptance or all reconciliation cases. Owner expects native Max /
Auctionator behavior: a single Post item posts the chosen quantity across stacks.

Installed Auctionator `SaleItem.lua` uses GetAvailablePostCount(location), caps
against its holdings count, computes native commodity deposit for the entire
chosen quantity and passes that quantity to PostCommodity with one anchor location.
Production now follows that path, bounded by marked intent, eligible bag units and
the native quantity limit. Every contributing source stack is revalidated. Deposit
is calculated once for the total, rather than summed from stack-level minimums.
Reconciliation sums new owned-listing units at the reviewed price so either one
aggregate listing or several native listings can establish the full quantity,
still requiring the matching settled bag decrease and unchanged intent revision.
The previous one-source-per-click limitation is superseded. Full-quantity posting
and native deposit/reconciliation need a new target-client check; Post all remains
disabled and ticket 06 remains open.

### Owned-listing failure and stalled market query — 2026-11-15

Owner screenshot after the full-quantity update shows raw `Posting.lua:35:
Owned-listing identity unavailable`, disabled Post item and a current-listings
table stuck waiting. The screenshot does not distinguish a nil row/ID from a
repeated ID, so the exact native row condition remains unverified.

Fixed two independent lifecycle bugs: a selected query discarded by competing
AH activity can requeue if it has neither a request nor a result; failed owned
baseline checks now pause instead of being retriggered by every UI render.
Refresh item explicitly retries both the selected market query and posting check.
Market browsing does not require a valid owned-listing baseline.

Owned identity maps now use native numeric IDs (avoiding tostring rounding),
coalesce identical duplicate cache rows without counting more units, and refuse
missing IDs or conflicting duplicates with user-facing detail instead of a raw
Lua source path. Posting remains blocked when attribution is unavailable. No
pending ledger or saved intent is discarded. Reload verification remains pending.

### Existing owned-ID conflicts — 2026-11-15

Owner's follow-up screenshot confirms native owned ID 115489437 appears in
conflicting rows. The exact differing fields and native grouping semantics are
not yet established. The earlier blanket rejection was broader than attribution
requires: a before-post baseline only needs every already-present ID in its
exclusion set. Existing duplicate/conflicting IDs can be excluded without using
their price, quantity or item metadata as evidence of a new post.

Owned reads now retain the complete valid ID set, deduplicate identical rows,
and separately track conflicting IDs. Existing conflicts no longer block fresh
posting. If a newly seen ID has conflicting rows after dispatch, automatic
confirmation is withheld and explicit operator reconciliation remains required.
Missing IDs remain blocking. No conflicting rows are summed or silently chosen
as confirmation evidence. Actual-client recovery remains pending.

### Listings remain queued — 2026-11-16

Owner screenshot still shows no current listings, generic quiet-AH waiting and
Waiting for fresh owned listings. Static tracing found an incorrect readiness
condition introduced by the conservative completeness gate: an external native
browse/search page can return successfully while HasFull* remains false. Holding
that page's request token until entire-market coverage incorrectly prevents both
selected-item and owned-listing queries after native navigation stops paginating.
Installed Auctionator SearchScan/Throttling code also treats a usable nonempty
partial response and native throttle readiness separately from full coverage.

External tokens now release on a usable matching page response (nonempty rows or
native complete-empty), while quiet time, native throttle readiness, Auctionator
queue checks, overlap handling and Copperwise's own result completeness remain.
Unanswered/overlapping requests explicitly request close/reopen rather than showing
an indefinite generic wait. The selected-item status now exposes its actual
readiness/metadata blocker. Metadata waits are bounded; an initially throttled
unsent query retains its dispatch state for retry. This changes query readiness,
not the complete-observation requirements for prices or posting attribution.
Actual-client recovery is pending; no posting or scan acceptance is inferred.

### Owner client verification — 2026-11-16

After installation of `7ce4939`, owner confirms current auction listings load
successfully. Owner also confirms one Post item action successfully posts a full
stack plus extra units together. This passes the reported readiness recovery and
cross-stack selected-item posting cases. No exact item/quantity, owned-listing
IDs, deposit comparison or explicit automatic intent-reconciliation observation
was supplied, so those details are not inferred. Prior owner approval of compact
layout and scanning remains recorded. Remaining checklist cases are not silently
accepted; multi-item Post all stays disabled and ticket 06 remains open.

2026-11-16 follow-up: owner confirms all held units were marked and the item
disappeared from the marked list after the successful cross-stack post. This
verifies automatic intent consumption/removal for that completed selected-item
post, in addition to current-listings loading and cross-stack execution. It does
not establish partial-intent remainder, failed/uncertain outcomes or every other
acceptance permutation.

2026-11-16 follow-up: owner confirms the partial-post verification works:
posting fewer units than marked leaves the item listed with the unposted
remainder still marked. The suggested example was mark 10/post 3/retain 7;
owner did not supply exact sample quantities. This verifies the partial-intent
remainder behavior, alongside the preceding full-removal case.
