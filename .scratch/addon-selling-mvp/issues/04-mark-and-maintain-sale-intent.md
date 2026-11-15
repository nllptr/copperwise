# 04: Mark and maintain sale intent

**What to build:** In the separate Inventory window, the player marks AH or Vendor sale intent, edits/removes quantities and restores the same character's pending plan after reload/logout.

**Blocked by:** 02: Browse and rank bag items.

**Status:** implemented — target-client acceptance pending

**Labels:** ready-for-agent

- [ ] Use the approved destination comparison for the marking action; move marked items into a separate section while row selection remains independent.
- [ ] Default a new mark to currently observed bag units; accept positive whole item-unit quantities, independent of stack boundaries.
- [ ] Row buttons toggle marking/removal without accumulating intent; labeled quantity edits replace quantity; preserve the chosen destination across later price changes unless explicitly removed/reselected.
- [ ] Show intended and currently available quantities separately; revalidate holdings without silently deleting shortages or treating saved intent as current availability.
- [ ] Persist intent through window/tab changes, AH visits, reload and logout, scoped to the current character.
- [ ] Keep AH and Vendor intent distinct; Vendor selling uses the normal merchant UI, and a bag decrease alone does not prove a vendor sale.
- [ ] Verify add/edit/remove, duplicates, shortages, persistence and character isolation in the target client; marking, restoration and window changes never post anything.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.

### Implementation — 2026-11-15

Added Inventory destination marking, separate marked/unmarked sections and
positive whole-unit editing, additive bag-unit additions and explicit removal.
Selection remains independent. Existing destination choices survive later
price changes; remove and reselect to change destination. Shortages, including
zero current holdings, remain visible and never delete intent. Holdings are
revalidated through the existing settling boundary; pending observations show
checking and cannot supply additions. Vendor marks use the normal merchant UI;
no bag event completes intent and no transaction API is called.

Added versioned per-character sale-plan persistence, independently of shared
market observations. Unsupported/malformed plans are preserved with editing
disabled. The existing Inventory regression fixture now loads the production
Intent module and supports its native controls; no new synthetic acceptance
boundary is introduced for this ticket.

