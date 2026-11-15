# Copperwise AH layout study

Open `index.html` directly in a browser. Self-contained HTML/CSS/JavaScript;
no build, network requests, dependencies or game connection.

This owner-requested replacement direction for ticket 05 follows the supplied
Auctionator screenshots and the existing `../ui-inventory/index.html` study.
The production addon is unchanged while this layout is reviewed.

## Review journey

1. The first AH-marked item is selected automatically. The sidebar contains the
   entire marked plan, with intended quantities; Vendor and unmarked items are
   excluded. Click another item to switch its posting form and listings.
2. Inspect quantity, unit buyout in gold/silver/copper, deposit, total buyout and
   2/8/24-hour duration radio buttons. The initial duration is 24 hours and is
   shared across item selections. Quantity defaults to eligible marked units;
   Max restores that quantity. Edits to quantity/price survive item switching.
3. Only Buyout price per unit and Available appear in the listings table.
   Available means item units at that price, grouped across listings. Click a
   price to use it in the posting form; no automatic undercut is modeled.
4. Post item simulates a confirmed post for the selected quantity only. It reduces
   that item's bags and intent, retains any remainder and selects the next item
   when the current mark is completed. A visible message confirms it is simulated.
5. Full scan and the disabled Post all placeholder sit in the shared top section.
   Full scan simulates progress and cancellation; Refresh item separately simulates
   loading selected-item listings, retaining edited terms. Native tabs are context
   labels rather than navigation to invented screens.
6. Use Preview state outside the proposed addon to inspect bag shortage, no current
   listings, unsupported items and an empty marked plan. Unsupported entries remain
   visible; an empty market permits an explicitly entered positive price. Invalid
   quantities/prices disable Post item. Reset prototype restores the selected scenario.

## Boundaries and decisions for implementation

All prices, supplies and deposits are synthetic fixtures. Some values echo the
screenshots for easy comparison; they are not collected observations. Deposits
are illustrative (one silver per prepared source stack in these fixtures), not
an asserted deposit formula, and remain constant as duration changes in this study.
Production must use native deposit calculations for the selected quantities and
duration. Currency presentation approximates native controls; glyph icons and
CSS frames must give way to native assets/fonts/widgets when implemented in Lua.

The requested current-listings panel requires selected-item native queries and
price-level aggregation. The existing retained full-market summary cannot supply
this depth. Full scan and selected-item refresh are distinct operations and must
respect native throttling, cancellation and Auctionator activity. This prototype
is no evidence that either native integration or posting works.

The initial proposed unit price here is the lowest selected-item listing. That
is a design proposal for the new current-listings workflow, not a silent change
to the approved production retained-scan default. Settle price-refresh/default
behavior before production reimplementation. The last complete global scan time
and selected-item refresh status are shown separately.

The requested per-item Post button extends the earlier batch-review surface.
Actual execution, confirmed outcomes and safe retries still belong to ticket 06;
this prototype introduces no transaction API or live batch execution. Post all
remains a placeholder. No production files, saved schemas or installed addon
files change as part of this study.
