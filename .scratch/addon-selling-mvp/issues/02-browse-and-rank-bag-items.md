# 02: Browse and rank bag items

**What to build:** The Inventory window lists aggregated bag holdings, allows item selection and ranks complete AH/vendor comparisons from retained full-market summary observations using the approved destination rules.

**Blocked by:** None — ticket 01 resolved (2026-11-15).

**Status:** in-progress

**Labels:** ready-for-agent

- [ ] List bag item kinds with icons, names and aggregated quantities; identify unsupported auction items and retain understandable missing-data states.
- [ ] Selecting a row changes detail independently of future marking controls
  and reads the retained full-scan observation for that item; selecting a row
  never sends a market query.
- [ ] Keep Full scan and cancellation exclusively in the Copperwise native AH
  tab. Missing Inventory data remains unavailable and directs the player there;
  do not add selected-item or sequential bag-item queries to Inventory.
- [ ] For the same owned quantity, show AH asking total and vendor sell total; rank complete comparisons by the larger total descending, then name and stable identity, with unavailable comparisons last.
- [ ] Choose Vendor on equal totals; withhold the destination action when either comparison value is unavailable, while keeping known numeric zero distinct.
- [ ] Refresh settled holdings and metadata without presenting transient stack moves/splits as actionable extra inventory.
- [ ] Verify multiple item selections, rankings, ties, zero and unavailable values and changed holdings through visible production-addon behavior in the target client.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.

### Full-scan workflow reconciliation — 2026-11-15

Owner requires an entire-market summary-mode scan like Auctionator. The native
Copperwise AH tab owns collection, progress and cancellation; standalone Inventory
is for reviewing/ranking holdings and later assigning AH/Vendor sale intent.
This replaces the original selected-item query criterion above. Reuse ticket 01's
retained snapshot interface and native commodity comparability restrictions.
Partial, failed or cancelled refreshes must not replace successful observations
or make their asking values appear newly observed.

Ticket 01's current acceptance checklist is the authoritative dependency status.
Its verified core workflow is recorded, but unverified edge cases remain open;
this edit does not silently waive the dependency or start ticket 02 implementation.

### Dependency resolved — 2026-11-15

Ticket 01 is now resolved using its recorded production-client evidence and the
owner-approved controlled diagnostics, which passed 7/7 in the target client.
Its current checklist distinguishes native observations from simulated edge
cases and records remaining evidence limits. Ticket 02 is unblocked; no ticket
02 implementation or acceptance is implied by this update.

### Implementation — 2026-11-15

Replaced the Inventory dropdown with a scrollable list of item icons, names and
aggregated quantities. Complete comparisons sort by greatest destination total,
then name and stable item ID; unavailable comparisons sort last. Detail shows
AH asking and vendor sell totals for the same owned quantity. Equal totals
prefer Vendor; known zero remains numeric. Missing comparisons have no
destination recommendation. Recommendations are labels in this slice; ticket
04 adds marking actions independently of row selection. Selection only reads
retained observations; scan controls remain exclusively in the native AH tab.
Existing bag/cursor settling continues to withhold actionable totals while
holdings change. Metadata is refreshed with settled snapshots.

Target-client acceptance remains pending; no native-client pass is claimed.
Use `/cw` after installing the updated addon and check:

1. With a retained complete scan, compare several commodity rows against their
   bag totals and native vendor sell values. Select each row; verify both totals
   use the displayed quantity and the retained timestamp does not change.
2. Confirm descending greater-total order; equal ranking values sort by name,
   then item ID. Scroll through more rows than fit in the viewport, select a
   lower row, and confirm selection survives a holdings-driven reorder.
3. Verify equal AH/vendor totals prefer Vendor, known-zero vendor remains zero,
   missing vendor metadata withholds the destination, and unavailable AH data
   sorts last. Use controlled client diagnostics only with explicit approval if
   native examples cannot be obtained; record simulated evidence separately.
4. Check unsupported items, metadata loading, no retained observation and
   observed-empty supply remain understandable. No missing value becomes zero.
5. Split, merge, move, lock and remove bag stacks; hold an item on the cursor.
   Totals and recommendations must be withheld until holdings settle; no
   transient extra inventory may become actionable. Check metadata completion.
6. Confirm selection never sends an AH query, Inventory has no scan controls,
   and native Copperwise Full scan/cancellation still work independently.
7. Confirm readability, scrolling and selection at the normal target UI scale.

### Acceptance feedback — screenshot capture

Owner reports the initial browsing UI looks good, but screenshot capture briefly
reorders the list before it returns to its normal order. Code inspection found
that temporarily withheld comparisons fell back to alphabetical sorting during
cursor/lock settling. Preserve the last settled order during this interval,
while continuing to withhold totals and recommendations. Re-rank after holdings
settle. Screenshot-specific event attribution and the fix still require client
confirmation; no additional acceptance criteria are marked passed.

### Owner-approved retained display — 2026-11-15

Owner confirmed row order stays intact during screenshot capture, but prices
still briefly become unavailable. Owner requested retaining last known display
values through mouse events and refreshing when those interactions finish.
Keep last settled quantities, comparisons and order visible with a single
updating status. Replace holdings only after the existing settling checks pass.
`SelectedItem()` remains unavailable while unsettled/cursor-held, so retained
display values cannot authorize future sale actions. This supersedes the earlier
acceptance instruction to hide displayed totals during transient bag changes;
no transient snapshot is published. Recheck screenshot capture and actual stack
moves/splits/removal, confirming the display stays stable then updates to the
settled quantities and ranking. Client confirmation remains pending.

### Display acceptance follow-up — 2026-11-15

Owner confirmed displayed values stay steady. Requested removal of the list
heading/update status: settling stays internal, while the last settled display
remains visible. Removed that heading and tried the native gray dialog background
(`Interface\DialogFrame\UI-DialogBox-Background`) in the Inventory inset.
Background appearance still needs owner confirmation in the target client.