The agreed primary boundary remains the actual production addon in the target
client. Follow the [ticket 04 checklist](../../../addons/Copperwise/README.md#ticket-04-client-acceptance--pending)
for add/edit/remove, duplicates, shortages, reload/logout, character isolation,
price changes, layout and absence of transactions. No acceptance box is checked
by repository validation; target-client verification remains pending.

### Prototype alignment correction — 2026-11-15

Owner screenshot showed repeated Add bag units clicks producing 99 intended
from 11 bags (88 shortage); the arithmetic followed the original rule, but the
control was confusing. Owner requested the approved Inventory prototype's
interaction instead. Added independent row AH/Vendor buttons and AH ×/Vendor ×
unmarking, with unmarked inventory above the marked section. Row selection
never changes intent, and marking never changes selection. Removed detail
mark/remove/add controls; quantity editing is labeled Units to sell with Save
quantity. Repeated marking no longer accumulates intent. The spec records this
superseding interaction decision; existing saved quantities remain intact.

The screenshot establishes intended/current/shortage display for Bolt of Linen
Cloth (11 bags, 99 intended, 88 shortage), but does not establish how many clicks
were made or pass the revised controls. Revised target-client acceptance remains
pending. Use the updated README checklist rather than the historical initial
Add bag units instructions above.

### Revised controls — owner client feedback — 2026-11-15

After installing prototype-alignment commit `5fda914`, the owner reports that
it “seems to be working as expected.” Record this as a positive production-client
check of the revised marking interaction. No individual unreported acceptance
case is inferred: reload/logout restoration, character isolation, zero-holding
shortages, price-change destination preservation and absence of transactions
across the complete lifecycle still require explicit verification. Ticket 04
remains implemented with acceptance pending.

### Partial intent and selected totals — 2026-11-15

Owner explicitly confirms Units to sell survives reload. This passes that
bounded reload quantity-restoration check; logout and character isolation are
not implied. Owner requests that a partial mark leave its unmarked remainder
in the top list and allow adding it to the existing sale plan. Owner also
reports totals still showing all bag units after editing intent to 5.

Implemented quantity-based split rows: 11 bags / 5 intent shows marked 5 and
unmarked 6, each ranked and valued for its own quantity. Selecting each portion
shows that portion's gross/net AH and vendor totals, separately from total bag
holdings. The upper AH +/Vendor + adds only current unmarked remainder and
preserves the saved destination; marked × still removes all intent. Intended
shortages remain; no zero remainder row or duplicate bag allocation is created.
Cached comparisons and retained list order distinguish item portions. Saved
plan format and prior quantities are unchanged. The spec records this extension
to the earlier toggle-only interaction decision.

Revised split-row/quantity-total behavior requires client verification using
the updated README worked example. Remaining acceptance stays pending.

### Partial-quantity client feedback — 2026-11-15

Owner supplied bank-character bag contents showing Bolt of Linen Cloth ×11
and retained net AH value 522c. Guided verification used that item: mark 11,
edit intent to 5, inspect upper remainder 6 and marked 5 with portion-specific
row/detail totals, then add the remaining 6 to restore intent 11. Expected
retained-price examples were 50c AH / 40c vendor per unit: marked 5 gives
250c gross AH / 237c net / 200c vendor; remainder 6 gives 300c gross /
285c net / 240c vendor. Owner reports it “seems to be working as expected.”
Record positive client feedback for this guided split/total/add-remainder
scenario, without implying separate screenshots or independent price checks
for every step. Split restoration after reload, logout, character isolation,
zero-holding shortages and destination preservation after price changes remain
unverified. The earlier owner-confirmed quantity restoration after reload
remains valid evidence for the prior version. Ticket acceptance stays pending.

### Split reload acceptance and scan warning correction — 2026-11-15

Owner confirms the requested reload check passes: 6 unmarked / 5 AH-marked
survives reload, with each portion's totals still using its own quantity.
This settles the revised split-quantity reload case; logout and other remaining
acceptance cases are not inferred.

Owner requests one outdated-scan warning icon in Inventory instead of **!** on
every AH button. Complete scans replace the whole compatible-market snapshot,
so all retained prices share its timestamp. Implemented one top-of-window icon
and age label with tooltip for source time, market, threshold and refresh action.
It uses the existing strict configurable threshold and remains independent of
selection/destination. Removed row markers and duplicate selected-item warnings;
no scan merging or storage changes. Existing freshness regression checks now
observe the shared window warning, including Vendor/unavailable selections.
Client verification of the revised warning remains pending.

### Shortages, Vendor checks and quiet revalidation — 2026-11-15

Owner confirms the new single warning looks good and that the requested checks
2 and 3 work: marked intent persists at zero bag availability with shortage,
and selling through the normal merchant UI changes availability without
implicitly clearing Vendor intent. Character-isolation acceptance remains
pending; it was check 1 and was not included in that confirmation.

Owner reports hover-triggered brief destination-button disappearance and
marked-row labels switching from bags 2 to bags checking. Rendering exposed
transient settling state despite retaining the last observed rows. Removed
those presentation gates: display uses the last settled bag snapshot while
AvailableItem and the mark handler continue to block additions until settled.
First-login availability remains unavailable until an actual settled snapshot;
saved intent cannot manufacture observed zero holdings. Actual bag changes are
published only after the existing settling interval. Updated the spec and
README hover/split/move checklist; client verification of this fix is pending.

### Quiet revalidation client feedback — 2026-11-15

After installing `3e75856` and being asked to repeat native bag-item hovering,
the owner reports it “seems to be working now.” Record the reported hover
flicker (disappearing buttons and bags checking labels) as resolved in the
production client. The preceding owner-confirmed window warning, shortages,
Vendor intent and split/reload behavior remain accepted within their recorded
scope. Character isolation, logout restoration and destination preservation
across changed prices still lack explicit client confirmation; ticket 04
remains implemented with remaining acceptance pending.
