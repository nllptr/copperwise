# Addon-only selling MVP

Status: open
Labels: ready-for-agent

## Problem Statement

The casual seller wants a usable way to review owned items, choose what to sell
and post those items without rebuilding a list at the auction house. Waiting
for API credentials, a backend, a desktop companion and accumulated price
history delays that useful workflow even though the required bag, scan and
posting capabilities have already been demonstrated in the target client.

## Solution

Ship one standalone addon with account-wide market observations and current-character
holdings and sale intent: review supported bag items, run a full auction-house summary scan from the Copperwise AH tab, compare total
AH asking value with total vendor sell value, mark quantities for sale, and
review the complete AH-marked list and deliberately start Post all from Copperwise,
posting eligible quantities through successive supported native calls.

These are two separate surfaces: a standalone Inventory window for reviewing
items and marking them for AH or Vendor, and a Copperwise tab inside the native
auction-house window for posting. The AH tab contains the items explicitly
marked **Sell on AH** in the Inventory window; Vendor-marked and unmarked items
do not enter its posting queue. This follows the native AH-tab approach already
used in the probes.

Keep the latest successful full-market summary scan available away from the AH,
with their observation time and coverage. The addon needs no API credentials,
backend, companion or Auctionator dependency. The initial supported market
items are comparable commodities within the verified native query/post paths;
this release does not promise every bag item's auction support.

Vendor-designated intent remains visible, but the player uses the normal
merchant UI to sell. Market history and crafting belong to later releases.

## User Stories

1. As a casual seller, I want to install one addon without external services, so that I can start using it immediately.
2. As a casual seller, I want an Inventory window accessible away from the AH, so that I can review what I own before visiting it.
3. As a casual seller, I want bag stacks of the same supported item combined, so that I can see my total owned quantity.
4. As a casual seller, I want unsupported items identified, so that missing auction support is understandable.
5. As a casual seller, I want to select an item and inspect its values, so that I can make a selling decision.
6. As a casual seller, I want vendor sell values distinguished from vendor purchase prices, so that I compare the correct proceeds.
7. As a casual seller, I want unavailable metadata distinguished from known zero values, so that missing data does not manufacture a recommendation.
8. As a casual seller, I want to request scans for supported bag items at the AH, so that I can obtain useful recent price context.
9. As a casual seller, I want scan progress and throttling visible, so that I understand when results are still pending.
10. As a casual seller, I want to cancel a scan, so that I can stop the work without accepting partial results as complete.
11. As a casual seller, I want Copperwise to respect other AH activity, so that its scans do not interrupt my normal workflow.
12. As a casual seller, I want the lowest observed buyout per unit and covered supply shown, so that stack sizes do not distort comparisons.
13. As a casual seller, I want no scan, failed scans, partial results and observed empty supply distinguished, so that I do not confuse missing prices with zero prices.
14. As a casual seller, I want the latest successful observations retained across reload/logout, so that I can review them away from the AH.
15. As a casual seller, I want scan age and market context visible, so that cached asking prices do not appear continuously live.
16. As a casual seller, I want an easily configurable stale-price warning, so that I can judge older AH comparisons.
17. As a casual seller, I want AH and vendor totals calculated for the same owned quantity, so that I can compare destinations fairly.
18. As a casual seller, I want the highest total destination values listed first, so that valuable holdings are easy to find.
19. As a casual seller, I want the destination button withheld when either comparison value is missing, so that an incomplete comparison does not choose for me.
20. As a casual seller, I want to mark an item and edit its intended sale quantity, so that my plan is independent of stack boundaries.
21. As a casual seller, I want marked items in a separate section, so that I can distinguish pending decisions from the rest of my inventory.
22. As a casual seller, I want duplicate additions, edits and removals to behave consistently, so that I can maintain my plan predictably.
23. As a casual seller, I want sale intent preserved through window changes, AH visits, reload and logout, so that I do not reconstruct my selections.
24. As a casual seller, I want intended and currently available quantities distinguished, so that changed bags do not silently erase my plan or promise unavailable items.
25. As a casual seller, I want AH-designated selections carried to Copperwise's AH surface, so that I can act on my existing list.
26. As a casual seller, I want to review item, quantity, price, duration and deposit before posting, so that cached intent cannot cause an unintended listing.
27. As a casual seller, I want one deliberate Post all action to start posting the reviewed batch, with any further clicks required by the native client, so that marking or opening the addon never spends a deposit.
28. As a casual seller, I want the pending quantity reduced only after a confirmed post, so that failed or cancelled attempts preserve my remaining intent.
29. As a casual seller, I want uncertain outcomes reconciled before retrying, so that I do not accidentally post twice.
30. As a casual seller, I want partial completion to leave the remaining quantity queued, so that I can finish the batch or resume its remainder through a later deliberate start.
31. As a casual seller, I want vendor-designated items clearly identified, so that I can sell them using the normal merchant UI.
32. As a casual seller, I want familiar native controls and readable item/coin presentation, so that Copperwise feels integrated with the game.
33. As a casual seller, I want listing values described as asking values, so that I do not mistake them for completed sales or guaranteed profit.

