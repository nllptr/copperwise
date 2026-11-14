# S06 ranking decision table

Status: completed — owner approved both defaults and the sidebar prototype.
All amounts below are synthetic copper values.
S02 and S05 are complete; neither approved a ranking formula. This document
provides inspectable orders, not a pricing engine or a personal cost ledger.

## Inventory: what should rise to the top?

Auction uplift per unit = observed unit buyout − unit vendor sell value.
Owned uplift = unit uplift × counted owned units (across bag stacks, plus bank
only when included). It is additional asking value over vendoring, not recorded
profit: acquisition costs, deposits, fees and completed sales are absent.

| Item | Owned units | Buyout/unit | Vendor/unit | Uplift/unit | Owned uplift |
| --- | ---: | ---: | ---: | ---: | ---: |
| Amber | 1 | 100 | 20 | 80 | 80 |
| Bark | 20 | 30 | 10 | 20 | 400 |
| Clay | 2 | 50 | 10 | 40 | 80 |
| Dust | 5 | 10 | 10 | 0 | 0 |
| Ember | 3 | 5 | 10 | −5 | −15 |
| Flax | 10 | unavailable | 10 | unavailable | unavailable |

Descending unit order: Amber, Clay, Bark, Dust, Ember, Flax.
Descending owned order: Bark, Amber, Clay, Dust, Ember, Flax.
Amber and Clay tie on owned uplift; the displayed example breaks ties by name.
Ember stays negative rather than being clamped to zero. Flax is unknown, not
zero. Missing vendor metadata also withholds uplift. An observed market with
no buyouts has no buyout price and therefore no auction uplift estimate.

Proposal: default to **Auction uplift · owned quantity**, highest first, to
surface the largest additional asking value in the included holdings. Offer
**Auction uplift · per unit** as the alternative. Row values must identify
their matching basis; changing Include bank changes counted quantities, so can
change the owned order. These labels and defaults await approval.

## Crafting: output unit or one craft?

For this comparison, estimated margin/craft = unit output buyout × fixed output
yield − additional ingredient cost for one craft. Margin/output divides that
margin by yield. This follows the S02 revised display: credit eligible owned
inputs once, price missing inputs at AH asking prices, and compare each recipe
independently. Owned inputs are not reserved across these alternatives. This
is not replacement-cost profit or a ledger of actual expenses. Ingredient
source selection and cached-bank eligibility remain separate open policies.

| Recipe | Outputs/craft | Buyout/output | Additional cost/craft | Margin/craft | Margin/output |
| --- | ---: | ---: | ---: | ---: | ---: |
| Single Salve | 1 | 100 | 20 | 80 | 80 |
| Twin Tonic | 2 | 70 | 30 | 110 | 55 |
| Quiet Oil | 1 | 20 | 20 | 0 | 0 |
| Bitter Brew | 2 | 10 | 30 | −10 | −5 |
| Cloud Elixir | 2 | 70 | unavailable | unavailable | unavailable |

Descending per-output order: Single Salve, Twin Tonic, Quiet Oil, Bitter Brew,
Cloud Elixir. Descending per-craft order: Twin Tonic, Single Salve, Quiet Oil,
Bitter Brew, Cloud Elixir. Missing output price, ingredient price, required
quantity or a supported fixed yield withholds margin; it never supplies a free
input. A known zero additional cost from sufficient owned inputs is valid.

Proposal: default to **Estimated margin · per craft**, highest first, matching
the approved S02 row presentation. Offer **Estimated margin · per output** as
the alternative. The list always compares one craft, independent of the detail
preview count. For example, Twin Tonic can require 110c additional inputs for
two crafts after ownership is credited once, yielding 170c batch margin and
85c average margin/craft; this does not replace its single-craft 110c list value.

## Shared ordering and missing estimates

Proposal: retain zero and negative estimates in numeric order; place unavailable
estimates last with **Unavailable** (or a dash with that accessible label).
Break numeric ties by displayed name ascending, then stable item/recipe identity
for duplicate names. Order unavailable rows by the same name/identity rule.
Compare unrounded amounts so display rounding does not manufacture ties.
For example, two recipes each at 80c/craft sort by name, regardless of yield.
Learning status remains a separate indicator/filter, not an implicit margin
adjustment or proof that crafting is executable.

