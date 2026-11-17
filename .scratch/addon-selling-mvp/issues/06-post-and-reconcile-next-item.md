# 06: Post all marked AH items and reconcile the batch

**What to build:** From the batch review in Copperwise's AH tab, the player clicks Post all to post eligible AH-marked quantities through successive supported native posting calls. Confirmed results reduce intent; unfinished items remain pending. The normal path does not require rebuilding or individually reviewing each listing.

**Blocked by:** 05: Review AH-marked items in the native AH tab.

**Status:** in progress — implementation and simulated acceptance complete; target-client verification pending

**Labels:** ready-for-agent

- [ ] Add an operational Post all action to ticket 05's reviewed list. One deliberate action starts a bounded session for that reviewed batch; never assume one native request can post several items.
- [ ] Establish in the target client whether the sequence can advance after confirmed outcomes from one initial click, or whether additional hardware clicks are required. Prefer one-click-started succession where permitted; otherwise use one consistent posting button that advances the same reviewed list, requesting only the extra clicks the client actually requires. Preserve native confirmations; do not bypass client action restrictions.
- [ ] Execute native postings in succession, revalidating source identity, quantity, eligibility and reviewed terms immediately before each call. Cover multiple marked items and multiple source stacks per item without forced per-item/per-stack review. Never silently substitute unreviewed prices or terms.
- [ ] Attribute each result using native owned-listing evidence and reconciled holdings before advancing; a click, API return, shared event or bag delta alone is insufficient. Show concise progress through the batch.
- [ ] Reduce pending intent only by confirmed posted units, remove entries at zero and continue through eligible remaining quantities/stacks. The current batch covers only its reviewed intent; newly added or increased intent waits for a new review/start action.
- [ ] Keep shortages and known-ineligible/known-unposted failures pending with a visible reason. Other eligible entries may continue when it is established that no listing was submitted; never retry a failure automatically. An uncertain outcome pauses the sequence and blocks further posts/retries until reconciliation, with explicit operator reconciliation when reliable attribution is unavailable.
- [ ] Provide Stop/Cancel for the active sequence: dispatch no further postings, reconcile any in-flight outcome and retain all unfinished intent. AH closure/tab departure, competing AH activity or invalid reviewed terms stop/pause the session. Completed listings remain posted; reopening/reloading never resumes the batch automatically.
- [ ] Timers/events may only advance an explicitly started active batch where native permissions allow; marking, opening windows, restoring queues, scanning, login/reload and unrelated events never start a batch. Required native confirmations and each post's attribution remain intact.
- [ ] Verify Post all across several marked item types and multiple stacks, partial completion, shortages, stop/cancel, AH closure, changed availability/terms, known failures, uncertain outcomes, duplicate prevention and native owned-listing evidence in the target client. Record the actual click requirements and remaining limits.
- [ ] Confirm Vendor-marked/unmarked items and other-addon activity cannot enter, accidentally complete or consume Copperwise's batch intent; verify normal AH navigation and Auctionator coexistence.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

### Targeted summary scan and posting filters — 2026-11-16

Owner authorized implementation of a quick Post all flow: scan only AH-selected
item types before the posting phase, match their fresh lowest buyout, and skip
items below a configurable minimum supply (default 500 listed units). Immediately
before each post, net proceeds after the usual 5% AH cut must strictly exceed
vendor proceeds for the same quantity. Ties, missing prices/vendor values and
incomplete coverage keep intent pending. Persistent AH choices do not bypass
these batch filters. Listed supply is a filter, not evidence of churn or sales.

Implementation uses native SearchForItemKeys browse summaries, in bounded
100-key chunks, with complete coverage required before posting starts. No item
price-level search is issued by the batch, and targeted observations do not
replace the retained full-market snapshot. Opening/selecting the AH review now
uses retained prices; Refresh item explicitly loads individual price levels.
Batch prices deliberately replace individual price edits with the targeted
lowest buyout; reviewed quantities and the shared duration remain captured.