## Implementation Decisions

- Build a production Lua addon using the verified native bag, commodity query
  and direct commodity posting capabilities. Completed probes establish bounded
  capability, not production completeness.
- Target the existing Forever macOS Intel client and current-character workflow.
  Record the actual build and context during release acceptance.
- Use the approved Inventory prototype and later approved ranking/queue decisions.
  Native controls, fonts, icons, coin presentation and scaling take precedence
  over browser-specific prototype details. No history graph is needed for MVP.
- Aggregate comparable supported items across bag stacks. Reconcile settled bag
  observations; transient bag updates must not produce actionable double counts.
  Revalidate location, identity, quantity and posting terms before each action.
- Run a user-initiated full-market summary scan from the Copperwise tab inside
  the native AH window, following the native unfiltered browse/pagination path
  used by Auctionator's summary mode, without depending on Auctionator. Inventory
  contains no scan controls: it reviews retained observations and marks sale
  destinations. Missing data directs the player to Full scan in the AH tab.
- Collect native item keys, minimum asking prices and available quantities across
  all browse pages. Observe native completeness; do not describe summaries as
  individual listings or an atomic market snapshot. Validate commodity unit-price
  and supply semantics in the actual client before accepting those comparisons.
- Respect native throttling and other AH activity. Show progress and cancellation;
  AH closure or leaving the scan tab stops further requests. Bound request count,
  processed rows and elapsed time; hitting a bound is incomplete and cannot
  replace a previous complete scan. Metadata loading never initiates a scan.
- Store latest successful local observations with source time, item identity,
  native market context and coverage. Keep them separate from the latest attempt
  state. Failed/cancelled refreshes must not erase a prior usable observation or
  make it appear newly observed. Complete empty observations are valid results
  with unavailable buyout, not zero buyout. Partial observations cannot masquerade
  as complete estimates or drive a destination recommendation.
- Share retained market scan observations across all characters on the same
  account using account-wide addon persistence. Separate incompatible native
  markets (realm/faction/region); scanning character identity must not restrict
  access to a compatible market observation. Preserve its original source time,
  coverage and comparable item identities when another character reads it.
- Keep current bag holdings and sale intent character-specific. Restore intent
  before revalidating that character's current holdings. No live prices away
  from AH, offline collection, cross-account sharing or simultaneous-client
  synchronization is implied. Ordinary save on reload/logout and load on
  login/reload is sufficient for the intended character-switching workflow.
- Inventory shows gross observed unit buyout times owned units and vendor sell
  value times the same units. Deduct the faction AH 5% cut from the gross AH
  total, rounding estimated proceeds down to whole copper. Rank complete
  comparisons by the greater of estimated AH proceeds and vendor total,
  descending; ties sort by name and stable identity. Unavailable comparisons
  sort last. Choose Vendor on equal destination totals. Omit the destination
  button when either value is unavailable; known zero remains numeric zero.
- An AH destination button shows a warning when observation age exceeds a
  user-configurable threshold, default one hour. Exactly one hour does not
  exceed the threshold. Cache loading does not refresh observation time.
- Marking defaults to the currently observed bag quantity, with positive whole
  item-unit edits. Duplicate additions increase existing intent; edits replace
  quantity; removal is explicit. Keep intended and executable quantities distinct.
  Preserve the selected destination rather than silently changing an existing
  decision when new prices arrive; allow explicit removal/reselection.
- Marked rows appear separately from unmarked inventory. Selection and marking
  are independent. AH and Vendor intent remain distinct; only AH intent enters
  Copperwise posting. Merchant automation is outside this release. Vendor intent
  can be explicitly removed; a bag decrease alone is not proof of a vendor sale.
- Keep the Inventory marking window separate from the native auction-house
  window. Implement posting in a Copperwise tab within the native AH window,
  following the probes' integration approach. Populate that tab's posting queue
  only from explicit Sell on AH intent created in the Inventory window; neither
  Vendor intent nor unmarked holdings become posting candidates automatically.
