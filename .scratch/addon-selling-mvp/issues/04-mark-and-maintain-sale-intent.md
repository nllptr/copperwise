# 04: Mark and maintain sale intent

**What to build:** In the separate Inventory window, the player marks AH or Vendor sale intent, edits/removes quantities and restores the same character's pending plan after reload/logout.

**Blocked by:** 02: Browse and rank bag items.

**Status:** ready-for-agent

**Labels:** ready-for-agent

- [ ] Use the approved destination comparison for the marking action; move marked items into a separate section while row selection remains independent.
- [ ] Default a new mark to currently observed bag units; accept positive whole item-unit quantities, independent of stack boundaries.
- [ ] Duplicate additions increase existing intent, edits replace quantity and removal is explicit; preserve the chosen destination across later price changes unless explicitly removed/reselected.
- [ ] Show intended and currently available quantities separately; revalidate holdings without silently deleting shortages or treating saved intent as current availability.
- [ ] Persist intent through window/tab changes, AH visits, reload and logout, scoped to the current character.
- [ ] Keep AH and Vendor intent distinct; Vendor selling uses the normal merchant UI, and a bag decrease alone does not prove a vendor sale.
- [ ] Verify add/edit/remove, duplicates, shortages, persistence and character isolation in the target client; marking, restoration and window changes never post anything.

## Scope and verification

Use the addon-only selling MVP specification and its approved ranking and sale-intent decisions. This ticket is a production vertical slice, verified through visible behavior in the actual target client. Reuse completed bag, native scanning and posting probes as bounded capability evidence; they do not pass this slice automatically. API, backend, companion, history, bank, crafting and purchasing work do not gate this release.

## Comments

Published after owner approval of the seven-ticket breakdown. This MVP series replaces the broader selling-context implementation order for the first release; the older roadmap remains historical and later-release scope. No parent specification or older ticket is closed or modified.
