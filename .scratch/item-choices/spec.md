# Per-item Keep, Vendor and AH choices

Status: resolved — owner approved installed inventory and minimap changes

## Request

Reduce repeated review of newly acquired items in `/cw`. Each item type can be
kept, assigned to Vendor, or assigned to AH, overriding estimated profitability.
The owner reviewed the browser prototype and requested category-wide clearing.
Prototype committed as `83c2ace`.

## Behavior

- Uncategorized items appear first, followed by To vendor, To AH and To keep.
- Each category has a count and Clear button. Clear removes all choices and pending
  sale intent in that category, including items not currently in bags.
- Each item offers three explicit choices. Repeating the selected choice clears
  it; selecting another destination switches it. Missing prices do not block choices.
- Keep excludes an item type from repeated uncategorized review. Vendor and AH
  override the comparison; the comparison remains advisory.
- Choices use the existing per-character persistence scope. They survive reload
  and completed posts, applying to newly observed bag quantity increases.
- Sale quantities remain a separate queue; confirmed posts reduce that queue.
  New quantities cover an existing shortage before adding more intent. Changing
  destination marks the current settled bag amount. Clearing removes intent.
- Existing quantity-only sale plans remain supported; no destructive migration.
- Settled net changes cannot identify acquisitions offset by losses between snapshots.

## Verification

Simulated production-module UI checks cover overrides, missing values, category
clearing/isolation, reload, acquisitions, shortage coverage, posting revision
invalidation and malformed saved data. Storage and scan regressions also pass.
The owner reviewed the installed `/cw` UI through successive reloads and screenshots,
including categories, flat choice controls, recommendation highlighting, category
clearing, the Assign recommended action, icon retention and heading alignment.
The owner also approved the draggable minimap button after installation.
Supporting tests cover persistence, acquisitions, shortage coverage and posting
revision protection; this does not claim a new end-to-end native posting test.
Broader posting and release verification remain in selling-MVP tickets 06/07.

## Final additions

- Flat joined choices use a solid selected state and advisory highlight while
  uncategorized. Category headings align with the flat action buttons.
- Assign recommended categorizes eligible uncategorized items, preserving existing
  choices and skipping incomplete comparisons.
- Saved icons remain available when categorized items leave bags.
- A minimap button toggles Inventory and can be dragged around round/square minimap
  edges. Its angle persists per character.

## Comments

2026-11-16: Owner approved the installed result: “i'm happy the way things are now,
so let's approve and commit”. Inventory, storage and scan checks and diff whitespace
validation pass. This closes the item-choice/minimap iteration; ticket 06 is separate.