- Review the complete AH-marked list in one compact surface, showing unit/total
  price, quantity, native duration and native-calculated deposit where known.
  Provide proposed defaults, optional per-item edits and a shared duration
  setting; selecting/configuring each row is not a required step. Price defaults
  and refresh policy remain to be explicitly settled; no undercut strategy is
  mandated. Post all starts execution of the reviewed batch in ticket 06.
- Sale intent spans stacks, but each post may be bounded to one revalidated
  source stack, consistent with the verified posting probe. Keep the remainder
  queued for successive posts within the reviewed batch; automatic stack
  consolidation and per-stack review are unnecessary.
- Use supported direct native posting calls in succession, with Post all as the
  main user action. Verify whether the target client permits advancement after
  one initial click; if further clicks are required, use one consistent button
  advancing the same reviewed list. Preserve native confirmations and permissions.
  Timers/events can advance only an explicitly started, still-active batch where
  permitted; windows, intent changes, scanning, reload and unrelated events never
  start or resume posting. Revalidate and reconcile each post before advancing.
- Reduce pending units only by confirmed attributed posting outcomes, removing
  entries at zero. A click, API return, shared event or bag delta alone does not
  prove a post. Uncertain outcomes retain unresolved intent and prevent blind
  retry until reconciled against native owned listings and current holdings;
  allow explicit operator reconciliation where reliable attribution is unavailable.
- The existing API-oriented Phase 0 conclusion is not a prerequisite for this
  addon-only release. Its production prerequisites are the relevant completed
  client probes plus the in-client acceptance below. The later API/history release
  retains its existing feasibility gates.

## Testing Decisions

- Owner confirmed one primary acceptance boundary: the complete production addon
  workflow in the actual target client, from bags and native AH observations
  through visible inventory, persistent sale intent and deliberate posting.
- Exercise externally visible behavior rather than private helpers, storage
  shapes or mocked client behavior. Use controlled owned quantities and chosen
  sample listings/terms where practical, with recorded native comparisons.
- Verify the connected journey: inspect bags, scan supported items at the AH,
  review ranking/destination values, mark/edit/remove quantities, leave/reopen,
  reload/logout and restore intent, then review and deliberately post.
- Verify multi-stack quantities and transient bag changes, unavailable/zero vendor
  metadata, no scan, empty/partial/failed/cancelled scans, stale observations and
  configured warning boundaries through visible outcomes.
- Verify scan coexistence, AH closure/recovery and failed refreshes preserving
  prior observations without changing their source time or coverage.
- Verify posting success using native owned listings and reconciled bag changes;
  cover changed availability/terms, cancellation, failure, uncertain outcomes,
  partial completion and repeat-action prevention. Marking and restoring intent
  must never submit a transaction.
- Verify native layout/readability at the owner's normal UI scale and normal
  AH navigation with Auctionator installed, without depending on Auctionator.
- Verify marking takes place in the separate Inventory window and posting takes
  place in Copperwise's native AH tab. Confirm only AH-marked items appear in
  that tab's posting queue, including after persistence and restoration.
- Reuse the existing bag, native auction-house and posting probes as capability
  evidence and manual-checklist prior art. Their passed samples do not pass the
  integrated production workflow automatically. Existing Go pipeline tests do
  not establish addon acceptance. Syntax checks are supporting checks only.

## Out of Scope

- Backend/API collection, credentials, desktop companion, exports/imports and
  continuous offline observation.
- Price trends, accumulated history, history ranges/graphs, historical crafting
  costs and scan/history reconciliation. Retaining a latest local observation
  does not introduce a history product.
- Crafting economics, recipe browsing, craft queues, ingredient shopping and
  native purchasing. The purchase capability probe is not an MVP prerequisite.
- Neutral/cross-faction auction houses (15% commission); defer to a later release.
- Bank inclusion, cached bank planning, other-character holdings and transfers.
- Equipment variants, noncommodity auction workflows and unsupported item classes.
- Automatic merchant selling, unprompted/background batch starts or resumptions,
  automatic undercut rules,
  automatic stack consolidation, cancellation of existing auctions and accounting.
- Claims of completed sales, sale probability, forecasts or guaranteed profit.
- Public distribution/accounts, additional markets/platforms and companion polish.

## Further Notes

This is the first release boundary, not deletion of the broader roadmap. It
supersedes the API/companion prerequisite only for addon-only selling work.
The owner confirmed the in-client testing boundary on 2026-11-15 after discussing
deferral of market trends in favor of a usable standalone addon.

