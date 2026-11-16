# 06: Post all marked AH items and reconcile the batch

**What to build:** From the batch review in Copperwise's AH tab, the player clicks Post all to post eligible AH-marked quantities through successive supported native posting calls. Confirmed results reduce intent; unfinished items remain pending. The normal path does not require rebuilding or individually reviewing each listing.

**Blocked by:** 05: Review AH-marked items in the native AH tab.

**Status:** ready-for-agent

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