## Owner decision

The following owner decisions supersede the proposed defaults above.

### Inventory: highest total destination value

For each item kind, aggregate counted owned units across stacks. Calculate total
AH asking value and total vendor sell value for that same quantity. Rank rows
highest first by the larger total. That same comparison selects the AH or Vendor
button. This replaces the auction-uplift proposal; uplift is not the default
ranking basis. Include bank changes the counted holdings when enabled.

| Item | Owned units | AH total | Vendor total | Ranking value | Button |
| --- | ---: | ---: | ---: | ---: | --- |
| Amber | 1 | 100 | 20 | 100 | AH |
| Bark | 20 | 600 | 200 | 600 | AH |
| Clay | 2 | 100 | 20 | 100 | AH |
| Dust | 5 | 50 | 50 | 50 | Vendor |
| Ember | 3 | 15 | 30 | 30 | Vendor |

Chosen order: Bark, Amber/Clay (equal ranking value), Dust, Ember. For an
additional distinction from uplift, an item with AH total 500c and vendor total
490c ranks above one with AH total 400c and vendor total 0c: 500c beats 400c,
even though its auction uplift is smaller. No sale, fees or recorded profit
is established by these asking values.

Owner approved Vendor on equal totals: immediate sale avoids risking an AH
deposit for no greater asking value. When neither destination value is known,
keep the item in the list and omit its action button; no recommendation is
possible. Owner subsequently clarified: omit the button if either value is
missing, even when the other is known; both are required for comparison.
A known numeric zero is distinct from unavailable metadata.

An AH button must carry an extra warning icon when the age of its underlying
AH observation exceeds a configurable threshold. Use observation age, not import
age. This warning does not itself change the chosen ranking formula. The default
threshold is **1 hour (60 minutes)**, owner-approved. Expose it as an easily
changed user setting, not a source-code constant requiring edits. A warning
appears when age is greater than the threshold; exactly one hour does not
exceed it. The exact settings placement remains an implementation detail.

Vendor value is not guaranteed to be available: the S03 actual-client probe
observed initial unavailable metadata for all three samples, followed by cache
notifications resolving their sell values (including a known zero). See
[S03 evidence](../../probes/bags/REPORT.md). S05 also recorded missing sell
metadata for a recipe ingredient. Missing vendor data must remain supported;
we cannot limit missing-price handling to AH data alone.

### Crafting: estimated margin per craft

Owner approved the per-craft default described above: Twin Tonic (110c) before
Single Salve (80c), then Quiet Oil (0c), Bitter Brew (−10c), Cloud Elixir
(unavailable under the proposed missing-value rule).

Recalculate costs and margins when actual owned ingredients change, and re-sort
the sidebar. Consuming owned materials can increase additional cost and move a
recipe down. Example: Twin Tonic's full input cost is 80c/craft. With ownership
covering 50c, its margin is 140 − 30 = 110c; with no owned ingredients left,
its margin becomes 140 − 80 = 60c. Single Salve at 80c then moves above it.
Changing the detail preview count alone does not consume ingredients or cause
that holdings-driven re-sort.

### Final presentation and ordering (owner-approved prototype)

Owner approved the S06 prototype (“prototype looked good”). No list heading or
repeated basis label is required. Inventory rows show icon, name (quantity),
total best sale asking value and destination button. Crafting rows show icon,
name, margin with `/craft`, and an extra indicator when owned ingredients reduce
additional cost, explained on hover and in the accessible row name.

Both lists sort descending numerically, unavailable comparisons last, with
alphabetical names for ties. Stable identity can resolve duplicate names as an
implementation detail. Zero/negative margins retain their numeric position.
Alternative sort controls are not required by this approval. Equal destination totals
use Vendor. Either price missing means no button, including when no AH buyout
price is available from an observed empty market. This supersedes S01's
observed-empty Vendor fallback. A missing value must not silently become zero.
Observed empty buyouts versus missing observations remain distinguishable.
The stale-AH warning uses an easily changed setting defaulting to one hour.

S06 is complete as a policy/UX decision. Production sorting and configuration
remain downstream implementation work. Historical proposals above remain
comparison context, not approval of alternatives or uplift sorting.