Implementation order reuses selling-context slices S10 (one bag item with scan),
S11 (browse/rank), S15 (persistent sale intent), and S16 (review/post next),
followed by focused addon-only release acceptance. M18 scanning, S03 bag data,
S08 direct posting, S01 Inventory prototype, and S06/S07 decisions provide prior
evidence. S09 purchasing is deferred. Original S23 describes the broader release
and does not define MVP completion. Existing ticket files retain their historical
scope until reconciled into MVP-specific implementation tickets.

The approved final ranking and sale-intent decisions apply; earlier auction-uplift
proposals do not. Existing crafting tickets contain older replacement-cost wording
that must be reconciled with later approved per-craft additional-cost decisions
before that later increment starts.

Planning references: [selling-context specification](../selling-context/spec.md),
[ranking decisions](../selling-context/ranking-bases.md), and
[queue decisions](../selling-context/queue-rules.md). The release-specific scope
and acceptance boundary above govern this MVP.

Owner clarification: the marking window and posting surface are separate. The
posting surface is a Copperwise tab inside the native AH window, as in the
probes, and acts only on items marked Sell on AH in the Inventory window.

Owner clarification (2026-11-15): entire-market summary-mode scanning is required,
matching Auctionator's reported "full scan (summary mode)", rather than scanning
only bag items. Scan controls belong exclusively in Copperwise's native AH tab.
The standalone Inventory window is for reviewing and sorting AH/Vendor intent.
This replaces the earlier bounded-item/sequential-bag collection design. Existing
single-item acceptance evidence remains historical and does not pass full-scan
coverage or the revised two-surface workflow. Installed Auctionator source uses
`SendBrowseQuery` with empty search/filters and `RequestMoreBrowseResults` until
`HasFullBrowseResults`, collecting `minPrice` and `totalQuantity` per native key.
The screenshot establishes Auctionator's reported success for 3,758 items; it
is not yet Copperwise full-scan acceptance.

### Account-wide data decision — 2026-11-15

Required: market scan data must be available to all characters on the same
account, subject to native market compatibility. The owner typically parks one
character at the AH to scan. An adventuring character uses those observations
to review its own bags, vendor some items and manually mail the rest to the
auction character. The receiving character handles its own holdings and sale
intent. This rationale does not add mail automation or a cross-character queue.

Implementation follow-up belongs to ticket 03: current code still stores scans
in per-character saved variables. Move market snapshots to account-wide storage,
preserve existing data and source times, and avoid an older character's migrated
snapshot replacing a newer snapshot for the same market. The existing
per-character implementation and its passed reload test do not establish
cross-character sharing.

Undecided future possibility: retain each character's bag and bank holdings so
other characters on the account can view them. The owner has not identified a
strong enough use case to commit to this. Do not implement it, treat it as an
MVP requirement, or merge different characters' holdings. Account-wide scan
sharing does not authorize account-wide inventory collection; bank/other-character
holdings remain outside the current release scope. Revisit when a concrete
workflow justifies the additional data and freshness rules.

### Saved-data compatibility decision — 2026-11-15

The owner is the sole user and waived migration from pre-account-wide versions.
This supersedes the earlier per-character snapshot migration requirement.
Account-wide schema version 1 is the compatibility baseline. From now on, schema
changes in addon updates must provide sequential saved-data migrations, preserving
observations and source times across supported upgrades, including skipped
releases. Unsupported or malformed stores and failed migrations must be preserved
rather than silently reset or overwritten.

### Faction AH commission decision — 2026-11-15

Owner requires commission to affect ranking and approved faction AH only for
the MVP. Compare estimated AH proceeds after the 5% cut against vendor sell
total for the same owned quantity. Use the larger value for ranking and choose
Vendor on ties; both comparison values remain required. Keep gross asking
values visible in detail. Estimated proceeds round down to whole copper,
exclude deposits, and do not imply a completed sale or guaranteed profit.
Neutral/cross-faction AH support, including its 15% cut and compatible market
identification, belongs to a later release. Perform MVP scans and posts only
at faction auction houses; existing faction market context does not establish
neutral-house support. Earlier gross-total ranking decisions are superseded.

### Ticket 02 acceptance exception — 2026-11-15

Owner approved code-only synthetic tests, with no additional in-game run, for
remaining ticket 02 cases that cannot reasonably be found in real holdings:
net AH/vendor ties, missing vendor metadata, missing retained observations and
equal-value ordering. These tests complement the recorded client workflow
passes and suffice to settle ticket 02. The exception is limited to this ticket;
it does not claim native-server evidence or waive later ticket/release testing.


### Deferred faction/ruleset acceptance — 2026-11-15