The AH tab exposes Min listed units, saved per character. The batch captures
that threshold, quantities, intent revisions, duration, deposits and source
stacks on start. Changes stop or withhold dispatch; newly added/increased intent
requires another start. Observations older than 60 seconds require a fresh batch.
Stop batch replaces Full scan while active and retains unfinished intent.
Confirmed owned-listing and settled-bag evidence still governs consumption and
advancement. Uncertain outcomes, native errors/confirmations, tab departure,
closure and competing AH work stop the batch without retries or auto-resume.

Automatic succession is attempted through the native API, without permission
bypasses. A blocked call preserves its durable pending ledger. After operator
reconciliation, further batches in that login use the same XML Continue posting
button for each native call. Actual native permissions and SearchForItemKeys
behavior on Forever remain unverified; missing API support refuses the batch.

Owner approved testing at the simulated native UI/API boundary and reviewing
against 2d3e45b. Production-module tests cover filters, quantities, source/deposit
changes, partial scan coverage/cache preservation, multi-item/cross-stack
confirmation, stop/reload/uncertainty, interference, price expiry and click fallback.
These do not resolve the target-client acceptance checklist above or ticket 07.

### Implementation review and checks — 2026-11-17

Two-axis review against owner-approved 2d3e45b found no documented standards
violations. Standards review identified a stale batch notice hiding later
individual validation/errors, and duplicated interpretation of scan activity.
Both were corrected and rechecked: deliberate individual work clears batch
results, pending-outcome guidance takes precedence, and Scan owns its button
rendering. A production UI regression covers the notice fix. Spec review found
no implementation mismatch or scope creep; its remaining finding is the pending
target-client acceptance described above.

All 20 batch boundary tests and the complete Inventory/storage/scan regression
suite pass. Lua syntax compilation and Go tests across the repository pass.
No native-server result is claimed by these checks.

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.

### Successive mass posting — 2026-11-15

Owner confirms ticket 05 can remain a whole-list review screen and requests
mass posting be explicit in ticket 06. The intended flow is mark → visit AH →
Copperwise → Post all. Multiple native postings in succession are expected;
multiple items in one native request are not assumed. The prior verified probe
establishes individual posting only. Whether one initial click can advance the
whole sequence is a target-client capability check, not an established fact.
This supersedes the earlier requirement for a separate deliberate action and
review for each post, while preserving attribution, reconciliation and native
permission requirements. User-started batch advancement is authorized within
the active reviewed session; background/unprompted batch starts remain excluded.

2026-11-15: Owner-approved ticket 05 prototype now includes selected-item Post.
Its implementation supplies deliberate single-source posting, before/after owned
listing + bag reconciliation, a persistent pending-outcome blocker and explicit
operator reconciliation. This is supporting infrastructure, not completion of
this ticket: Post all remains disabled, multi-item execution and automatic
advancement are unimplemented, and production client posting acceptance is pending.

2026-11-15 follow-up: owner verified one real 20-unit post, then requested the
full reviewed commodity quantity across stacks in one native call, matching
native Max/Auctionator. Ticket 05's individual path now uses GetAvailablePostCount
and total-quantity deposit/PostCommodity, with multi-listing quantity reconciliation.
This supersedes the earlier mandatory source-stack-sized calls for comparable
commodities; multi-item Post all remains separate and unimplemented.

2026-11-16: Owner confirms current auction listings now load and one selected-item
post successfully handles a full stack plus additional units in one action.
Cross-stack individual posting is now owner-verified supporting evidence. This
does not establish multi-item Post all, batch advancement, click requirements
across item types or the remaining outcome/reconciliation acceptance matrix.

2026-11-16 follow-up: owner confirms the fully marked item disappeared after the
successful cross-stack individual post. Automatic completed-intent removal is
verified for that case; partial/uncertain outcomes and Post all remain unverified.

2026-11-16 follow-up: owner confirms individual posting fewer units than marked
retains the unposted marked remainder. This passes the individual partial-intent
case; it does not verify partial completion of a multi-item Post all batch.
