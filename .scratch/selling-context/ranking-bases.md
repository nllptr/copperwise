# S06 ranking decision table

Status: awaiting owner decision. All amounts below are synthetic copper values.
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

Pending: Inventory default and alternative, Crafting default and alternative,
visible basis labels, and shared tie/missing-estimate handling above. Approval
of S02's presentation or the ticket breakdown does not approve these proposals.
Once the owner responds, record the exact decisions here and link them from
S06. Until then, production ranking remains unselected and S06 remains open.