Owner deferred all testing for other factions/rulesets to
[ticket 08](issues/08-verify-other-factions-and-rulesets.md), including remaining
incompatible-market client verification across faction/realm/region. This does
not gate ticket 03 or release acceptance in the currently verified Forever
Alliance environment. Existing automated isolation checks remain required.
Untested environments are not accepted by this deferral, and neutral AH/other
ruleset support is not added to the MVP scope.

### Prototype marking interaction correction — 2026-11-15

Owner requested closer adherence to `probes/ui-inventory/index.html` after the
initial ticket 04 Add bag units control made accidental quantity accumulation
too easy. Use independent per-row AH/Vendor mark buttons, with AH ×/Vendor ×
to unmark. Keep unmarked inventory above the separate marked section; clicking
the item name/icon changes selection only. A new mark defaults to current bag
units. Repeated marking is a mark/unmark toggle, never additive intent. Edit
marked quantity explicitly through a labeled Units to sell field and Save
quantity. This supersedes the earlier duplicate-addition rule for the MVP sale
marking flow; craft-queue rules and other future workflows are unchanged.
Preserve existing saved intent quantities; the UI change does not reset plans.

### Partial sale intent and quantity totals — 2026-11-15

Owner verified Units to sell survives reload, then requested splitting partial
intent from unmarked remainder. If bags contain 11 units and intent is 5, show
5 in Marked for sale and 6 in the upper inventory section. The upper row's
destination action adds only those 6 to the existing intent, preserving its
chosen destination; once all observed bags are intended, no upper row remains.
The marked row's × action removes the whole intent. This extends the preceding
prototype correction: additive marking is permitted only for currently unmarked
bag remainder, with no general Add bag units control or double counting.

Rank and display each portion using its own quantity. Selecting the marked
portion shows totals for intended units (5 in the example), and selecting the
upper portion shows totals for remaining unmarked units (6). Keep total bag
holdings, intended units, coverage and shortages distinct. An intent above
current bags retains its full planned quantity and shortage, with zero upper
remainder. Editing or changing observed bags recalculates the split; no saved
schema change or silent intent change is needed.

### Full-scan freshness warning — 2026-11-15

Owner confirmed the partial quantity split and portion-specific totals survive
reload. Owner then requested one Inventory-window warning icon for outdated
market data, replacing per-item exclamation marks: successful scans replace the
entire market snapshot, so all retained item prices share a source timestamp.
Use the compatible market's last complete scan time and existing configurable
threshold (default 60 minutes, strictly exceeded). The warning is independent
of selected item, destination and current holdings. Hover explains source time,
market, threshold and refresh action. Missing compatible scans show existing
unavailable states instead of an invented stale scan. Failed/cancelled scans
continue to use the retained complete snapshot's age. This supersedes earlier
per-AH-button stale warnings. No scan merging or incremental refresh is added.

### Quiet holdings revalidation — 2026-11-15

Owner confirms the window-level warning, zero-availability shortage behavior
and manual Vendor sale behavior work. Owner reports hovering native bag items
briefly hides destination buttons and replaces marked-row bag counts with
checking. Keep background revalidation visually quiet: retain last settled
buttons, quantities, totals, shortages and order while unsettled. Continue to
require settled holdings at click time for new/remainder marks. Explicit edits
and removals remain available. Before the first settled login observation,
show availability as unavailable rather than treating saved intent as holdings.
Publish genuine holding changes after settling. This supersedes earlier
checking labels and temporary destination-button hiding during bag activity.

### Whole-list review and Post all — 2026-11-15

Owner confirms the target is mark items → visit AH → Copperwise tab → Post all.
Ticket 05 provides review of the entire AH-marked list with proposed terms and
optional edits, without mandatory per-item review or any transaction. Ticket 06
makes mass posting explicit through successive supported native calls; a single
multi-item native request is not assumed. One initial start should drive the
sequence if the target client permits it. Any required extra clicks use the
same advancing button, preserving the reviewed list and native confirmations.
The existing individual-post probe does not establish batch click requirements.

Only confirmed posts reduce intent. Known shortages/ineligible entries and
known-unposted failures remain pending with reasons; other eligible entries may
continue when safe, without automatic failure retries. Uncertainty pauses the
sequence until reconciled. Stop/Cancel prevents new dispatches and reconciles
in-flight results; closure, tab departure, conflicting AH activity or invalid
terms stop/pause the session. Reopening/reloading never auto-resumes. New or
increased intent is outside an already-reviewed batch and requires a later
review/start. These decisions supersede earlier per-post deliberate-click and
blanket event/timer-advancement prohibitions only within an explicitly started
reviewed batch. They do not authorize background posting starts or native action
restriction bypasses. Price defaults/refresh and duration defaults remain to be
settled explicitly; matching lowest buyout has been suggested, not mandated.
