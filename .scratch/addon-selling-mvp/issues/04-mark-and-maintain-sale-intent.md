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
